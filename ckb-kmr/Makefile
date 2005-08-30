FREEDICTDIR ?= ..
DISTFILES = sor-kur.txt Makefile ckb-kmr.tei.header
include $(FREEDICTDIR)/tools/Makefile.common

$(dictname).tei: sor-kur.txt $(dictname).tei.header \
	$(toolsdir)/xdf2tei.pl
	cat $(dictname).tei.header >$@
	$(toolsdir)/xdf2tei.pl <$< >>$@
	echo "</body></text></TEI.2>" >>$@

clean::
	-rm $(dictname).tei
