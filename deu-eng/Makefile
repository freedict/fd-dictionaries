
.SUFFIXES: .tar.gz .tei .dict .dz

TOOLS = ../tools/
TEI2DICT = $(TOOLS)tei2dict_xml.pl
ADDFREEDICT = $(TOOLS)add-freedict.sh

VPATH = ../tools:../dicts:../dicts/bin

#include Makefile.language
PWD = $(shell pwd)
LANGUAGE = $(shell basename $(PWD))


.tei.dict:
	$(TEI2DICT) -f $*.tei
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


install: all\
	$(ADDFREEDICT) --remove $*
	$(ADDFREEDICT) --install $*

commit: 
	cvs -z3 commit

test:
	nsgmls -s $(LANGUAGE).tei
