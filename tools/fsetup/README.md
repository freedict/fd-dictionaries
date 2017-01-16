Freedict SETUP — fsetup
-------------------------

Fsetup is designed to set up the environment for managing and releasing FreeDict
dictionaries.

The FreeDict root has to look like this:

    somedir/
        crafted/
        generated/
        release/
        tools/

The environment variable FREEDICTDIR has to point to `somedir`. The directory
crafted should contain the repository from
<https://github.com/freedict/fd-dictionaries>.

The script will take care of populating the other directories, either using
rsync or sshfs.

ToDo: document configuration
