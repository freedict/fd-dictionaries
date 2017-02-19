# The line below is really just a fallback and only works if you have got a copy of the tools directory at this location. It's better to set the environment variable in your shell.
FREEDICT_TOOLS ?= ../../tools
DISTFILES = ChangeLog English-Czech.xdf Makefile \
	eng-ces.tei eng-ces.tei.header README ChangeLog general.footer \
  INSTALL freedict-P5.dtd freedict-P5.rng freedict-P5.xml freedict-dictionary.css
supported_phonetics=
include $(FREEDICT_TOOLS)/Makefile.common
#eng-ces-nophon.tei: $(toolsdir)/xdf2tei.pl eng-ces.tei.header general.footer
#	cat eng-ces.tei.header >$@
#	$(toolsdir)/xdf2tei.pl <English-Czech.xdf >>$@
#	cat general.footer >>$@

#clean::
#	rm -f eng-ces.tei eng-ces-nophon.tei
