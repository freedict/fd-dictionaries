FREEDICTDIR ?= ..
DISTFILES = german-turkish.txt Makefile deu-tur.tei.header
include $(FREEDICTDIR)/tools/Makefile.common

$(dictname).tei: german-turkish.txt $(dictname).tei.header \
	$(FREEDICTDIR)/tools/xdf2tei.pl
	cat deu-tur.tei.header >$@
	$(FREEDICTDIR)/tools/xdf2tei.pl <$< >>$@
	echo "</body></text></TEI.2>" >>$@

clean::
	-rm $(dictname).tei
