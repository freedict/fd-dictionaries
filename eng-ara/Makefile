
VERSION = 0.0.2
FREEDICTDIR = ..
TOOLSDIR = $(FREEDICTDIR)/tools
TEI2DICT = $(TOOLSDIR)/xmltei2xmldict.pl
PWD = $(shell pwd)
LANGUAGE = $(shell basename $(PWD))

# name of reverse index
RLANGUAGE = ara-eng

# where built files should get installed
DESTDIR = /usr/share/dictd

# the file xml.soc file comes with sp/opensp/openjade
# and is required by nsgmls
XMLSOC = /usr/share/sgml/opensp/xml.soc

# how to use the one already set in envoronment?
# maybe only add these to exiting path?
CATALOGS = /var/lib/sgml/CATALOG.tei_4xml:/var/lib/sgml/CATALOG.iso_ent

%.dict %.index: %.tei
	export SGML_CATALOG_FILES="$(XMLSOC):$(CATALOGS)";\
	$(TEI2DICT) -s -f $< -t $(TOOLSDIR)/xsl/tei2txt.xsl

%.dict.dz: %.dict
	dictzip -k $*.dict

%.tar.gz: %.dict.dz %.index
	tar czf $*.tar.gz $*.dict.dz $*.index

%.tar.bz2: %.dict.dz %.index
	tar cjf $*.tar.bz2 $*.dict.dz $*.index

.PHONY: all dirs tgzrelease bz2release install uninstall commit test clean dist

all:	$(LANGUAGE).dict.dz $(LANGUAGE).index	

dirs:
	if [ ! -d $(FREEDICTDIR)/tgz ]; then  mkdir $(FREEDICTDIR)/tgz; fi
	if [ ! -d $(FREEDICTDIR)/bz2 ]; then  mkdir $(FREEDICTDIR)/bz2; fi

tgzrelease: $(LANGUAGE).tar.gz dirs
	cp $(LANGUAGE).tar.gz $(FREEDICTDIR)/tgz

bz2release: $(LANGUAGE).tar.bz2 dirs
	cp $(LANGUAGE).tar.bz2 $(FREEDICTDIR)/bz2

install: $(LANGUAGE).dict.dz $(LANGUAGE).index
	install -d $(DESTDIR)
	install -m 644 $^ $(DESTDIR)
	if [ -x /usr/sbin/dictdconfig ]; then /usr/sbin/dictdconfig -w; fi

uninstall: 
	-rm $(DESTDIR)/$(LANGUAGE).dict.dz $(DESTDIR)/$(LANGUAGE).index
	if [ -x /usr/sbin/dictdconfig ]; then /usr/sbin/dictdconfig -w; fi

commit: 
	cvs -z3 commit

test:
	test -e $(XMLSOC) || (echo "Please set path to xml.soc file!"; exit 1)
	export SP_ENCODING=XML ;\
	export SP_CHARSET_FIXED=YES ;\
	export SGML_CATALOG_FILES="$(XMLSOC):$(CATALOGS)" ;\
	nsgmls -s -E 10 $(LANGUAGE).tei

clean:
	-rm $(LANGUAGE).index
	-rm $(LANGUAGE).dict
	-rm $(LANGUAGE).dict.dz
	-rm $(FREEDICTDIR)/bz2/$(LANGUAGE).tar.bz2
	-rm $(FREEDICTDIR)/tgz/$(LANGUAGE).tar.gz

dist: clean
	(cd ..; tar -cvjf $(LANGUAGE)/freedict-$(LANGUAGE)-$(VERSION).tar.bz2 \
--exclude=CVS --exclude=freedict-*.tar.bz2 --exclude=.* $(LANGUAGE))

reverse: $(LANGUAGE).tei
	export SGML_CATALOG_FILES="$(XMLSOC):$(CATALOGS)";\
	$(TEI2DICT) -u -s -f $< -r -t $(TOOLSDIR)/xsl/tei2txt.xsl
	mv $(LANGUAGE).index $(RLANGUAGE).index
	mv $(LANGUAGE).dict $(RLANGUAGE).dict
	dictzip -k $(RLANGUAGE).dict
