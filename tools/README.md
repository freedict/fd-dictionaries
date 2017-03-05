FreeDict Tools
===============

The FreeDict tools are used to import, export and mange FreeDict dictionaries.
Most of the documentation can be found in the FreeDict HOWTO at

    https://github.com/freedict/fd-dictionaries/wiki/FreeDict-HOWTO

In general, it is a good idea to have a look at our wiki at
    
    https://github.com/freedict/fd-dictionaries/wiki

Getting Started
---------------

The following lines may get you started on some requirements:

FreeDict databases are encoded in the TEI XML format (chapter 9), see
<http://www.tei-c.org/release/doc/tei-p5-doc/en/html/DI.html>.

The conversion is based on XSL stylesheets (see directory `xsl/`). These can in
principle transform to any format, but only the .dict format is supported at the
moment.

You should have at least the following tools installed, to build the
dictionaries: make, xsltproc, tar, gzip, dictzip, dictfmt

For proper use of all our tools, Perl, Python > 3.4, Git and a XML-capable
editor are strongly advised.

If you find a `Makefile` in a directory, you can be sure that `make help` will
assist you in what you can do with it. The help screen will also inform you how
to build dictionary releases. Furthermore, the whole build system is explained
in chapter 8 of the HOWTO, mentioned earlier.

If you read this file, because you want to figure out how to build a dictionary,
please have a look at a dictionary from
<https://github.com/freedict/fd-dictionaries) and run make in one of the various
dictionary directories.

Debian/Ubuntu Dependencies
--------------------------

If you use Debian/Ubuntu, you should install the following packages:

    sudo apt-get install make unzip xsltproc libxml-libxml-perl python3

Also, teiaddphonetics requires XML::LibXML::Reader, which is not even
in libxml-libxml-perl in unstable, so you need to do as root:

	cpan XML::LibXML


Sebastian Humenda, March 2017

