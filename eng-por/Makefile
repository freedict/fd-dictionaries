# The line below is really just a fallback and only works if you have got a copy of the tools directory at this location. It's better to set the environment variable in your shell.
FREEDICT_TOOLS ?= ../../tools
DISTFILES = eng-por.tei Makefile COPYING INSTALL NEWS README ChangeLog \
freedict-P5.dtd freedict-P5.rng freedict-P5.xml freedict-dictionary.css
# Clear this variable, because currently the .tei file already contains
# phonetics information.
supported_phonetics =
include $(FREEDICT_TOOLS)/Makefile.common
