# The line below is really just a fallback and only works if you have got a copy of the tools directory at this location. It's better to set the environment variable in your shell.
FREEDICT_TOOLS ?= ../../tools
DISTFILES = AUTHORS ChangeLog COPYING spa-eng.tei INSTALL Makefile NEWS README \
         freedict-P5.dtd freedict-P5.rng freedict-P5.xml freedict-dictionary.css
supported_phonetics=
include $(FREEDICT_TOOLS)/mk/dicts.mk
#include $(toolsdir)/ergane/Makefile.inc

#$(dictname)-nophon.tei: $(dictname).tei.header

# for teidiff: checkout an old revision
#old/$(dictname).tei:
#	cvs -z3 checkout -d old -D 2006-01-01 $(dictname)/$(dictname).tei

#old = old/$(dictname).tei

