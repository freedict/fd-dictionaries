"""FreeDict API generator

This script parses the meta data of all available dictionaries, queries
information about available releases and writes all information to an XML file.
For more information, please have a look at the wiki at
<http://freedict.org/howto>.

For usage of the script, try the -h option.
"""
import argparse
import os
import sys
import time

from apigen import dictionary, metadata, releases, xmlhandlers

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(sys.argv[0]))))
from config import get_path
import config



def exec_or_fail(command):
    """If command is not None, execute command. Exit upon failure."""
    if command:
        ret = os.system(command)
        if ret:
            print("Failed to execute `%s`:" % command)
            sys.exit(ret)


def read_dict_info(conf, generate_api=True):
    """Parse dictionary meta data from the dictionary source and extract
    information about all released dictionaries. Return a list of dictionaries
    (Dictionary objects). generate_api is used to emit a message which is only
    useful if the API is generated."""
    dictionaries = []
    for dict_source in ['crafted', 'generated']:
        dict_source = get_path(conf[dict_source])
        print("Parsing meta data for all dictionaries from", dict_source)
        dictionaries.extend(metadata.get_meta_from_xml(dict_source))

    release_path = get_path(conf['release'])
    print("Parsing release information from", release_path)
    release_files = releases.get_all_downloads(release_path)
    for dict in dictionaries:
        name = dict.get_name()
        if not name in release_files:
            if generate_api:
                print("Skipping %s, no releases found." % name)
            continue
        try:
            version = releases.get_latest_version(release_files[name])
        except releases.ReleaseError as e: # add file name to error
            raise releases.ReleaseError(list(e.args) + [name])
        for full_file, format in release_files[name][version]:
            dict.add_download(dictionary.mklink(full_file, format, version))
    return dictionaries



def find_outdated_releases(dictionaries):
    """This function finds dictionaries which have been updated, but not
    released yet."""
    candidates = []
    for dict in dictionaries:
        if dict.get_downloads() == []:
            candidates.append((dict.get_name(), None, None))
        else:
            released = max(l.version for l in dict.get_downloads())
            if dict['edition'] > released:
                candidates.append((dict.get_name(), dict['edition'], released))
    return candidates


def main(args):
    parser = argparse.ArgumentParser(description='FreeDict API generator')
    parser.add_argument("-n", "--need-update", dest="check_for_unreleased_dicts",
            action="store_true", default=False,
            help="check for unreleased dictionaries instead of generating the API file")
    parser.add_argument('-p', "--pre-exec-script", dest="prexec", metavar="PATH",
            help=('script/command to execute before this script, e.g. to set up a sshfs '
                'connection to a remote server, or to invoke rsync.'))
    parser.add_argument('-o', "--post-exec-script", dest="postexc", metavar="PATH",
            help=("script/command to execute after this script is done, e.g. to "
                "umount mounted volumes."))

    args = parser.parse_args(args[1:])
    conf = config.discover_and_load()

    exec_or_fail(args.prexec) # mount / synchronize release files

    dictionaries = read_dict_info(conf, not args.check_for_unreleased_dicts)

    if args.check_for_unreleased_dicts:
        outdated = find_outdated_releases(dictionaries)
        if not outdated:
            print("Everything up-to-date.")
        else:
            print("\nName      Source Version    Release Version")
            print("-------   ---------------   --------------------------")
            for data in sorted(outdated, key=lambda x: x[0]):
                name, v1, v2 = [str(e if e else 'unknown') for e in data]
                print('{}   {:<15}   {:<15}'.format(name, v1, v2))
    else:
        # remove dictionaries without download links
        dictionaries = sorted((d for d in dictionaries if d.get_downloads() != []),
            key=lambda entry: entry.get_name())
        api_path = config.get_path(conf['DEFAULT'], key='api_output_path')
        if not api_path == 'freedict-database.xml' and not os.path.exists(os.path.dirname(api_path)):
            os.makedirs(os.path.dirname(api_path))
        print("Writing API file to",api_path)
        xmlhandlers.write_freedict_database(api_path, dictionaries)

    # if the files had been mounted with sshfs, it's a good idea to give it some
    # time to synchronize its state, otherwise umounting fails
    time.sleep(2)
    exec_or_fail(args.postexc) # umount or rsync files, if required

if __name__ == '__main__':
    #pylint: disable=broad-except
    try:
        main(sys.argv)
    except Exception as e:
        if 'DEBUG' not in os.environ:
            print('Error:',str(e))
            print(("\nNote: Rerun the script with the environment variable DEBUG=1 "
                "to obtain a traceback."))
            sys.exit(9)
        else:
            raise e

