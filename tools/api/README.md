API Generator   
==========

The scripts in this directory help to generate the FreeDict API. On information
what the API is and what it looks like, have a look at <https://github.com/freedict/fd-dictionaries/wiki/FreeDict-API>.

The API generation consists of two steps. In the first step, remote files are
made available, in the second, the actual XML file is generated.

Remote files are all released files and the auto-imported dictionaries. In order
to make them available, either SSHFS or RSYNC can be used. This can be
configured in the FreeDict configuration, see <ToDo, Chapter 9 of HOWTO>. The
`file_manager` will take care of doing this work, transparently.

The `generator` generates the actual XML file. It relies on the FREEDICT_DIR
variable to be set. Information about this variable can be found
[here](https://github.com/freedict/fd-dictionaries/wiki/FreeDict-HOWTO).\
To find out how this program works, call

    python3 generator/main.py -h

All this is already automated in the make rule `api`, so in most cases,
`make api` should be enough.

