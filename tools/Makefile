# This makefile forms the root of the FreeDict build infrastructure.
# It provides commands to build and install dictionaries and to generate the API
# file.

TOOLSDIR ?= $(FREEDICTDIR)/tools
include $(TOOLSDIR)/Makefile.config # that defines also TOOLSDIR - never mind

DICTS=$(shell find $(FREEDICTDIR) -maxdepth 2 -name '???-???' -printf "%P ")

# Calls default target for each dictionary module.
# Note: This is a conflict if you wanted to call
# the 'all' target of each dictionary module.
all: build_all $(DICTs)

# most useful targets
## allow parallel builds of all dictionaries

build_all: $(DICTS)

$(DICTS):
	$(MAKE) -C $(FREEDICTDIR)/$@

install-base: ## install the built files, without attempting to restart any applications using them
install-base: build_all
	for dict in $(DICTS); do; \
		make -e -C $(DICTS) install; \
	done

install: ## install built dictionaries and attempt to restart applications using them
install: install-core
	$(DICTD_RESTART_SCRIPT)

# ToDo
uninstall:
	$(BUILD)

# check whether has been configured for remote file access exists
$(FREEDICTDIR)/config.ini:
ifeq ("$(wildcard $(PATH_TO_FILE))","")
	$(error For this target, a configuration named $(FREEDICTDIR)/config.ini has to exist. It contains information about how to access the released and generated dictionaries. You might also want to have a look at the $(FREEDICTDIR)tools/api/file_manager program.)
endif

# call the API generator to create a file $FREEDICTDIR/freedict-database.xml
api: $(FREEDICTDIR)/config.ini
	# -p: mount / synchronize released and generated files; -o: umount them
	#  again
	$(PYTHON) $(TOOLSDIR)/api/generator/generator.py \
		-p "$(PYTHON) $(TOOLSDIR)/api/file_manager/file_manager.py -m" \
		-o "$(PYTHON) $(TOOLSDIR)/api/file_manager/file_manager.py -u" \
		$(FREEDICTDIR)/freedict-database.xml\
		|| sleep 1; $(PYTHON) $(TOOLSDIR)/api/file_manager/file_manager.py -u
# the last line above makes sure that sshfs volumes are umounted, if something
# goes wrong

# provide a clean up rule, which can be run, if sshfs was not umounted cleanly
api-cleanup:
	$(PYTHON) $(TOOLSDIR)/api/file_manager/file_manager.py -u

api-validation: $(FREEDICT_DIR)/freedict-database.xml $(FREEDICT_DIR)/freedict-database.rng
	xmllint --noout --relaxng freedict-database.rng $<


clean:
	$(BUILD)

.PHONY: install uninstall api release-% all vok clean tests update dist build_all $(DICTS)

