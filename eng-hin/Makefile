
.SUFFIXES: .tar.gz .tei .dict .dz .vok

TOOLS = ../tools/
TEI2DICT = $(TOOLS)xmltei2xmldict.pl
ADDFREEDICT = $(TOOLS)add-freedict.sh
TEI2WEBSTER = $(TOOLS)tei2webster.pl
WEBSTERDIR = ../../1/
WEBSTER = $(WEBSTERDIR)/webfmt
DICT2VOK = $(TOOLS)dict2evolutionary.pl

VERSION = 1.3

VPATH = ../tools:../dicts:../dicts/bin

SGML_CATALOG_FILES = /usr/share/sgml/opensp/xml.soc:/var/lib/sgml/CATALOG.tei_4xml:/var/lib/sgml/CATALOG.xmlcharent
LANGUAGE = $(shell basename $(PWD))
RLANGUAGE = hin-eng

all:	\
	$(LANGUAGE).tar.gz

rtgz:	\
	$(RLANGUAGE).tar.gz

# these are eng-hin specific targets

ehconv.c : ehconv.yy
	flex -oehconv.c ehconv.yy

ehconv : ehconv.c
	gcc ehconv.c -lfl -oehconv

eng-hin.tei.end : ehconv English-Hindi-Dictionary_2.isc
	./ehconv <English-Hindi-Dictionary_2.isc >eng-hin.tei.end

eng-hin.tei : eng-hin.tei.header eng-hin.tei.end
	cat eng-hin.tei.header eng-hin.tei.end >eng-hin.tei

clean:
	rm ehconv.c eng-hin.index eng-hin.dict eng-hin.tei eng-hin.tei.end ehconv

reverse:
	(export SGML_CATALOG_FILES=$(SGML_CATALOG_FILES);\
	$(TEI2DICT) -u -f $(LANGUAGE).tei -t ../tools/xsl/tei2txt.xsl -r -a)
	mv $(LANGUAGE).dict ../dicts/$(RLANGUAGE).dict
	mv $(LANGUAGE).index ../dicts/$(RLANGUAGE).index

.tei.dict:
	$(TEI2DICT) -f $*.tei -u -t ../tools/xsl/tei2txt.xsl
	#$(TEI2WEBSTER) $*.tei
	#$(WEBSTER) < $*.web
	if [ ! -d ../dicts ]; then  mkdir ../dicts; fi
	mv $*.dict ../dicts
	mv $*.index ../dicts

.dict.dz:
	dictzip -k ../dicts/$*.dict

.dz.tar.gz:
	if [ ! -d ../dicts ]; then mkdir ../dicts/bin; fi
	(cd ../dicts/ ; tar czvf bin/$*.tar.gz $*.dict.dz $*.index)

.dict.vok:
	$(DICT2VOK) < ../dicts/$*.dict |\
	recode -f u8..cp1252 > ../dicts/$*.vok;


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

validation: $(LANGUAGE).tei
	export SP_ENCODING=XML ;\
        export SP_CHARSET_FIXED=YES ;\
        export SGML_CATALOG_FILES=$(SGML_CATALOG_FILES) ;\
        nsgmls -s -E 10 $(LANGUAGE).tei

.PHONY: test rtest validation all install commit clean

test:
	$(TOOLS)/testing/test-database.pl -l de_DE.utf8 -f ../dicts/$(LANGUAGE) |tee testresult.txt

rtest:
	$(TOOLS)/testing/test-database.pl -l de_DE.utf8 -f ../dicts/$(RLANGUAGE) |tee testresult-reverse.txt

dist:
	cd ..; tar cvjf $(LANGUAGE)/$(LANGUAGE)-$(VERSION).src.tar.bz2 \
$(LANGUAGE)/AUTHORS \
$(LANGUAGE)/ChangeLog \
$(LANGUAGE)/COPYING \
$(LANGUAGE)/English-Hindi-Dictionary_2.isc \
$(LANGUAGE)/INSTALL \
$(LANGUAGE)/Makefile \
$(LANGUAGE)/NEWS \
$(LANGUAGE)/README \
$(LANGUAGE)/ehconv.yy \
$(LANGUAGE)/eng-hin.tei.header
