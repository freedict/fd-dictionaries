XMLTO_OPTS = -m inc/customise-docbook.xsl
DOCBOOKIMAGES = /usr/share/sgml/docbook/docbook-xsl-stylesheets-1.61.3/images

# these files have to reside in the "inc" subdir
VERBATIMFILES = la1-la2.template.tei
EXTRAFILES = build-system-overview.png style.css la1-la2.template.tei

escapedfiles = $(addsuffix .escaped.xml,$(VERBATIMFILES))
linkfiles = $(escapedfiles) $(EXTRAFILES)

# default target
all: xhtml

# files that are included by the docs (images, stylesheet etc.)
%.escaped.xml: %
	inc/escapexml.pl $< >$@

$(addprefix html/,$(linkfiles)): $(addprefix inc/,$(linkfiles))
	for i in $(linkfiles); do if [ ! -a $@ ]; then ln -s ../inc/$$i html/; fi; done

$(addprefix xhtml/,$(linkfiles)): $(addprefix inc/,$(linkfiles))
	for i in $(linkfiles); do if [ ! -L $@ ]; then ln -s ../inc/$$i xhtml/; fi; done

# targets for output formats
xhtml: *.xml inc/customise-docbook.xsl $(addprefix xhtml/,$(linkfiles))
	@if [ ! -d xhtml/images ]; then ln -s $(DOCBOOKIMAGES) xhtml/images; fi
	xmlto $(XMLTO_OPTS) -o xhtml xhtml freedicthowto.xml

xhtml-nochunks: *.xml inc/customise-docbook.xsl $(addprefix xhtml/,$(linkfiles))
	@if [ ! -d xhtml/images ]; then ln -s $(DOCBOOKIMAGES) xhtml/images; fi
	xmlto $(XMLTO_OPTS) -o xhtml xhtml-nochunks freedicthowto.xml

html: *.xml inc/customise-docbook.xsl $(addprefix html/,$(linkfiles))
	@if [ ! -d html/images ]; then ln -s $(DOCBOOKIMAGES) html/images; fi
	xmlto $(XMLTO_OPTS) -o html html freedicthowto.xml

pdf: *.xml inc/customise-docbook.xsl $(linkfiles)
	xmlto $(XMLTO_OPTS) pdf freedicthowto.xml

ps: *.xml inc/customise-docbook.xsl $(linkfiles)
	xmlto $(XMLTO_OPTS) ps freedicthowto.xml

clean:
	-rm *~ xhtml/* html/* inc/*.escaped.xml

.PHONY: all xhtml xhtml-nochunks html clean
