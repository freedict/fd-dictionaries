FREEDICTDIR ?= ..
hedir ?= $(FREEDICTDIR)/hun-eng
VPATH += $(hedir)
include $(hedir)/Makefile
DISTFILES = eng-hun.tei Makefile ChangeLog

eng-hun-nophon.tei: eng-hun.tei.header SZOTAR.DBF szotar-dbf2tei.pl
ifeq ($(dbview_in_path),)
	@echo "To get the data out of the dBase database, we require the tool"
	@echo "\`dbview' from Martin Schulze aka Joey."
	@echo "Try to get it from http://packages.debian.org/stable/misc/dbview"
	@false
else
	cp $< $@
	$(hedir)/szotar-dbf2tei.pl -v --reverse >> $@
endif

