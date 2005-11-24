FREEDICTDIR ?= ..
DISTFILES = hun-eng.tei Makefile ChangeLog README SZOTAR.ZIP hun-eng.tei.header szotar-dbf2tei.pl
include $(FREEDICTDIR)/tools/Makefile.common

dbview_in_path := $(shell which dbview 2>/dev/null)

hun-eng.tei: hun-eng.tei.header SZOTAR.DBF szotar-dbf2tei.pl
ifeq ($(dbview_in_path),)
	@echo "To get the data out of the dBase database, we require the tool"
	@echo "\`dbview' from Martin Schulze aka Joey."
	@echo "Try to get it from http://packages.debian.org/stable/misc/dbview"
	false
else 
	@if [ ! -f SZOTAR.DBF ]; then unzip SZOTAR.ZIP SZOTAR.DBF; fi
	./szotar-dbf2tei.pl
endif

SZOTAR.DBF: SZOTAR.ZIP

clean::
	-rm SZOTAR.DBF
