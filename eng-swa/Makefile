
.SUFFIXES: .tar.gz .tei .dict .dz

PWD = $(shell pwd)
LANGUAGE = $(shell basename $(PWD))
TOOLS = ../tools/
TEI2DICT = $(TOOLS)xmltei2xmldict.pl
ADDFREEDICT = $(TOOLS)add-freedict.sh
VERSION = $(shell sabcmd $(TOOLS)xsl/getedition.xsl $(LANGUAGE).tei)


SGML_CATALOG_FILES = "/usr/share/sgml/opensp/xml.soc:/usr/share/doc/packages/sp/html-xml/xml.soc:/var/lib/sgml/CATALOG.tei_4xml:/var/lib/sgml/CATALOG.xmlcharent"

.tei.dict:
	(export SGML_CATALOG_FILES=$(SGML_CATALOG_FILES);\
	$(TEI2DICT) -f $*.tei -u -t ../tools/xsl/tei2txt.xsl)
	if [ ! -d ../dicts ]; then  mkdir ../dicts; fi
	mv $*.dict ../dicts
	mv $*.index ../dicts

.dict.dz:
	dictzip -k ../dicts/$*.dict

.dz.tar.gz:
	if [ ! -d ../dicts ]; then mkdir ../dicts/bin; fi
	(cd ../dicts/ ; tar czvf bin/$*.tar.gz $*.dict.dz $*.index)

all:	\
	$(LANGUAGE).tar.gz
reverse:
	(export SGML_CATALOG_FILES=$(SGML_CATALOG_FILES);\
	../tools/xmltei2xmldict.pl -f $(LANGUAGE).tei -t ../tools/xsl/tei2txt.xsl -r)
	mv $(LANGUAGE).dict ../dicts/$(LANGUAGE).dict
	mv $(LANGUAGE).index ../dicts/$(LANGUAGE).index

install: all\
	$(ADDFREEDICT) --remove $*
	$(ADDFREEDICT) --install $*

commit: 
	cvs -z3 commit

validate:
	(export SP_ENCODING=XML;export SP_CHARSET_FIXED=yes;\
export SGML_CATALOG_FILES=$(SGML_CATALOG_FILES);\
nsgmls -E 10 -s $(LANGUAGE).tei)

test:
	$(TOOLS)/testing/test-database.pl -f ../dicts/$(LANGUAGE) -l de_DE.utf-8
clean:
	rm -f $(LANGUAGE).dict $(LANGUAGE).index
	rm -f ../dicts/$(LANGUAGE){.index,.dict,.dict.dz}
	rm -f ../dicts/bin/$(LANGUAGE).tar.gz

dist:
	cd ..; tar cvjf $(LANGUAGE)/$(LANGUAGE)-$(VERSION).src.tar.bz2 \
$(LANGUAGE)/$(LANGUAGE).tei \
$(LANGUAGE)/Makefile \
$(LANGUAGE)/README

