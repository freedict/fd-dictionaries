FREEDICTDIR ?= ..
DISTFILES = kha-eng.tei Makefile
include $(FREEDICTDIR)/tools/Makefile.common
LA1locale = kha_IN

# aspell related
la1 = $(shell export V=$(dictname); echo $${V:0:3})

clean::
	rm -f $(la1).wordlist $(la1).rws

$(la1).wordlist: $(dictname).index
	$(toolsdir)/testing/index2wordlist.pl $< >$@

$(la1).rws: $(la1).wordlist
	aspell --lang=$(la1) create master ./$@ < $<

aspell: $(la1).rws

.PHONY: aspell

