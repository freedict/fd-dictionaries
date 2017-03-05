# The line below is really just a fallback and only works if you have got a copy of the tools directory at this location. It's better to set the environment variable in your shell.
FREEDICT_TOOLS ?= ../../tools
DISTFILES = sor-kur.txt Makefile ckb-kmr.tei ckb-kmr.tei.header README ChangeLog \
  INSTALL freedict-P5.dtd freedict-P5.rng freedict-P5.xml freedict-dictionary.css
include $(FREEDICT_TOOLS)/mk/dicts.mk
#$(dictname).tei: sor-kur.txt $(dictname).tei.header \
#	$(toolsdir)/xdf2tei.pl
#	cat $(dictname).tei.header >$@
#	$(toolsdir)/xdf2tei.pl <$< >>$@
#	echo "</body></text></TEI.2>" >>$@

#clean::
#	-rm $(dictname).tei
