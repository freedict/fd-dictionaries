FREEDICTDIR ?= ..
DISTFILES = ChangeLog eng-tur.tei.header ingtur-ing.utf8 \
	    ingtur-tur.utf8 eng-tur2tei.pl general.footer Makefile README
include $(FREEDICTDIR)/tools/Makefile.common

eng-tur-nophon.tei: eng-tur.tei.header ingtur-ing.utf8 \
  ingtur-tur.utf8 eng-tur2tei.pl general.footer
	cat eng-tur.tei.header >$@
	./eng-tur2tei.pl >>$@
	cat general.footer >>$@

clean::
	rm -f eng-tur-nophon.tei eng-tur.tei

