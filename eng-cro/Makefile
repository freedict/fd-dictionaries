
.SUFFIXES: .tar.gz .tei .dict .dz

TOOLS = ../tools/
TEI2DICT = $(TOOLS)xmltei2xmldict.pl
ADDFREEDICT = $(TOOLS)add-freedict.sh
VERSION = 0.0.1

PWD = $(shell pwd)
LANGUAGE = $(shell basename $(PWD))

SGML_CATALOG_FILES = "/usr/share/sgml/opensp/xml.soc:/usr/share/doc/packages/sp/html-xml/xml.soc:/var/lib/sgml/CATALOG.tei_4xml:/var/lib/sgml/CATALOG.xmlcharent"

.tei.dict:
	(export SGML_CATALOG_FILES=$(SGML_CATALOG_FILES);\
	$(TEI2DICT) -f $*.tei -s -t ../tools/xsl/tei2txt.xsl)
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
	$(TEI2DICT) -f $(LANGUAGE).tei -t ../tools/xsl/tei2txt.xsl -r)
	mv $(RLANGUAGE).dict ../dicts/$(RLANGUAGE).dict
	mv $(RLANGUAGE).index ../dicts/$(RLANGUAGE).index

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
	$(TOOLS)testing/test-database.pl -f ../dicts/$(LANGUAGE)

clean:
	rm -f $(LANGUAGE).dict $(LANGUAGE).index
	rm -f ../dicts/$(LANGUAGE){.index,.dict,.dict.dz}
	rm -f ../dicts/bin/$(LANGUAGE).tar.gz

dist:
	tar cvjf $(LANGUAGE)-$(VERSION).src.bz2 cro-eng.tei Makefile README

