# This makefile snippet contains all commands which can be performed in a
# directory containing many dictionary (a dictionary root).
# The subdirectories have to be called "lg1-lg2" (so the usual dictionary naming
# conventions).
FREEDICT_TOOLS ?= .
include $(FREEDICT_TOOLS)/mk/config.mk

# this shows that this makefile include may only be used for a directory
# containing many dictionaries
DICTS=$(shell find . -maxdepth 1 -name '???-???' -printf "%P ")

# Calls default target for each dictionary module.
# Note: This is a conflict if you wanted to call
# the 'all' target of each dictionary module.
all: #! build all dictionaries (default)
all: build_all $(DICTs)

# most useful targets
# allow parallel builds of all dictionaries

build_all: $(DICTS)

$(DICTS):
	$(MAKE) -C $@

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
