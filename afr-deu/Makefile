
.SUFFIXES: .tar.gz .tei .tei.gz .dict .dic.dz .dz .vok .dic .fo .pdf .ipk

TOOLS = ../tools/
ADDFREEDICT = $(TOOLS)add-freedict.sh
TEI2ZBDIC = $(TOOLS)tei2zbdic.py
WEBSTERDIR = /usr/local/bin/
DICTFMT = dictfmt
XEROX   = /usr/local/bin/xerox
DICT2VOK = $(TOOLS)dict2evolutionary.pl
#XSLPROCESSOR = sabcmd
XSLPROCESSOR = xsltproc
XSLT = $(TOOLS)tei2txt.xsl
TEIFO = /usr/src/packages/theater/teixsl/fo/tei.xsl
DIC2IPK = $(TOOLS)zbedic2zaurus.sh

VPATH = ../tools:../dicts:../dicts/bin

include Makefile.language
include $(TOOLS)Makefile.config

.tei.dict:
	$(XSLPROCESSOR) $(XSLT) $*.tei | \
	$(DICTFMT) --locale $(LOCALE) -c5 --without-headword  $* 
	if [ ! -d ../dicts ]; then  mkdir ../dicts; fi
	mv -f $*.dict ../dicts/$*.dict
	mv -f $*.index ../dicts/$*.index

.tei.dic:
	echo Make dic 
	$(TEI2ZBDIC) $*.tei ../dicts/$*1.dic
	$(XEROX) -d ../dicts/$*1.dic ../dicts/$*.dic
	rm -f ../dicts/$*1.dic

.dic.dz.ipk:
	echo Make ipk
	(cd ../dicts; ln -s  `$(DIC2IPK) $*.dic.dz` $*.ipk )


.dic.dic.dz:
	echo zip dic 
	dictzip ../dicts/$*.dic

.tei.tei.gz:
	echo gzip tei
	cp $*.tei ../dicts/
	gzip ../dicts/$*.tei

.dict.dz:
	dictzip -k ../dicts/$*.dict

.dz.tar.gz:
	if [ ! -d ../dicts ]; then mkdir ../dicts/bin; fi
	(cd ../dicts/ ; tar czvf bin/$*.tar.gz $*.dict.dz $*.index)

.dict.vok:
	$(DICT2VOK) < ../dicts/$*.dict |\
	recode -f u8..cp1252 > ../dicts/$*.vok;

.fo.pdf:
	pdfxmltex $*.fo

.tei.fo:
	$(XSLPROCESSOR) -o $*.fo $(TEIFO) $*.tei

all:	\
	$(LANGUAGE).tar.gz \
	$(LANGUAGE).dic.dz \
	$(LANGUAGE).tei.gz

vok:	\
	$(LANGUAGE).vok

ipk:	\
	$(LANGUAGE).ipk

install: all
	echo Hier
	cd ../dicts && \
	pwd; \
	$(ADDFREEDICT) --remove $(LANGUAGE); \
	$(ADDFREEDICT) --install $(LANGUAGE); \
	cd ../$(LANGUAGE); 

uninstall: 
	cd ../dicts
	$(ADDFREEDICT) --remove $(LANGUAGE) 
	cd ../$(LANGUAGE)

commit: 
	cvs -z3 commit

test:
	nsgmls -s $(LANGUAGE).tei

