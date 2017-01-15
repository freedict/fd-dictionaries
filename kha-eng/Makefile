FREEDICTDIR ?= ../../
DISTFILES = kha-eng.tei Makefile ChangeLog \
   INSTALL freedict-P5.dtd freedict-P5.rng freedict-P5.xml \
   freedict-dictionary.css
include $(FREEDICTDIR)/tools/Makefile.common
LA1locale = kha_IN

# aspell related
# creates aspell wordlist for la1
la1 = $(shell export V=$(dictname); echo $${V:0:3})

# disadvantage: dictd normalized words (lowercase, only alnumspace)
$(la1).wordlist: $(dictname).index
	$(toolsdir)/testing/index2wordlist.pl $< >$@

$(la1).rws: $(la1).wordlist
	aspell --lang=$(la1) create master ./$@ < $<

aspell: $(la1).rws

clean::
	rm -f $(la1).wordlist $(la1).rws

.PHONY: aspell

