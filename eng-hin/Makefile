FREEDICTDIR ?= ..
DISTFILES = COPYING Makefile README ChangeLog AUTHORS \
	 English-Hindi-Dictionary_2.isc INSTALL NEWS \
	 ehconv.yy eng-hin.tei.header
TEI2DICTFLAGS = -a
include $(FREEDICTDIR)/tools/Makefile.common

# these are eng-hin specific targets
ehconv.c: ehconv.yy
	flex -oehconv.c ehconv.yy

ehconv: ehconv.c
	gcc ehconv.c -lfl -oehconv

eng-hin.tei.end: ehconv English-Hindi-Dictionary_2.isc
	./ehconv <English-Hindi-Dictionary_2.isc >eng-hin.tei.end

eng-hin.tei: eng-hin.tei.header eng-hin.tei.end
	cat eng-hin.tei.header eng-hin.tei.end >eng-hin.tei

clean::
	-rm -f ehconv.c eng-hin.index eng-hin.dict eng-hin.tei \
	eng-hin.tei.end ehconv

