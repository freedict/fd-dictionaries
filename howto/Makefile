XMLTO_OPTS = -m inc/customise-docbook.xsl
# when you use Debian and the docbook-xsl package:
#DOCBOOKIMAGES = /usr/share/doc/docbook-xsl/images
# Debian, docbook-xsl 1.71.0.dfsg.1-2
DOCBOOKIMAGES = /usr/share/xml/docbook/stylesheet/nwalsh/images
# when you use SuSE 9.0 and the docbook-xsl-stylesheets package:
#DOCBOOKIMAGES = /usr/share/sgml/docbook/docbook-xsl-stylesheets-1.61.3/images
HOWTO_VERSION = 0.1

# these files have to reside in the "inc" subdir
VERBATIMFILES = la1-la2.template.tei kha-deu.tei.header
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
	oodraw $<
	exit 1

$(addprefix html/,$(linkfiles)): $(addprefix inc/,$(linkfiles))
	for i in $(linkfiles); do if [ ! -L $@ ]; then ln -s ../inc/$$i html/; fi; done

$(addprefix xhtml/,$(linkfiles)): $(addprefix inc/,$(linkfiles))
	for i in $(linkfiles); do if [ ! -L $@ ]; then ln -s ../inc/$$i xhtml/; fi; done

# targets for output formats
xhtml: xhtml-folder *.xml inc/customise-docbook.xsl $(addprefix xhtml/,$(linkfiles))
	@if [ ! -L xhtml/images ]; then ln -s $(DOCBOOKIMAGES) xhtml/images; fi
	xmlto $(XMLTO_OPTS) -o xhtml xhtml freedicthowto.xml

xhtml-folder:
	mkdir xhtml

xhtml-nochunks: *.xml inc/customise-docbook.xsl $(addprefix xhtml/,$(linkfiles))
	@if [ ! -L xhtml/images ]; then ln -s $(DOCBOOKIMAGES) xhtml/images; fi
	xmlto $(XMLTO_OPTS) -o xhtml xhtml-nochunks freedicthowto.xml

html: *.xml inc/customise-docbook.xsl $(addprefix html/,$(linkfiles))
	@if [ ! -L html/images ]; then ln -s $(DOCBOOKIMAGES) html/images; fi
	xmlto $(XMLTO_OPTS) -o html html freedicthowto.xml

pdf: *.xml inc/customise-docbook.xsl $(linkfiles)
	xmlto $(XMLTO_OPTS) pdf freedicthowto.xml

ps: *.xml inc/customise-docbook.xsl $(linkfiles)
	xmlto $(XMLTO_OPTS) ps freedicthowto.xml

clean:
	rm -f *~ xhtml/* html/* inc/*.escaped.xml

commit:
	cvs -z3 commit

dist: $(DISTFILES)
	cd .. && tar cvjf howto/freedict-howto-$(HOWTO_VERSION).src.tar.bz2 $(addprefix howto/,$^)

# -h makes tar dereference symbolic links
freedict-howto-$(HOWTO_VERSION).xhtml.tar.bz2: xhtml
	tar cvjhf $@ --exclude "*.[tg]if" xhtml

release-xhtml: freedict-howto-$(HOWTO_VERSION).xhtml.tar.bz2

.PHONY: all xhtml xhtml-folder xhtml-nochunks html clean commit dist release-xhtml
