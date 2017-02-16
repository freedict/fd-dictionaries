"""FreeDict API generator

This script parses the meta data of all available dictionaries, queries
information about available releases and writes all information to an XML file.
For more information, please have a look at the wiki at
<http://freedict.org/howto>.

For usage of the script, try the -h option.
"""
import argparse
import os
from os.path import join as pathjoin
import sys
import time

from apigen import dictionary, metadata, releases, xmlhandlers



def find_freedictdir():
    """Find FreeDict path with these rules:
    1.   environment variable FREEDICTDIR is set, takeit 
    2.   current directory is tools, crafted, generated or release, then take parent

    When the FREEDICTDIR has been found, it's returned.
    FileNotFoundError is raised, if FREEDICTDIR couldn't be determined.
    ValueError is raised, if crafted, generated, release and tools could not be found in FREEDICTDIR."""
    localpath = None
    if 'FREEDICTDIR' in os.environ:
        localpath = os.environ['FREEDICTDIR']
    else: # check whether current directory contains dictionaries
        # is cwd == 'tools':
        cwd = os.getcwd()
        for subdir in ['crafted', 'generated', 'tools']:
            if cwd.endswith(subdir):
                localpath = os.path.abspath(os.path.join(cwd, '..'))

    notexists = lambda x: not os.path.exists(os.path.join(localpath, x))
    if localpath is None:
        raise ValueError("No environment variable FREEDICTDIR set and not in a "
                "subdirectory called either tools, crafted or generated.")
    if not os.path.exists(localpath):
        raise FileNotFoundError("FREEDICTDIR=%s: not found" % localpath)
    elif notexists('tools') or notexists('crafted') or notexists('generated') \
            or notexists('release'):
        raise ValueError(("The four directories tools, generated, release and "
        "crafted have  to exist below\n    FREEDICTDIR=%s") % localpath)
    return localpath

def exec_or_fail(command):
    """If command is not None, execute command. Exit upon failure."""
    if command:
        ret = os.system(command)
        if ret:
            print("Failed to execute `%s`:" % command)
            sys.exit(ret)


def main(args):
    parser = argparse.ArgumentParser(description='FreeDict API generator')
    parser.add_argument("output_path", metavar="PATH_TO_XML", type=str, nargs=1,
            help='output path to the FreeDict API XML file')
    parser.add_argument('-p', "--pre-exec-script", dest="prexec", metavar="PATH",
            help=('script/command to execute before this script, e.g. to set up a sshfs '
                'connection to a remote server, or to invoke rsync.'))
    parser.add_argument('-o', "--post-exec-script", dest="postexc", metavar="PATH",
            help=("script/command to execute after this script is done, e.g. to "
                "umount mounted volumes."))

    config = parser.parse_args(args[1:])

    exec_or_fail(config.prexec) # mount / synchronize release files
    freedictdir = find_freedictdir()
    dictionaries = []
    for dict_source in ['crafted', 'generated']:
        print("Parsing meta data for all dictionaries in", pathjoin(freedictdir,
            dict_source))
        dictionaries.extend(metadata.get_meta_from_xml(pathjoin(freedictdir,
                dict_source)))

    print("Parsing release information from", pathjoin(freedictdir, 'release'))
    release_files = releases.get_all_downloads(pathjoin(freedictdir, 'release'))
    for dict in dictionaries:
        name = dict.get_name()
        if not name in release_files:
            print("Skipping %s, no releases found." % name)
            continue
        try:
            version = releases.get_latest_version(release_files[name])
        except releases.ReleaseError as e: # add file name to error
            raise releases.ReleaseError(list(e.args) + [name])
        for full_file, format in release_files[name][version]:
            dict.add_download(dictionary.mklink(full_file, format, version))

    # remove dictionaries without download links
    dictionaries = list(d for d in dictionaries if d.get_downloads() != [])
    dictionaries.sort(key=lambda entry: entry.get_name())
    xmlhandlers.write_freedict_database(config.output_path[0], dictionaries)

    # if the files had been mounted with sshfs, it's a good idea to give it some
    # time to synchronize its state, otherwise umounting fails
    time.sleep(1.3)
    exec_or_fail(config.postexc) # umount or rsync files, if required

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

