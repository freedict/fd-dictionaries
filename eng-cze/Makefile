FREEDICTDIR ?= ../../CVS
DISTFILES = ChangeLog eng-cze.tei Makefile
include $(FREEDICTDIR)/tools/Makefile.common

eng-cze.tei:
	cat eng-cze.tei.header >eng-cze.tei
	$(FREEDICTDIR)/tools/xdf2tei.pl <English-Czech.xdf >>eng-cze.tei
	cat general.footer >>eng-cze.tei

clean::
	-rm eng-cze.tei
