FREEDICTDIR ?= ..
DISTFILES = Deutsch-Kurdî.txt Makefile deu-kur.tei.header
include $(FREEDICTDIR)/tools/Makefile.common

$(dictname).tei: Deutsch-Kurdî.txt $(dictname).tei.header \
	$(FREEDICTDIR)/tools/xdf2tei.pl
	cat $(dictname).tei.header >$@
	$(FREEDICTDIR)/tools/xdf2tei.pl <$< >>$@
	echo "</body></text></TEI.2>" >>$@

clean::
	-rm $(dictname).tei
