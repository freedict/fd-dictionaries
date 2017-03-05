# The line below is really just a fallback and only works if you have got a copy of the tools directory at this location. It's better to set the environment variable in your shell.
FREEDICT_TOOLS ?= ../../tools
DISTFILES = COPYING Makefile README ChangeLog AUTHORS \
	 English-Hindi-Dictionary_2.isc INSTALL NEWS \
	 ehconv.yy eng-hin.tei eng-hin.tei.header  \
   freedict-P5.dtd freedict-P5.rng freedict-P5.xml freedict-dictionary.css
TEI2DICTFLAGS = -a
supported_phonetics=
include $(FREEDICT_TOOLS)/mk/dicts.mk
UNSUPPORTED_PLATFORMS = evolutionary bedic

# these are eng-hin specific targets
#ehconv.c: ehconv.yy
#	flex -oehconv.c ehconv.yy

#ehconv: ehconv.c
#	gcc ehconv.c -lfl -oehconv

#eng-hin-nophon.tei: eng-hin.tei.header ehconv English-Hindi-Dictionary_2.isc
#	cp eng-hin.tei.header $@
#	./ehconv <English-Hindi-Dictionary_2.isc >>$@

#clean::
#	rm -f ehconv.c eng-hin.tei eng-hin-nophon.tei ehconv

