# The line below is really just a fallback and only works if you have got a copy of the tools directory at this location. It's better to set the environment variable in your shell.
FREEDICT_TOOLS ?= ../../tools
DISTFILES = COPYING eng-ara.tei Makefile README ChangeLog \
INSTALL freedict-P5.dtd freedict-P5.rng freedict-P5.xml freedict-dictionary.css
supported_phonetics=
include $(FREEDICT_TOOLS)/mk/dicts.mk
UNSUPPORTED_PLATFORMS = evolutionary

#clean::
#	rm -f ara-eng.c5 ara-eng.c5.index ara-eng.c5.dict
#	rm -f eng-ara.c5 eng-ara.c5.index eng-ara.c5.dict
#	rm -f *.dz *.bz2 eng-ara.tei

