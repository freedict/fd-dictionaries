FREEDICTDIR ?= ..
DISTFILES = kha-eng.tei Makefile
include $(FREEDICTDIR)/tools/Makefile.common
LA1locale = kha_IN


# bedic related

# old style to group homographs, kept for timing comparison
grouped2.tei: $(dictname).tei $(xsldir)/group-homographs.xsl
	time $(XSLTPROCESSOR) $(xsldir)/group-homographs.xsl $< '$$verbose=' >$@

clean::
	rm -f grouped2.tei


# stardict related
.PHONY: stardict

$(dictname).idxhead:
	echo "" > $@

dictd_www.freedict.de_$(dictname).idx.gz dictd_www.freedict.de_$(dictname).dict.dz: $(dictname).index $(dictname).dict $(dictname).idxhead
	scrambled_wordcount="$(shell ~/dict/platforms/stardict/stardict-2.4.4/src/tools/dictd2dic $(dictname))"
	echo "$(word 3,$(scrambled_wordcount))"

stardict: dictd_www.freedict.de_$(dictname).ifo

dictd_www.freedict.de_$(dictname).ifo: dictd_www.freedict.de_$(dictname).idx.gz
	echo "StarDict's dict ifo file" > $@
	echo "version=2.4.2" >> $@
	echo "wordcount=1706" >> $@
	size="$(shell zcat dictd_www.freedict.de_$(dictname).idx.gz | wc -c)"; \
	echo "idxfilesize=$$size" >> $@
	echo "bookname=$(dictname)" >> $@
	echo "author=the author name" >> $@
	echo "email=author@email" >> $@
	echo "website=www.freedict.org" >> $@
	echo "description=converted to StarDict format by freedict.org" >> $@
	echo "date=2005.03.25" >> $@
	echo "sametypesequence=m" >> $@

clean::
	rm -f $(dictname).idxhead dictd_www.freedict.de_$(dictname).idx.gz dictd_www.freedict.de_$(dictname).dict.dz $(dictname).ifo

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

