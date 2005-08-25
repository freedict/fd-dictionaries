#figdir = figures
figdir =
docname = freedict-editor
lang = C
omffile = freedict-editor-C.omf
entities = legal.xml ipa-table.xml
include $(top_srcdir)/xmldocs.make
dist-hook: app-dist-hook

# generate HTML version of the docs for the freedict.org website
.PHONY: html
XMLTO_OPTS = -m customise-docbook.xsl
html: freedict-editor.xml
	xmlto $(XMLTO_OPTS) -o html html freedict-editor.xml
