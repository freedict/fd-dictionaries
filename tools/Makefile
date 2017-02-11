# Makefile that can call `make' for all dictionary modules

include Makefile.config

TOOLSDIR := $(FREEDICTDIR)/tools

BUILD = set -e && for file in $(FREEDICTDIR)/crafted/???-???; do $(MAKE) -C $$file $@; done \
               && for file in $(FREEDICTDIR)/generated/???-???; do $(MAKE) -C $$file $@; done \

# Calls default target for each dictionary module.
# Note: This is a conflict if you wanted to call
# the 'all' target of each dictionary module.
all:
	for file in $(FREEDICTDIR)/crafted/???-???; do $(MAKE) -C $$file; done
	for file in $(FREEDICTDIR)/generated/???-???; do $(MAKE) -C $$file; done

# most useful targets
release-%:
	$(BUILD)

dist:
	$(BUILD)

# if you forgot where you made changes... :)
vok:
	$(BUILD)

install:
	$(BUILD)

uninstall:
	$(BUILD)

# check whether fsetup has been configured already
$(FREEDICTDIR)/config.ini:
ifeq ("$(wildcard $(PATH_TO_FILE))","")
	$(error For this target, a configuration named $FREEDICTDIR/config.ini has to exist. It contains information about how to access the released and generated dictionaries. You might also want to have a look at the $(FREEDICTDIR)tools/api/file_manager program.)
endif

# call the API generator to create a file $FREEDICTDIR/freedict-database.xml
dbupdate: $(FREEDICTDIR)/config.ini
	# -p: mount / synchronize released and generated files; -o: umount them
	#  again
	$(PYTHON) $(TOOLSDIR)/api/generator/main.py \
		-p "$(PYTHON) $(TOOLSDIR)/api/file_manager/file_manager.py -m" \
		-o "$(PYTHON) $(TOOLSDIR)/file_manager/file_manager.py -u" \
		$(FREEDICTDIR)/freedict-database.xml

clean:
	$(BUILD)

tests:
	$(BUILD)

test:
	$(BUILD)

validation:
	$(BUILD)

.PHONY: install uninstall dbupdate release-% all vok clean tests update dist

