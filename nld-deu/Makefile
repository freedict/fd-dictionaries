
.SUFFIXES: .tar.gz .tei .dict .dz .vok

TOOLS = ../tools/
TEI2DICT = $(TOOLS)tei2dict.pl
ADDFREEDICT = $(TOOLS)add-freedict.sh
TEI2WEBSTER = $(TOOLS)tei2webster.pl
WEBSTERDIR = ../../1/
WEBSTER = $(WEBSTERDIR)/webfmt
DICT2VOK = $(TOOLS)dict2evolutionary.pl
XSLPROCESSOR = sabcmd

XSLT = $(TOOLS)tei2webster.xsl


VPATH = ../tools:../dicts:../dicts/bin

include Makefile.language
include $(TOOLS)Makefile.config

.tei.dict:
	# $(TEI2DICT) $*.tei
	#$(TEI2WEBSTER) $*.tei
	$(XSLTPROCESSOR) $(XSLT) $*.tei $*.web
	$(WEBSTER) < $*.web
	if [ ! -d ../dicts ]; then  mkdir ../dicts; fi
	mv web1913.dict ../dicts/$*.dict
	mv web1913.index ../dicts/$*.index

.dict.dz:
	dictzip -k ../dicts/$*.dict

.dz.tar.gz:
	if [ ! -d ../dicts ]; then mkdir ../dicts/bin; fi
	(cd ../dicts/ ; tar czvf bin/$*.tar.gz $*.dict.dz $*.index)

.dict.vok:
	$(DICT2VOK) < ../dicts/$*.dict |\
	recode -f u8..cp1252 > ../dicts/$*.vok;

all:	\
	$(LANGUAGE).tar.gz

vok:	\
	$(LANGUAGE).vok

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
