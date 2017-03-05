# The line below is really just a fallback and only works if you have got a copy of the tools directory at this location. It's better to set the environment variable in your shell.
FREEDICT_TOOLS ?= ../../tools
DISTFILES = AUTHORS ChangeLog COPYING INSTALL Makefile NEWS README afr-deu.tei \
            freedict-P5.dtd freedict-P5.rng freedict-P5.xml freedict-dictionary.css
include $(FREEDICT_TOOLS)/mk/dicts.mk
#include $(toolsdir)/ergane/Makefile.inc

# for teidiff testing: checkout an old revision
#old/$(dictname).tei:
#	cvs -z3 checkout -d old -D 2006-01-01 $(dictname)/$(dictname).tei

#old = old/$(dictname).tei

#$(dictname).tei: $(dictname).tei.header
