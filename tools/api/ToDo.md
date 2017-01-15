-   rework command line switches, etc.
    -   don't do any action if no parameter supplied
-   new directory structure:
    -   below $FREEDICTDIR, there will be tools, generated and crafted
    -   tools will still contain tools
    -   crafted will be the git repo with all the hand-crafted dictionaries or
        those, which we have adopted to maintain (upstream is dead)
    -   generated -> all auto-generated dictionaries, for which the importers
        are in tools/importers; since they are auto-imported, they don't need to
        be in the git
    -   the releases directory should be renamed to build
    -   a potential releases directory should contain the released files
        -   such a directory would either be rsync'ed or sshfs'ed
-   write a script, which executes rsync or sshfs for the generated dictionary
    and releases/ (or build/)
    -   was in the API generator before, but doesn't belong there

old SF path: integrate USER,freedict@frs.sf.net:/home/pfs/project/freedict

