FREEDICTDIR ?= ..
DISTFILES = hun-eng.tei Makefile ChangeLog README SZOTAR.ZIP hun-eng.tei.header szotar-dbf2tei.pl
include $(FREEDICTDIR)/tools/Makefile.common

hun-eng.tei: hun-eng.tei.header SZOTAR.DBF szotar-dbf2tei.pl
	@if [ ! -f SZOTAR.DBF ]; then unzip SZOTAR.ZIP SZOTAR.DBF; fi
	./szotar-dbf2tei.pl

SZOTAR.DBF: SZOTAR.ZIP

clean::
	-rm SZOTAR.DBF
