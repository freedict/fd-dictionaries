FREEDICTDIR ?= ..
DISTFILES = ChangeLog English-Czech.xdf Makefile \
	eng-cze.tei.header general.footer
include $(FREEDICTDIR)/tools/Makefile.common

eng-cze-nophon.tei: $(toolsdir)/xdf2tei.pl eng-cze.tei.header general.footer
	cat eng-cze.tei.header >$@
	$(toolsdir)/xdf2tei.pl <English-Czech.xdf >>$@
	cat general.footer >>$@

clean::
	rm -f eng-cze.tei eng-cze-nophon.tei
