FREEDICTDIR ?= ..
DISTFILES = ChangeLog eng-tur.tei Makefile README
include $(FREEDICTDIR)/tools/Makefile.common

eng-tur.tei:
	cat eng-tur.tei.header > eng-tur.tei
	./eng-tur2tei.pl >>eng-tur.tei
	cat general.footer >>eng-tur.tei

