
.SUFFIXES: .tar.gz .tei .dict .dz

TOOLS = ../tools/
TEI2DICT = $(TOOLS)tei2dict.pl
ADDFREEDICT = $(TOOLS)add-freedict.sh
TEI2WEBSTER = $(TOOLS)tei2webster.pl
WEBSTERDIR = ../../1/dict-gcide/
WEBSTER = $(WEBSTERDIR)/webfmt


VPATH = ../tools:../dicts:../dicts/bin

include Makefile.language


.tei.dict:
	# $(TEI2DICT) $*.tei
	$(TEI2WEBSTER) $*.tei
	$(WEBSTER) < $*.web
	if [ ! -d ../dicts ]; then  mkdir ../dicts; fi
	mv web1913.dict ../dicts/$*.dict
	mv web1913.index ../dicts/$*.index

.dict.dz:
	dictzip -k ../dicts/$*.dict

.dz.tar.gz:
	if [ ! -d ../dicts ]; then mkdir ../dicts/bin; fi
	(cd ../dicts/ ; tar czvf bin/$*.tar.gz $*.dict.dz $*.index)

all:	\
	$(LANGUAGE).tar.gz


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
