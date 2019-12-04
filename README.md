FreeDict - free bilingual dictionaries
=======================================

The FreeDict project aims at providing free (open source) dictionary databases,
to be used both by humans and machines.
The official home is at <http://freedict.org>, where you can find documentation
for dictionary usage and development.

Dictionary Sources
-------

This repository only contains dictionaries which are *not* auto-imported, so
which were converted once or written by hand. If you are searching for *all*
dictionary sources, you should instead go to <https://freedict.org/downloads>,
where you find the latest source releases of all dictionaries.
Auto-imported dictionaries can also be found at
<https://download.freedict.org/generated>.

Development
-----------

All dictionaries are encoded in [TEI (version 5)][tei_v5] which is a
flexible XML format to encode human speech. The FreeDict project
provides dictionaries but also style sheets to convert the TEI
databases into human-readable formats.

At the moment, the [dict format][dict] and the [SLOB format][slob] are
supported.

The development documentation is in our wiki at
<https://github.com/freedict/fd-dictionaries/wiki>.

Installation
------------

You can install precompiled dictionaries on GNU/Linux distributions like Debian
(and all derived distributions as Ubuntu, Mint, etc.) and Arch Linux. Please
have a look at your package manager.

If you still want to build from source and you don't want to read the wiki,
here's a really quick getting started guide:

-   Get <https://github.com/freedict/tools>, clone it to a path without spaces
    and set an environment variable called `FREEDICT_TOOLS` pointing there.
-   Change to your dictionary, try `make help`. For building `make` should be
    enough, at least if you have both tei2slob and xsltproc installed. It's also
    possible to disable some of the output formats, ask our friendly buildsystem
    for help: `make help`.


  [dict]: https://en.wikipedia.org/wiki/DICT
  [slob]: https://github.com/itkach/slob/wiki/Dictionaries
  [tei_v5]: https://en.wikipedia.org/wiki/Text_Encoding_Initiative
