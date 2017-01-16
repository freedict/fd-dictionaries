#!/usr/bin/env python3
import argparse
import configparser
import io
import os
import sys

def execute(cmd, raise_on_error=False):
    ret = os.system(cmd)
    if ret:
        print('Subcommand failed with exit code', ret)
        print('Command:',cmd)
        if raise_on_error:
            raise OSError()
        else:
            sys.exit(ret)

class RsyncFileAccess:
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


def load_configuration(freedictdir):
    """load given `config` from given freedictdir. Default values are assumed
    for values which weren't given."""
    config = configparser.ConfigParser()
    config['DEFAULT'] = {
            'file_access_via': 'sshfs'} # only rsync and sshfs are allowed
    config['generated'] = {}
    config['generated']['server'] = 'www.wikdict.com'
    config['generated']['remote_path'] = '/home/freedict/lf-dictionaries'
    config['generated']['user'] = 'anonymous'
    config['release'] = {}
    config['release']['server'] = 'frs.sf.net'
    config['release']['remote_path'] = '/home/pfs/project/freedict'
    config['release']['user'] = 'anonymous'

    # overwrite defaults with user settings
    with open(os.path.join(freedictdir, 'config.ini')) as configfile:
        config.read_file(configfile)

    if config['DEFAULT']['file_access_via'] not in ['sshfs', 'rsync']:
        raise ValueError(('section=DEFAULT, file_access_via="%s": invalid value,'
            ' possible values are sshfs and rsync' % config['DEFAULT']['file_access_via']))
    return config

def setup():
    """Find freedict directory and parse command line arguments. Return a tuple
    with the freedict directory and the configuration object."""
    if not 'FREEDICTDIR' in os.environ:
        print("Error: environment variable FREEDICT unset, but it is required.")
        sys.exit(40)
    # parse command line options
    parser = argparse.ArgumentParser(description='FreeDict build setup utility')
    parser.add_argument('-m', dest="make_available", action='store_true',
            help='make files in generated/ and release/ available; this will use internally either sshfs or rsync, depending on the configuration')
    parser.add_argument('-u', dest='umount', action='store_true',
        help='clean up actions for release/ and generated/, e.g. umount of fuse mount points, etc.')
    args = parser.parse_args()

    # check for contradicting options
    if args.umount and args.make_available:
        print("Error: you can only specify -u or -m exclusively.")
        sys.exit(44)

    return (os.environ['FREEDICTDIR'], args)


def main():
    (freedictdir, args) = setup()
    try:
        config = load_configuration(freedictdir)
    except io.UnsupportedOperation:
        print("Could not read from %s" % os.path.join(freedictdir, 'config.ini'))
        print("Please check that the file exists and is readable.")
        sys.exit(1)
    except ValueError as e:
        print(e)
        sys.exit(42)

    access_method = RsyncFileAccess()
    if config['DEFAULT']['file_access_with'] == 'sshfs':
        access_method = SshfsAccess()

    release_directory = os.path.join(freedictdir, 'release')
    if not os.path.exists(release_directory):
        try:
            os.makedirs(release_directory)
        except OSError:
            # if the file does exist, but the fuse endpoint is _not_ connected,
            # we could try running fusermount -u:
            os.system('fusermount -u "%s"' % release_directory)

    if args.make_available:
        for section in (s for s in config.sections() if s):
            print("Making files for `%s` available" % section)
            options = config[section]
            target_path = os.path.join(freedictdir, section)
            access_method.make_avalailable(options['user'], options['server'],
                options['remote_path'], target_path)
    elif args.umount:
        for section in (s for s in config.sections() if s):
            target_path = os.path.join(freedictdir, section)
            try:
                access_method.make_unavailable(target_path)
            except OSError:
                continue

main()
