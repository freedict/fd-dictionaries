FREEDICTDIR ?= ../../
DISTFILES = COPYING Makefile README ChangeLog AUTHORS \
	 English-Hindi-Dictionary_2.isc INSTALL NEWS \
	 ehconv.yy eng-hin.tei eng-hin.tei.header  \
   freedict-P5.dtd freedict-P5.rng freedict-P5.xml freedict-dictionary.css
TEI2DICTFLAGS = -a
supported_phonetics=
include $(FREEDICTDIR)/tools/Makefile.common
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

