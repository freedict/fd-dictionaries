FREEDICTDIR ?= ..
DISTFILES = ChangeLog eng-cze.tei Makefile eng-cze.tei.header general.footer
include $(FREEDICTDIR)/tools/Makefile.common

eng-cze.tei: $(toolsdir)/xdf2tei.pl eng-cze.tei.header general.footer
	cat eng-cze.tei.header >eng-cze.tei
	$(toolsdir)/xdf2tei.pl <English-Czech.xdf >>eng-cze.tei
	cat general.footer >>eng-cze.tei

clean::
	-rm eng-cze.tei
