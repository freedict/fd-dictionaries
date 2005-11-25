# Makefile that can call `make' for all dictionary modules

include Makefile.config

BUILD =	for file in $(FREEDICTDIR)/???-???; do $(MAKE) -C $$file $@; done

# Calls default target for each dictionary module.
# Note: This is a conflict if you wanted to call
# the 'all' target of each dictionary module.
all:	
	for file in $(FREEDICTDIR)/???-???; do $(MAKE) -C $$file; done

# most useful targets
release-%:
	$(BUILD)

# if you forgot where you made changes... :)
commit:
	$(BUILD)

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

update:
	for file in $(FREEDICTDIR)/???-???; do cd $$file && cvs -z3 update; done

.PHONY: install uninstall dbupdate commit release-% all vok clean update

