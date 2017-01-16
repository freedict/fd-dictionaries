Freedict SETUP — fsetup
=========================

Fsetup is designed to set up the environment for managing and releasing FreeDict
dictionaries and the API.

This step is necessary, because some of the files do not exist locally, but are
only available on a remote server.

Dependencies
------------

This script required python > 3.4. Depending on the configure file access
method, either rsync or sshfs is required, too. It is adviced to install and
configure sshfs, if a decent internet connection is available. If you run Debian
or Ubuntu, execute:

    apt-get install python3 sshfs

Configuration
-------------

This utility requires a configuration file with a few options set. Open the file
`$FREEDICTDIR/config.ini` in your favourite editor and enter something like
this:

    [DEFAULT]
    file_access_with = sshfs
    [release]
    user=SFACCOUNT,freedict
    [generated]
    user=USER

-   `file_access_with`: sets the file access strategy; possible values are rsync
    or sshfs, default is rsync
-   `[release]`: server on which to look for the released dictionaries, that's
    sourceforge at the moment; `,freedict` has to be part of the user name
-   `[generated]`: this configures account information for the file services
    containing all auto-generated dictionaries

This minimal configuration should be enough for most of the use cases. For a
fully commented version, please have a look into the file
[configuration.ini.example](configuration.ini.example).

Explanation of the FreeDict root
--------------------------------

ToDo: migrate this to the Wiki

The FreeDict root has to look like this:

    somedir/
        crafted/
        generated/
        release/
        tools/

The environment variable FREEDICTDIR has to point to `somedir`. The directory
crafted should contain the repository from
<https://github.com/freedict/fd-dictionaries>.

