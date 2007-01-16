FREEDICTDIR ?= ..
DISTFILES = AUTHORS COPYING INSTALL NEWS lat-eng.tei.header \
	    Makefile README ChangeLog
include $(FREEDICTDIR)/tools/Makefile.common
include $(toolsdir)/ergane/Makefile.inc

$(dictname).tei: $(dictname).tei.header

# for teidiff: checkout an old revision
old/$(dictname).tei:
	cvs -z3 checkout -d old -D 2006-01-01 $(dictname)/$(dictname).tei

old = old/$(dictname).tei

