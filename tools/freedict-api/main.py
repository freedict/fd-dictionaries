# ToDo: usage of script right here
# explain search for directories
# have a look at extractdata.pl

import argparse
import os
import re
import sys

import dictionary
import metadata
import releases
import xmlhandlers



def find_freedictdir():
    """Find FreeDict path:
    1.   FREEDICTDIR is set, take that
    2.   current directory is tools and above are dictionaries, take parent
    3.   check whether current directory contains dictionaries, take it
    4.   raise FileNotFoundError if nothing found."""
    localpath = None
    if 'FREEDICTDIR' in os.environ:
        if os.path.exists(os.environ['FREEDICTDIR']):
            localpath = os.environ['FREEDICTDIR']
        else:
            raise ValueError("Path specified in $FREEDICTDIR does not exist.")
    else: # check whether current directory contains dictionaries
        # is cwd == 'tools':
        directory = ('..' if os.path.basename(os.getcwd()) == 'tools' else '.')
        match = re.compile('^[a-z]{3}-[a-z]{3}')
        # does `directory` contain files?
        # any files with our dictionary naming conventions?
        if any(match.search(f) for f in os.listdir(directory)):
            localpath = directory
    if localpath is None:
        raise ValueError("path to FreeDictDir not set.")
    else:
        return localpath

def main(args):
    parser = argparse.ArgumentParser(description='Short sample app')
    parser.add_argument('-f', "--freedict-dir", action="store",
            dest="freedictdir",
            help='set FREEDICTDIR')
    parser.add_argument('-o', "--output", action="store", dest="outputpath",
            default='freedict-database.xml',
            help='output path for the resulting XML freedict database')
    parser.add_argument('-l', "--local-only", action="store_true", dest="l",
            default='False',
            help='do NOT connect to any server, perform all actions locally.')
    parser.add_argument('-r', "--local-rsync", action="store", dest="r",
            default="False",
            help='do everything locally, except for releases where rsync is used')

    config = parser.parse_args(args[1:])

    freedictdir = (config.freedictdir if config.freedictdir else find_freedictdir())
    print("parsing meta data for all dictionaries")
    dictionaries = metadata.get_meta_from_xml(freedictdir)

    print("parsing release information...")
    # ToDo: properly figure out where the freedict release files are
    release_files = releases.get_all_downloads(os.path.join(freedictdir,
        'frs/freedict'))
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

main(sys.argv)
