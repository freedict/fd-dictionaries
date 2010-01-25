all: freedict.po editordoc.html howto freedict-database.xml flags-bedic.php \
	flags-evolutionary.php freedict.pot de kha ru ku fr ar bg lt

sources = $(wildcard *.php) $(wildcard inc/*.php)

freedict.po: freedict.pot
	msgmerge -U locale/ar_EG/LC_MESSAGES/freedict.po $<
	msgmerge -U locale/de_DE/LC_MESSAGES/freedict.po $<
	msgmerge -U locale/kha_IN/LC_MESSAGES/freedict.po $<
	msgmerge -U locale/ru_RU/LC_MESSAGES/freedict.po $<
	msgmerge -U locale/ku_TR/LC_MESSAGES/freedict.po $<
	msgmerge -U locale/fr_FR/LC_MESSAGES/freedict.po $<
	msgmerge -U locale/bg_BG/LC_MESSAGES/freedict.po $<
	msgmerge -U locale/lt_LT/LC_MESSAGES/freedict.po $<

../freedict-editor/help/C/html/index.html:
	$(MAKE) -C ../freedict-editor/help/C html

editordoc.html: ../freedict-editor/help/C/html/index.html
	test -e $@ || ln -s $< $@

howto:
	ln -s ../howto/xhtml $@

freedict-database.xml:
	ln -s ../$@

flags-bedic.php:
	ln -s flags-dict-tgz.php $@
	
flags-evolutionary.php:
	ln -s flags-dict-tgz.php $@

freedict.pot: $(sources)
	xgettext -o $@ --copyright-holder="freedict.org" \
	  --msgid-bugs-address="freedict-beta@lists.sf.net" *.php inc/*.php

locale/%/LC_MESSAGES/freedict.mo: locale/%/LC_MESSAGES/freedict.po
	msgfmt -c --statistics -o $@ $<

de: locale/de_DE/LC_MESSAGES/freedict.mo

kha: locale/kha_IN/LC_MESSAGES/freedict.mo

ru: locale/ru_RU/LC_MESSAGES/freedict.mo

ku: locale/ku_TR/LC_MESSAGES/freedict.mo

fr: locale/fr_FR/LC_MESSAGES/freedict.mo

ar: locale/ar_EG/LC_MESSAGES/freedict.mo

bg: locale/bg_BG/LC_MESSAGES/freedict.mo

lt: locale/lt_LT/LC_MESSAGES/freedict.mo

clean:
	-rm -f locale/ru_RU/LC_MESSAGES/freedict.mo \
	locale/fr_FR/LC_MESSAGES/freedict.mo \
	locale/ku_TR/LC_MESSAGES/freedict.mo \
	locale/kha_IN/LC_MESSAGES/freedict.mo \
	locale/ar_EG/LC_MESSAGES/freedict.mo \
	locale/de_DE/LC_MESSAGES/freedict.mo \
	locale/bg_BG/LC_MESSAGES/freedict.mo \
	locale/lt_LT/LC_MESSAGES/freedict.mo

.PHONY: all freedict.po ../freedict-editor/help/C/html/index.html \
	de kha ru ku fr ar bg lt

