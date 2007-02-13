FREEDICTDIR ?= ..
DISTFILES = AUTHORS ChangeLog COPYING INSTALL Makefile NEWS README \
eng-rom.tei.header eng-rom.text romtext2tei.pl
include $(FREEDICTDIR)/tools/Makefile.common

clean::
	rm -f eng-rom-nophon.tei eng-rom.tei

eng-rom-nophon.tei: eng-rom.text eng-rom.tei.header
	./romtext2tei.pl < $< > $@

