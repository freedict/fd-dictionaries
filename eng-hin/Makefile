
.SUFFIXES: .tar.gz .tei .dict .dz .vok

TOOLS = ../tools/
TEI2DICT = $(TOOLS)tei2dict_xml.pl
ADDFREEDICT = $(TOOLS)add-freedict.sh
TEI2WEBSTER = $(TOOLS)tei2webster.pl
WEBSTERDIR = ../../1/
WEBSTER = $(WEBSTERDIR)/webfmt
DICT2VOK = $(TOOLS)dict2evolutionary.pl


VPATH = ../tools:../dicts:../dicts/bin

include Makefile.language

all:	\
	$(LANGUAGE).tar.gz

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

# below is like the other freedict makefiles

.tei.dict:
	$(TEI2DICT) -f $*.tei -c
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

test:	\
	$(LANGUAGE).tei
	nsgmls -E 5 -s 
