# This makefile snippet contains all commands which can be performed on a whole
# collection of dictionaries in the same directory. It assumes to be included
# and executed in a directory with subdirectories called "lg1-lg2" (so the usual
# ditionary naming conventions).
FREEDICT_TOOLS ?= .
include $(FREEDICT_TOOLS)/mk/config.mk

DICTS=$(shell find $(FREEDICTDIR) -maxdepth 2 -name '???-???' -printf "%P ")

# Calls default target for each dictionary module.
# Note: This is a conflict if you wanted to call
# the 'all' target of each dictionary module.
all: #! build all dictionaries (default)
all: build_all $(DICTs)

# most useful targets
# allow parallel builds of all dictionaries

build_all: $(DICTS)

$(DICTS):
	$(MAKE) -C $(FREEDICTDIR)/$@

install-base: #! install the built files, without attempting to restart any applications using them
install-base: build_all
	for dict in $(DICTS); do; \
		make -e -C $(DICTS) install; \
	done

install: #! install built dictionaries and attempt to restart applications using them
install: install-core
	$(DICTD_RESTART_SCRIPT)

# ToDo
uninstall:
	$(BUILD)

clean::
	for DICT in $(DICTS); do \
		$(MAKE) -C $(DICT); \
	done

.PHONY: install uninstall api all clean build_all $(DICTS)
