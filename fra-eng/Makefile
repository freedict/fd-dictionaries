FREEDICTDIR ?= ..
DISTFILES = AUTHORS ChangeLog COPYING fra-eng.tei.header \
	    INSTALL Makefile NEWS README
include $(FREEDICTDIR)/tools/Makefile.common
include $(toolsdir)/ergane/Makefile.inc

$(dictname)-nophon.tei: $(dictname).tei.header

# for teidiff testing: checkout an old revision
old/$(dictname).tei:
	cvs -z3 checkout -d old -D 2006-01-01 $(dictname)/$(dictname).tei

old = old/$(dictname).tei

