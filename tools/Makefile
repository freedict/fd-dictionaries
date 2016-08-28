# Makefile that can call `make' for all dictionary modules

include Makefile.config

BUILD = set -e && for file in $(FREEDICTDIR)/???-???; do $(MAKE) -C $$file $@; done

# Calls default target for each dictionary module.
# Note: This is a conflict if you wanted to call
# the 'all' target of each dictionary module.
all:
	for file in $(FREEDICTDIR)/???-???; do $(MAKE) -C $$file; done

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

dbupdate:
	$(BUILD)

clean:
	$(BUILD)

tests:
	$(BUILD)

test:
	$(BUILD)

validation:
	$(BUILD)

update:
	for file in $(FREEDICTDIR)/???-???; do cd $$file && svn update; done

.PHONY: install uninstall dbupdate release-% all vok clean tests update dist

