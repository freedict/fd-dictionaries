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
    2.   current directory is tools, crafted or generated or releases, then take parent
    3.  -   return directory upon success
        -   raise FileNotFoundError if nothing found.
        -   raise ValueError, if crafted, generated, releases and tools could not be found
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
            or notexists('releases'):
        raise ValueError(("The four directories tools, generated, releases and "
        "crafted have  to exist below\n    FREEDICTDIR=%s") % localpath)
    return localpath

def main(args):
    parser = argparse.ArgumentParser(description='Short sample app')
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

    freedictdir = find_freedictdir()
    print("parsing meta data for all dictionaries")
    dictionaries = metadata.get_meta_from_xml(pathjoin(freedictdir, "crafted"))
    dictionaries.extend(metadata.get_meta_from_xml(pathjoin(freedictdir, "generated")))

    print("parsing release information...")
    release_files = releases.get_all_downloads(pathjoin(freedictdir, 'releases'))
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
