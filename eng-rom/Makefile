FREEDICTDIR ?= ..
DISTFILES = AUTHORS ChangeLog COPYING eng-rom.tei INSTALL Makefile NEWS README \
eng-rom.tei.header eng-rom.text romtext2tei.pl
include $(FREEDICTDIR)/tools/Makefile.common

clean::
	-rm eng-rom.tei

eng-rom.tei: eng-rom.tei.header
	./romtext2tei.pl <eng-rom.text >eng-rom.tei
