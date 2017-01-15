# ToDo: usage of script right here
# explain search for directories
# have a look at extractdata.pl

import argparse
import os
from os.path import join as pathjoin
import sys

import dictionary
import metadata
import releases
import xmlhandlers



def find_freedictdir():
    """Find FreeDict path:
    1.   FREEDICTDIR is set, take that
    2.   current directory is tools, crafted, generated or release, then take parent
    3.  -   return directory upon success
        -   raise FileNotFoundError if nothing found.
        -   raise ValueError, if crafted, generated, release and tools could not be found
            in FREEDICTDIR"""
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

def main(args):
    parser = argparse.ArgumentParser(description='FreeDict API generator')
    parser.add_argument("output_path", metavar="PATH_TO_XML", type=str, nargs=1,
            help='output path to the FreeDict API XML file')
    parser.add_argument('-s', "--script", dest="script", metavar="PATH", 
            help=('script to execute before this script, e.g. to set up a sshfs '
                'connection to a remote server, or to invoke rsync.'))

    config = parser.parse_args(args[1:])

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
        except releases.ReleaseError as e:
            # ToDo: nicer handling
            raise releases.ReleaseError(list(e.args) + [name])
        for full_file, format in release_files[name][version]:
            dict.add_download(dictionary.mklink(full_file, format, version))

    # remove dictionaries without download links
    dictionaries = list(d for d in dictionaries if d.get_downloads() != [])
    dictionaries.sort(key=lambda entry: entry.get_name())
    xmlhandlers.write_freedict_database(config.outputpath, dictionaries)

#pylint: disable=broad-except
try:
    main(sys.argv)
except Exception as e:
    if 'DEBUG' not in os.environ:
        print(str(e))
        print(("\nNote: Rerun the script with the environment variable DEBUG=1 "
            "to obtain a traceback."))
        sys.exit(9)
    else:
        raise e
