# This makefile contains all recipes to build and manage the FreeDict
# tools, including the API. It also provides targets to build a release archive
# with the latest tools included.

FREEDICT_TOOLS ?= .
include $(FREEDICT_TOOLS)/mk/config.mk

VERSION = 0.4
PREFIX ?= usr/local
DESTDIR ?= /
INSTALLDIR ?= $(DESTDIR)/$(PREFIX)/share/freedict

dirs = api buildhelpers ergane JMdict lib mk teimerge testing xquery xsl/inc
TARGET_DIRS = $(addprefix $(INSTALLDIR)/tools/, $(dirs))


api: #! generate the api with information about all dictionaries and their downloads at the configured api path
api:
	# -p: mount / synchronize released and generated files; -o: umount them
	#  again
	$(PYTHON) $(FREEDICT_TOOLS)/api/generator/generator.py \
		-p "$(PYTHON) $(FREEDICT_TOOLS)/api/file_manager/file_manager.py -m" \
		-o "$(PYTHON) $(FREEDICT_TOOLS)/api/file_manager/file_manager.py -u" \
		$(FREEDICT_TOOLS)/freedict-database.xml\
		|| sleep 1; $(PYTHON) $(FREEDICT_TOOLS)/api/file_manager/file_manager.py -u
# the last line above makes sure that sshfs volumes are umounted, if something
# goes wrong

# provide a clean up rule, which can be run, if sshfs was not umounted cleanly
api-cleanup: #! runs umount / clean up actions if make api failed and cannot be executed in a subsequent run
	@$(PYTHON) $(FREEDICT_TOOLS)/api/file_manager/file_manager.py -u

api-validation: #! validate the freedict-database.xml against its RNG schema
api-validation:
	xmllint --noout --relaxng freedict-database.rng $(shell $(MAKE) api-path)



$(BUILD_DIR)/freedict-tools-$(VERSION).tar.bz2: Makefile* *.pl
ifeq ($(wildcard $(BUILD_DIR)),)
	mkdir -p $(BUILD_DIR)
endif
	tar --totals --exclude="*/.svn/*" --exclude="*/.*" \
	  --exclude="*/charlint*" --exclude="*/UnicodeData.txt" \
	  --exclude="*/ergane/jet4/*" \
	  --exclude="*/ergane/unzip/*" \
	  --exclude="*/ergane/zip/*" \
	  --exclude="*/__pycache__/*" \
	  -cvjf $@ ../tools

release: #! build a release tarball in $$BUILD_DIR, ../build by default
release: $(BUILD_DIR)/freedict-tools-$(VERSION).tar.bz2

# ToDo: needs to be rewritten
install: #! install the tools to $$DESTDIR/$PREFIX/share/freedict, by default /usr/local/share/freedict
	install -d $(TARGET_DIRS)
	install $(INSTALL_FILES) $(INSTALLDIR)
	install -m 644 lib/*.pm \
	  $(INSTALLDIR)/tools/lib
	install -m 644 xsl/inc/*.xsl \
	  $(INSTALLDIR)/xsl/inc

# ToDo: should be only re-enabled when providing an up-to-date RPM .spec file
#release-rpm-freedict-tools: freedict-tools.spec \
#	$(BUILD_DIR)/freedict-tools-$(VERSION).tar.bz2
#	@if [ ! -d /usr/src/rpm/RPMS/noarch ]; then \
#	  mkdir -p /usr/src/rpm/RPMS/noarch; fi
#	@if [ ! -d $(BUILD_DIR)/rpm ]; then \
#	  ln -s /usr/src/rpm/RPMS/noarch \
#	  $(BUILD_DIR)/rpm; fi
#	@if [ ! -d /usr/src/rpm/SOURCES ]; then \
#	  mkdir -p /usr/src/rpm/SOURCES; fi
#	if [ ! -r /usr/src/rpm/SOURCES/freedict-tools-$(VERSION).tar.bz2 ]; then \
#	  ln -s $(BUILD_DIR)/freedict-tools-$(VERSION).tar.bz2 \
#	    /usr/src/rpm/SOURCES/freedict-tools-$(VERSION).tar.bz2; fi
#	rpmbuild --target=noarch -ba freedict-tools.spec

.PHONY: release install release-rpm-freedict-tools api all


