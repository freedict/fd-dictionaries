# This file contains all targets defined for a dictionary. Each dictionary
# makefile should include it. It defines targets to convert (build) the TEI
# files to the supported output formats. It also features some release targets
# used for making a release in FreeDict. "install" and "uninstall" targets are
# provided, too.
include $(FREEDICT_TOOLS)/mk/config.mk

#######################
#### set some variables
#######################

# let the tools from $(toolsdir) override tools
# from /usr/bin
PATH := $(FREEDICT_TOOLS):$(PATH)

ifeq ($(origin UNSUPPORTED_PLATFORMS), undefined)
UNSUPPORTED_PLATFORMS = bedic evolutionary
endif


available_platforms := dictd stardict aspell d4m fo

xsldir ?= $(FREEDICT_TOOLS)/xsl
xmllint := /usr/bin/xmllint

dictname ?= $(shell basename "$(shell pwd)")
rdictname := $(shell export V=$(dictname); echo $${V:4:3}-$${V:0:3})


PREFIX ?= usr
DESTDIR ?= /

################
# default target
################


all: #! build all currently supported output formats
all: $(dictname).dict.dz $(dictname).index

# Please note: the "release" target has been significantly reduced to enable the
# release of FreeDict tools in a relatively problem-free state.
# You are more than welcome to help out in the process of re-instituting
# the above targets; please drop us a line at freedict-beta.

release: #! build all available release archives at release/
release: release-src release-dict-tbz2 release-dict-tgz


find-homographs: $(dictname).tei
	@cat $< | grep orth | \
	sed -e s:'          <orth>':'':g -e s:'<\/orth>':'':g | sort -f | \
	uniq -i -d

# prints what was used as Part-Of-Speech <pos> element content
# with a number stating how often it was used
pos-statistics: $(dictname).tei
	grep -o "<pos>.*</pos>" $< | perl -pi -e 's/<pos>(.*)<\/pos>/$$1/;' | sort | uniq -c

###############################################################################
#### create directories where release files are stored
###############################################################################

dirs: #! creates all directories for releasing files
	@if [ ! -d "$(BUILD_DIR)/dict-tgz" ]; then \
		mkdir -p "$(BUILD_DIR)/dict-tgz"; fi
	@if [ ! -d "$(BUILD_DIR)/dict-tbz2" ]; then \
		mkdir "$(BUILD_DIR)/dict-tbz2"; fi


######################################################################
#### targets for c5/dictfmt conversion style into dict database format
######################################################################

$(dictname).c5: $(dictname).tei $(xsldir)/tei2c5.xsl \
	$(xsldir)/inc/teientry2txt.xsl \
	$(xsldir)/inc/teiheader2txt.xsl \
	$(xsldir)/inc/indent.xsl
	if [ "$(firstword $(XSLTPROCESSOR))" == "xsltproc" ]; then \
	  $(XSLTPROCESSOR) --xinclude --stringparam current-date $(date) $(xsldir)/tei2c5.xsl $< >$@; \
	  else \
	  $(XSLTPROCESSOR) $(xsldir)/tei2c5.xsl $< \$$current-date=$(date) >$@; fi

$(dictname)-reverse.c5: $(dictname).tei $(xsldir)/tei2c5-reverse.xsl
	@if [ "$(firstword $(XSLTPROCESSOR))" == "xsltproc" ]; then \
	  $(XSLTPROCESSOR) --stringparam current-date $(date) $(xsldir)/tei2c5-reverse.xsl $< >$@; \
	  else \
	  $(XSLTPROCESSOR) $(xsldir)/tei2c5-reverse.xsl $< \$$current-date=$(date) >$@; fi

# ToDo: doesn't work
reverse: $(dictname)-reverse.c5

%.dict %.index: %.c5 query-dictd
	dictfmt --without-time -t --headword-separator %%% $(DICTFMTFLAGS) $* <$<

%.dict.dz: %.dict
	dictzip -k $<


$(BUILD_DIR)/dict-tgz/freedict-$(dictname)-$(version).tar.gz: \
	$(dictname).dict.dz $(dictname).index
	tar -C .. -cvzf $@ $(addprefix $(notdir $(realpath .))/, $^)

release-dict-tgz: #! prepare the release for the dict format in tar.gz format
release-dict-tgz: dirs \
	$(BUILD_DIR)/dict-tgz/freedict-$(dictname)-$(version).tar.gz

$(BUILD_DIR)/dict-tbz2/freedict-$(dictname)-$(version).tar.bz2: \
	$(dictname).dict.dz $(dictname).index
	tar -C .. -cvjf $@ $(addprefix $(notdir $(realpath .))/, $^)

release-dict-tbz2: #! prepare the release for the dict format in tar.bz2 format
release-dict-tbz2: dirs \
	$(BUILD_DIR)/dict-tbz2/freedict-$(dictname)-$(version).tar.bz2

$(BUILD_DIR)/dict-tbz2/freedict-$(dictname)-$(version)-reverse.tar.bz2: \
	$(dictname)-reverse.dict.dz $(dictname)-reverse.index
	tar -C .. -cvjf $@ $(addprefix $(notdir $(realpath .))/, $^)

# ToDo: reverse target, description, still working?
release-dict-tbz2-reverse: dirs \
	$(BUILD_DIR)/dict-tbz2/freedict-$(dictname)-$(version)-reverse.tar.bz2

######################################
#### targets for evolutionary platform
######################################

date=$(shell date +%G-%m-%d)


install: #! install the dictionary
install: $(dictname).dict.dz $(dictname).index
	install -d $(DESTDIR)/$(PREFIX)/share/dictd
	install -m 644 $^ $(DESTDIR)/$(PREFIX)/share/dictd

uninstall: #! uninstall this dictionary
	-rm $(DESTDIR)/$(PREFIX)/share/dictd/$(dictname).dict.dz $(DESTDIR)/$(DESTDIR)/$(dictname).index
	$(DICTD_RESTART_SCRIPT)

########################
#### maintenance targets
########################

valid.stamp: $(dictname).tei
	xmllint --noout --relaxng freedict-P5.rng $<
	# way 1
	@test -e $(XMLSOC) || (echo "Please set path to xml.soc file!"; exit 1)
	#export SP_ENCODING=XML; \
	#export SP_CHARSET_FIXED=YES; \
	#export SGML_CATALOG_FILES="$(XMLSOC):$(SGML_CATALOG_FILES)"; \
	#$(NSGMLS) -wxml -s -E 10 $(XMLDECLARATION) $(dictname).tei
	#echo "If this file is newer than $(dictname).tei, that is valid XML." >$@
	echo "File is valid TEI XML."

validation: #! validate dictionary with FreeDict's TEI XML subset
validation: valid.stamp

testresult-$(version).log: $(dictname).index $(dictname).dict
	$(FREEDICT_TOOLS)/testing/test-database.pl -f $(dictname) -l $(DICTD_LOCALE) |tee $@ \
	&& exit $${PIPESTATUS[0]}

test: testresult-$(version).log

testresult-$(version)-reverse.log: $(rdictname).index $(rdictname).dict
	$(FREEDICT_TOOLS)/testing/test-database.pl -f $(rdictname) -l $(DICTD_LOCALE) |tee $@ \
	&& exit $${PIPESTATUS[0]}

test-reverse: testresult-$(version)-reverse.log
	
tests: valid.stamp testresult-$(version).log

# Query platform support status
# This yields an exit status of
# 0 for dict supported on this platform
# 1 for dict unsupported on this platform
# 2 FOR unknown platform
query-%:
	@if [ -z "$(findstring $*,$(available_platforms))" ]; then \
	  echo "Unknown platform: $*"; exit 2; fi
	@if [ -n "$(findstring $*,$(UNSUPPORTED_PLATFORMS))" ]; then \
	  echo "Platform $* does not support this dictionary module."; exit 1; fi
	@echo "Platform $* supports this dictionary module."

print-unsupported: #! print unsupported platforms
	@echo -n $(UNSUPPORTED_PLATFORMS)

# this is a "double colon rule"
# adding another "clean::" rule in your Makefile
# allows to extend this with additional commands
#
# for example:
#
# clean::
#	-rm -f delete_this_file.too
clean:: #! clean build files
	rm -f $(dictname).index $(dictname).dict
	rm -f $(dictname).c5 $(dictname).dict.dz testresult-*.log
	rm -f $(dictname)-reverse.c5 $(dictname)-reverse.dict.dz
	rm -f $(dictname)-reverse.index
	rm -f valid.stamp
	rm -f $(BUILD_DIR)/dict-tbz2/freedict-$(dictname)-$(version).tar.bz2
	rm -f $(BUILD_DIR)/dict-tgz/$(dictname)-$(version).tar.gz
	rm -f $(BUILD_DIR)/src/freedict-$(dictname)-$(version).src.tar.bz2
	rm -f $(BUILD_DIR)/src/freedict-$(dictname)-$(version).src.zip
	rm -f $(BUILD_DIR)/tei/$(dictname)-$(version)-tei.tar.bz2

# put all sources of a dictionary module into a tarball for release
# ("distribution").  this only includes the .tei file if it doesn't have to be
# generated from other sources
$(BUILD_DIR)/src/freedict-$(dictname)-$(version).src.tar.bz2: $(DISTFILES)
	@if [ ! -d $(BUILD_DIR)/src ]; then \
		mkdir -p $(BUILD_DIR)/src; fi
	tar -C .. -cvjhf $@ \
		--exclude=.svn --exclude=freedict-*.tar.bz2 --exclude=freedict-*.zip --exclude=.* \
		$(addprefix $(notdir $(realpath .))/, $(DISTFILES))

$(BUILD_DIR)/src/freedict-$(dictname)-$(version).src.zip: $(DISTFILES)
	cd .. && zip -r9 $(subst ../,,$@) $(addprefix $(dictname)/, $(DISTFILES)) \
      -x \*/.svn/\* $(dictname)/freedict-*.tar.bz2 $(dictname)/freedict-*.zip $(dictname)/.* 

release-src: #! create source release tarball
release-src: $(BUILD_DIR)/src/freedict-$(dictname)-$(version).src.tar.bz2 $(BUILD_DIR)/src/freedict-$(dictname)-$(version).src.zip

# the following two targets work like "dist", but include the .tei file
# unconditionally
$(BUILD_DIR)/tei/$(dictname)-$(version)-tei.tar.bz2: $(DISTFILES) $(dictname).tei
	@if [ ! -d $(BUILD_DIR)/tei ]; then \
		mkdir -p $(BUILD_DIR)/tei; fi
	if (echo "$(DISTFILES)" | grep "$(dictname).tei " > /dev/null); then \
		tar -C .. -cvjhf $@ \
			--exclude=.svn --exclude=freedict-*.tar.bz2 --exclude=.* \
			$(addprefix $(notdir $(realpath .))/, $(DISTFILES)); \
	else \
		tar -C .. -cvjhf $@ \
			--exclude=.svn --exclude=freedict-*.tar.bz2 --exclude=.* \
			$(addprefix $(notdir $(realpath .))/, $(DISTFILES) $(dictname).tei); \
	fi

release-tei-tbz2: $(BUILD_DIR)/tei/$(dictname)-$(version)-tei.tar.bz2

#############################
#### targets for rpm packages
#############################

release-rpm: freedict-$(dictname).spec dist
	@if [ ! -d $(BUILD_DIR)/rpm ]; then \
		ln -s /usr/src/packages/RPMS/noarch \
		$(BUILD_DIR)/rpm; fi
	@if [! -x /usr/src/packages/SOURCES/freedict-$(dictname)-$(version).src.tar.bz2 ]; then \
		ln -s $(BUILD_DIR)/src/freedict-$(dictname)-$(version).src.tar.bz2 \
			/usr/src/packages/SOURCES; fi
	rpmbuild --target=noarch -ba freedict-$(dictname).spec

release-rpm-reverse:


############################################
#### targets for (z)bedic on zaurus platform
############################################
# For a broader view, read the FreeDict HOWTO. It takes these steps:
#  1a. apply `sort.xsl'
#  1b. apply `group-homographs-sorted.xsl'
#  1c. link to `tei-wrapper.xml'
#  2a. apply `tei2dic.xsl' to create a bedic format file with newlines
#  2b. convert to Unicode NFC using charlint.pl
#  2c. replace double newlines by NUL bytes and replace \\e by \e using perl
#  3. apply `xerox' that comes with libbedic to generate missing properties
#  4. apply `dictzip' to compress it
#  5. optionally execute dic2ipk.sh to create a Zaurus installation package

sorted.tei: $(dictname).tei $(xsldir)/sort.xsl
	$(XSLTPROCESSOR) $(xsldir)/sort.xsl $< >$@

grouped.tei: sorted.tei $(xsldir)/group-homographs-sorted.xsl
	$(XSLTPROCESSOR) $(xsldir)/group-homographs-sorted.xsl $< >$@

tei-wrapper.xml: $(xsldir)/tei-wrapper.xml
	ln -s $(xsldir)/tei-wrapper.xml

# optional
unwrapped.tei: grouped.tei tei-wrapper.xml
	xmllint --noent tei-wrapper.xml >unwrapped.tei

bedic-precedence: $(dictname).unxeroxed.dic
	@if [ -z "$(LA1locale)" ]; \
	then echo 'Please set LA1locale to the locale of the source language!'; \
	else echo "The output of this should be incorporated appropriately \
into \`tei2dic.xsl':"; \
	$(XEROX) --generate-char-precedence $(LA1locale) $<; fi

$(dictname).escaped.dic: tei-wrapper.xml grouped.tei $(xsldir)/tei2dic.xsl
	$(XSLTPROCESSOR) $(xsldir)/tei2dic.xsl $< >$@

# Charlint - A Character Normalization Tool
# http://www.w3.org/International/charlint/
#
# You may want to adapt this:
unicodedata = $(FREEDICT_TOOLS)/UnicodeData.txt
#unicodedata = /usr/lib/perl5/5.8.1/unicore/UnicodeData.txt
#unicodedata = /usr/share/perl/5.8.8/unicore/UnicodeData.txt
#
$(FREEDICT_TOOLS)/UnicodeData.txt:
	cd $(FREEDICT_TOOLS) && wget ftp://ftp.unicode.org/Public/UNIDATA/UnicodeData.txt
#
charlint_url = http://dev.w3.org/cvsweb/~checkout~/charlint/charlint.pl?rev=1.27&content-type=text/plain&only_with_tag=HEAD
$(FREEDICT_TOOLS)/charlint.pl::
	@if [ ! -x $@ ]; then \
	cd $(FREEDICT_TOOLS) && wget -O $@ '$(charlint_url)' && chmod a+x $@; fi
#
$(CHARLINT_DATA): $(unicodedata)
	$(CHARLINT) -f $< -S $@ -d -D
#
$(CHARLINT):: $(CHARLINT_DATA)

# generate NFC (Canonical Decomposition followed by Canonical Composition)
$(dictname).normalized.dic: $(dictname).escaped.dic $(CHARLINT)
	$(CHARLINT) -s $(CHARLINT_DATA) <$< >$@

$(dictname).unxeroxed.dic: $(dictname).normalized.dic
	perl -pi -e 's/\\0/\x00/gm; s/\\e/\e/gm;' <$< >$@

# old style:
#%.unxeroxed.dic: %.tei
#	tei2dic.py $< $*.unxeroxed.dic

$(BUILD_DIR)/dic/freedict-%-$(version).dic: %.unxeroxed.dic
	@if [ ! -d $(BUILD_DIR)/dic ]; then \
		mkdir $(BUILD_DIR)/dic; fi
	$(XEROX) $*.unxeroxed.dic $@

release-bedic: $(BUILD_DIR)/dic/freedict-$(dictname)-$(version).dic.dz

# optional
$(BUILD_DIR)/ipk/%.ipk: $(BUILD_DIR)/dic/%.dic.dz
	@if [ ! -d $(BUILD_DIR)/ipk ]; then \
		mkdir $(BUILD_DIR)/ipk; fi
	cd $(BUILD_DIR)/ipk && ln -s `dic2ipk.sh $<` $@

# optional
release-zaurus: $(BUILD_DIR)/ipk/freedict-$(dictname)-$(version).ipk

clean::
	rm -f sorted.tei grouped.tei tei-wrapper.xml unwrapped.tei \
	$(dictname).escaped.dic $(dictname).normalized.dic $(dictname).unxeroxed.dic \
	$(BUILD_DIR)/dic/freedict-$(dictname)-$(version).dic \
	$(BUILD_DIR)/dic/freedict-$(dictname)-$(version).dic.dz

##################################
#### targets for StarDict platform
##################################

# This tool comes with stardict
DICTD2DIC ?= dictd2dic

# This is hardcoded into dictd2dic :(
stardict_prefix = dictd_www.dict.org_

# idxhead is required to preexist by dictd2dic. The reason is not documented.
$(dictname).idxhead:
	echo -n "" > $@

$(stardict_prefix)$(dictname).idx $(stardict_prefix)$(dictname).dict.dz \
	dictd2dic.out: $(dictname).index $(dictname).dict $(dictname).idxhead
	$(DICTD2DIC) $(dictname) >dictd2dic.out
	gzip -9 $(stardict_prefix)$(dictname).idx

# $(wordcount) and $(idxfilesize) are a target-specific variables
$(stardict_prefix)$(dictname).ifo: \
	wordcount=$(word 2, $(shell tail -n1 dictd2dic.out))

$(stardict_prefix)$(dictname).ifo: \
	idxfilesize=$(strip $(shell zcat $(stardict_prefix)$(dictname).idx | wc -c))

authorresp.out: $(dictname).tei $(xsldir)/getauthor.xsl
	$(XSLTPROCESSOR) $(xsldir)/getauthor.xsl $< >$@

title.out: $(dictname).tei $(xsldir)/gettitle.xsl
	$(XSLTPROCESSOR) $(xsldir)/gettitle.xsl $< >$@

sourceurl.out: $(dictname).tei $(xsldir)/getsourceurl.xsl
	$(XSLTPROCESSOR) $(xsldir)/getsourceurl.xsl $< >$@

$(stardict_prefix)$(dictname).ifo: $(stardict_prefix)$(dictname).idx \
	dictd2dic.out authorresp.out title.out sourceurl.out
	@echo "Generating $@..."
	@echo "StarDict's dict ifo file" > $@
	@echo "version=2.4.2" >> $@
	@echo "wordcount=$(wordcount)" >> $@
	@echo "idxfilesize=$(idxfilesize)" >> $@
	@echo "bookname=$(shell cat title.out)" >> $@
	@echo "author=$(shell sed -e "s/ <.*>//" <authorresp.out)" >> $@
	@echo "email=$(shell sed -e "s/.* <\(.*\)>/\1/" <authorresp.out)" >> $@
	@echo "website=$(shell cat sourceurl.out)" >> $@
	@echo "description=Converted to StarDict format by freedict.org" >> $@
	@echo "date=$(shell date +%G.%m.%d)" >> $@
	@echo "sametypesequence=m" >> $@
	@cat $@

stardict: $(stardict_prefix)$(dictname).ifo

$(BUILD_DIR)/stardict/freedict-$(dictname)-$(version)-stardict.tar.bz2: \
       	$(stardict_prefix)$(dictname).ifo \
	$(stardict_prefix)$(dictname).dict.dz \
	$(stardict_prefix)$(dictname).idx.gz
	@if [ ! -d $(BUILD_DIR)/stardict ]; then \
		mkdir $(BUILD_DIR)/stardict; fi
	tar -C .. -cvjf \
	  $(BUILD_DIR)/stardict/freedict-$(dictname)-$(version)-stardict.tar.bz2 \
	  $(addprefix $(notdir $(realpath .))/, $^)

release-stardict: \
	$(BUILD_DIR)/stardict/freedict-$(dictname)-$(version)-stardict.tar.bz2

clean::
	rm -f $(dictname).idxhead $(stardict_prefix)$(dictname).idx.gz \
	$(stardict_prefix)$(dictname).dict.dz $(stardict_prefix)$(dictname).ifo \
	$(BUILD_DIR)/stardict/freedict-$(dictname)-$(version)-stardict.tar.bz2 \
	dictd2dic.out authorresp.out title.out sourceurl.out

#####################
#### targets for ding
#####################

%.ding: %.tei $(xsldir)/tei2ding.xsl
	$(XSLTPROCESSOR) $(xsldir)/tei2ding.xsl $< >$@

clean::
	rm -f *.ding

#######################
#### Phonetics import
#######################

supported_phonetics ?= $(shell PATH="$(FREEDICT_TOOLS):$(PATH)" teiaddphonetics -li)

la1 := $(shell export V=$(dictname); echo $${V:0:3})
#la2 := $(shell export V=$(dictname); echo $${V:4:3})

ifneq (,$(findstring $(la1),$(supported_phonetics)))

# TEIADDPHONETICS ?= -v
$(dictname).tei: $(dictname)-nophon.tei
	teiaddphonetics $(TEIADDPHONETICS) -i $< -ou $@ -mbrdico-path $(MBRDICO_PATH)

endif


#######################
#### Makefile-technical
#######################

# should be default, but is not for make-historic reasons
.DELETE_ON_ERROR:

.PHONY: all version status sourceURL maintainer dirs install uninstall \
	release releaase-src release-dict-tbz2 release-dict-tbz2-reverse release-dict-tgz \
	release-dict-tgz-reverse release-zaurus \
	release-rpm release-rpm-reverse release-rpm-freedict-tools \
	clean dist validation query-% print-unsupported \
	test test-reverse test-reverse-oldstyle tests \
	find-homographs pos-statistics \
	stardict release-stardict release-tei-tbz2

