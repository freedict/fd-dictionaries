FREEDICTDIR ?= ..
DISTFILES = kha-eng.tei Makefile
include $(FREEDICTDIR)/tools/Makefile.common

grouped.tei: ../tools/xsl/group-homographs.xsl kha-eng.tei
	sabcmd ../tools/xsl/group-homographs.xsl kha-eng.tei >grouped.tei '$$verbose='

tei-wrapper.xml:
	ln -s ../tools/xsl/tei-wrapper.xml

unwrapped.tei: grouped.tei tei-wrapper.xml
	xmllint --noent tei-wrapper.xml >unwrapped.tei

unwrapped.dic: unwrapped.tei
	../tools/tei2dic.py unwrapped.tei unwrapped.dic

unwrapped.xeroxed.dic: unwrapped.dic
	xerox -d unwrapped.dic unwrapped.xeroxed.dic

clean::
	-rm unwrapped.dic unwrapped.xeroxed.dic

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

la1 = $(shell export V=$(dictname); echo $${V:0:3})
	
clean::
	-rm $(dictname).idxhead dictd_www.freedict.de_$(dictname).idx.gz dictd_www.freedict.de_$(dictname).dict.dz $(dictname).ifo
	-rm $(la1).wordlist $(la1).rws

$(la1).wordlist: $(dictname).index
	$(toolsdir)/testing/index2wordlist.pl $< >$@

$(la1).rws: $(la1).wordlist
	aspell --lang=$(la1) create master ./$@ < $<

aspell: $(la1).rws

.PHONY: aspell

