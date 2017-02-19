# The line below is really just a fallback and only works if you have got a copy of the tools directory at this location. It's better to set the environment variable in your shell.
FREEDICT_TOOLS ?= ../../tools
DISTFILES = AUTHORS ChangeLog COPYING eng-deu.tei INSTALL Makefile NEWS README \
freedict-P5.dtd freedict-P5.rng freedict-P5.xml freedict-dictionary.css
# Clear this variable, because currently the .tei file already contains
# phonetics information.  This will have to be removed, when proper import from
# upstream is implemented.
supported_phonetics =

include $(FREEDICT_TOOLS)/Makefile.common
