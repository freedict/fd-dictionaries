
.SUFFIXES: .tar.gz  

VPATH = ../dicts/bin

vok:
	for file in ../*-*; do echo make $$file; $(MAKE) -C $$file vok; done

all:	
	for file in ../*-*; do echo make $$file; $(MAKE) -C $$file; done

commit:
	for file in ../*-*; do echo commit $$file; $(MAKE) -C $$file commit; done

install:
	for file in ../*-*; do echo make $$file; $(MAKE) -C $$file install; done


uninstall:
	for file in ../*-*; do echo make $$file; $(MAKE) -C $$file uninstall; done

makefiles:
	for file in ../*-*; do echo makefiles $$file; rm $$file/Makefile; ln -s ../tools/Makefile.dicts $$file/Makefile; done
 
