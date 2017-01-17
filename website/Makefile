LOCALES=$(wildcard locale/*_*)
POS=$(addsuffix /LC_MESSAGES/freedict.po,$(LOCALES))
MOS=$(addsuffix /LC_MESSAGES/freedict.mo,$(LOCALES))

all: editordoc.html freedict-database.xml flags-bedic.php \
	flags-evolutionary.php freedict.pot $(MOS)

sources = $(wildcard *.php) $(wildcard inc/*.php)

locale/%/LC_MESSAGES/freedict.po: freedict.pot
	msgmerge -U locale/$*/LC_MESSAGES/freedict.po $<
	touch $@ # because msgmerge doesn't do this if the .po didn't change

../freedict-editor/configure: ../freedict-editor/autogen.sh
	cd ../freedict-editor && ./autogen.sh

../freedict-editor/Makefile: ../freedict-editor/configure
	cd ../freedict-editor && ./configure

../freedict-editor/help/C/html/index.html: ../freedict-editor/Makefile
	$(MAKE) -C ../freedict-editor/help/C html

editordoc.html: ../freedict-editor/help/C/html/index.html
	test -e $@ || ln -s $< $@

freedict-database.xml:
	ln -s ../$@

flags-bedic.php:
	ln -s flags-dict-tgz.php $@

flags-evolutionary.php:
	ln -s flags-dict-tgz.php $@

freedict.pot: $(sources)
	xgettext --from-code=utf-8 -o $@ --copyright-holder="freedict.org" \
	  --msgid-bugs-address="freedict-beta@lists.sf.net" *.php inc/*.php

locale/%/LC_MESSAGES/freedict.mo: locale/%/LC_MESSAGES/freedict.po
	msgfmt -c --statistics -o $@ $<

clean:
	-rm -f $(MOS)

.PHONY: all clean

