# Makefile that can call `make' for all dictionary modules

# calls default target for each dictionary module
all:	
	for file in ../???-???; do $(MAKE) -C $$file; done

# most useful targets
release-%:
	for file in ../???-???; do $(MAKE) -C $$file $@; done

# if you forgot where you made changes... :)
commit:
	for file in ../???-???; do $(MAKE) -C $$file $@; done

install:
	for file in ../*-*; do $(MAKE) -C $$file install; done

uninstall:
	for file in ../*-*; do $(MAKE) -C $$file uninstall; done

.PHONY: install uninstall commit release-% all
