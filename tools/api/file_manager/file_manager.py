#!/usr/bin/env python3
"""This script makes remote files available for local processing. Remote files
are e.g. the released files hosted on a server as downloads or the
auto-generated dictionaries, kept outside the git repository.
This script requires a configuration. Please see the README for more details.
Running this script with the `-h` option will give an overview about its usage."""

import argparse
import os
import subprocess
import sys


sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(sys.argv[0]))))
import config


def execute(cmd, raise_on_error=False):
    """Execute a command; if the return value is != 0, the program either
    terminates or an exception is raised."""
    proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)
    text = (e.decode(sys.getdefaultencoding()) for e in proc.communicate())
    ret = proc.wait()
    if ret:
        text = '\n'.join(text).strip()
        if text.startswith('fusermount: ') and 'not found in /etc/mtab' in text:
            return # umounting something which isn't mounted is not harmful, ignore

        text = ('Subcommand failed with exit code %s\n'
                 'Command: %s\n%s\n') % (ret, cmd, text)
        if raise_on_error:
            raise OSError(text)
        else:
            print(text)
            if ret >= 255:
                ret = 1
            sys.exit(ret)

class RsyncFileAccess:
    """This class is one of two classes to allow acces to remote files using
    rsync. The drawback with rsync is that before the usage by other scripts,
    all files have to be downloaded. On the other hand, this might speed up
    subsequent runs and allows offline work. On Windows, it might be desirable
    to use rsync, because sshfs is not officially ported to Windows."""
    def name(self):
        return "rsync"

    def make_avalailable(self, user, server, remote_path, path):
        """Synchronize files to have them available locally."""
        execute("rsync -avrltD -e ssh {}@{}:/{}/ {}".format(
                user, server, remote_path, path))

    #pylint: disable=unused-argument
    def make_unavailable(self, path):
        """Don't do anything, rsync has no clean up requirements."""
        pass

class SshfsAccess:
    """This class mounts and umounts the remote files using sshfs. This will
    work on any system that fuse runs on, namely GNU/Linux, FreeBSD and Mac."""
    def name(self):
        return 'sshfs'

    def make_avalailable(self, user, server, remote_path, path):
        """Mount remote file system using sshfs."""
        if len(os.listdir('.')) == 0:
            print("Error: %s has to be empty, otherwise sshfs won't work." % path)
            sys.exit(41)
        execute('sshfs {}@{}:{} {}'.format(user, server, remote_path, path))

    def make_unavailable(self, path):
        execute('fusermount -u {}'.format(path), raise_on_error=True)



def setup():
    """Find freedict directory and parse command line arguments. Return a tuple
    with the freedict directory and the configuration object."""
    # parse command line options
    parser = argparse.ArgumentParser(description='FreeDict build setup utility')
    parser.add_argument('-a', dest="print_api_path", action='store_true',
            help="print output path for generated API file, read from local configuration")
    parser.add_argument('-m', dest="make_available", action='store_true',
            help='make files in generated/ and release/ available; this will use internally either sshfs or rsync, depending on the configuration')
    parser.add_argument('-u', dest='umount', action='store_true',
        help='clean up actions for release/ and generated/, e.g. umount of fuse mount points, etc.')
    args = parser.parse_args()

    # check for contradicting options
    if args.umount and args.make_available:
        print("Error: you can only specify -u or -m exclusively.")
        sys.exit(44)
    if not args.umount and not args.make_available and not args.print_api_path:
        print("Error: No option specified")
        parser.print_help()

    return args


def main():
    args = setup()
    try: # load configuration
        conf = config.discover_and_load()
    except config.ConfigurationError as e:
        print(e)
        sys.exit(42)

    if args.print_api_path:
        print(config.get_path(conf['DEFAULT'], key='api_output_path'))
        sys.exit(0)
    access_method = RsyncFileAccess()
    if conf['DEFAULT']['file_access_via'] == 'sshfs':
        access_method = SshfsAccess()

    release_directory = config.get_path(conf['release'])
    if not os.path.exists(release_directory):
        try:
            os.makedirs(release_directory)
        except OSError:
            # if the file does exist, but the fuse endpoint is _not_ connected,
            # we could try running fusermount -u:
            os.system('fusermount -u "%s"' % release_directory)

    if args.make_available:
        for section in ('release', 'generated'):
            if conf[section].getboolean('skip'):
                print("Skipping",section)
                continue
            print('Making files for "%s" available...' % section)
            options = conf[section]
            target_path = config.get_path(options)
            access_method.make_avalailable(options['user'], options['server'],
                options['remote_path'], target_path)
    elif args.umount:
        for section in ('generated', 'release'):
            if conf[section].getboolean('skip'):
                print("Skipping",section)
                continue
            target_path = config.get_path(conf[section])
            try:
                access_method.make_unavailable(target_path)
            except OSError as e:
                print(e.args[0])
                continue

main()
