
.SUFFIXES: .tar.gz .tei .dict .dz

TOOLS = ../tools/
TEI2DICT = $(TOOLS)tei2dict.pl
ADDFREEDICT = $(TOOLS)add-freedict.sh

VPATH = ../tools:../dicts:../dicts/bin

.tei.dict:
	$(TEI2DICT) $*.tei
	if [ ! -d ../dicts ]; then  mkdir ../dicts; fi
	mv $*.dict ../dicts
	mv $*.index ../dicts

.dict.dz:
	dictzip -k ../dicts/$*.dict

.dz.tar.gz:
	if [ ! -d ../dicts ]; then mkdir ../dicts/bin; fi
	(cd ../dicts/ ; tar czvf bin/$*.tar.gz $*.dict.dz $*.index)

all:	\
	deu-nld.tar.gz


install: all\
	$(ADDFREEDICT) --remove $*
	$(ADDFREEDICT) --install $*

commit: 
	cvs -z3 commit
