# The line below is really just a fallback and only works if you have got a copy of the tools directory at this location. It's better to set the environment variable in your shell.
FREEDICT_TOOLS ?= ../../tools
DISTFILES = AUTHORS ChangeLog COPYING lat-deu.tei \
freedict-P5.xml freedict-P5.rng freedict-P5.dtd freedict-dictionary.css INSTALL Makefile NEWS README words.xsl words.xml
include $(FREEDICT_TOOLS)/mk/dicts.mk


clean::
	-rm -f lat-deu.tmp xslt.tmp

lat-deu.tei: lat-deu-header.tei words.xml words.xsl
	@echo 'Converting one custom XML format to TEI xml…'
	xsltproc words.xsl words.xml >> $(@:tei=tmp)
	grep -B 99999 '<body>' $(@:.tei=-header.tei) > $@
	tail -n +2 < $(@:tei=tmp) >> $@
	grep -A 9999 '</body>' $(@:.tei=-header.tei) >> $@
	-rm $(@:tei=tmp)
	@echo 'Reformatting TEI file…'
	xmllint --format - > $(@:tei=tmp) < $@
	cat $(@:tei=tmp) > $@
	rm $(@:tei=tmp)



