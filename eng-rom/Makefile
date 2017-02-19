# The line below is really just a fallback and only works if you have got a copy of the tools directory at this location. It's better to set the environment variable in your shell.
FREEDICT_TOOLS ?= ../../tools
DISTFILES = AUTHORS ChangeLog COPYING INSTALL Makefile NEWS README \
eng-rom.tei eng-rom.tei.header README ChangeLog eng-rom.text romtext2tei.pl \
freedict-P5.dtd freedict-P5.rng freedict-P5.xml freedict-dictionary.css
supported_phonetics=
include $(FREEDICT_TOOLS)/Makefile.common
#clean::
#	rm -f eng-rom-nophon.tei eng-rom.tei

#eng-rom-nophon.tei: eng-rom.text eng-rom.tei.header
#	./romtext2tei.pl < $< > $@

