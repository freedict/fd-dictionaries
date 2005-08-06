XMLTO_OPTS = -m inc/customise-docbook.xsl
DOCBOOKIMAGES = /usr/share/sgml/docbook/docbook-xsl-stylesheets-1.61.3/images
HOWTO_VERSION = 0.0.8

# these files have to reside in the "inc" subdir
VERBATIMFILES = la1-la2.template.tei
EXTRAFILES = build-system-overview.png style.css la1-la2.template.tei

DISTFILES = $(wildcard *.xml) ChangeLog Makefile \
    $(addprefix inc/,$(VERBATIMFILES)) \
    inc/build-system-overview.sxd inc/customise-docbook.xsl inc/escapexml.pl \
    inc/style.css

escapedfiles = $(addsuffix .escaped.xml,$(VERBATIMFILES))
linkfiles = $(escapedfiles) $(EXTRAFILES)

# default target
all: xhtml

# files that are included by the docs (images, stylesheet etc.)
%.escaped.xml: %
	inc/escapexml.pl $< >$@

inc/build-system-overview.svg inc/build-system-overview.png: inc/build-system-overview.sxd
	@echo "I'm starting OpenOffice now. Please export the data as PNG and SVG."
	OOo-draw $<
	exit 1

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

commit:
	cvs -z3 commit

dist: $(DISTFILES)
	cd .. && tar cvjf howto/freedict-howto-$(HOWTO_VERSION).src.tar.bz2 $(addprefix howto/,$^)

# -h makes tar dereference symbolic links
freedict-howto-$(HOWTO_VERSION).xhtml.tar.bz2: xhtml
	tar cvjhf $@ --exclude "*.[tg]if" xhtml

release-xhtml: freedict-howto-$(HOWTO_VERSION).xhtml.tar.bz2

.PHONY: all xhtml xhtml-nochunks html clean commit dist release-xhtml
