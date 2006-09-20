all: freedict.po editordoc.html howto freedict-database.xml flags-bedic.php \
	flags-evolutionary.php freedict.pot de kha ru ku fr ar

freedict.po: freedict.pot
	msgmerge -U locale/ar_EG/LC_MESSAGES/freedict.po $<
	msgmerge -U locale/de_DE/LC_MESSAGES/freedict.po $<
	msgmerge -U locale/kha_IN/LC_MESSAGES/freedict.po $<
	msgmerge -U locale/ru_RU/LC_MESSAGES/freedict.po $<
	msgmerge -U locale/ku_TR/LC_MESSAGES/freedict.po $<
	msgmerge -U locale/fr_FR/LC_MESSAGES/freedict.po $<

../freedict-editor/help/C/html/index.html:
	$(MAKE) -C ../freedict-editor/help/C html

editordoc.html: ../freedict-editor/help/C/html/index.html
	test ! -e $@ && ln -s $< $@

howto:
	ln -s ../howto/xhtml $@

freedict-database.xml:
	ln -s ../$@

flags-bedic.php:
	ln -s flags-dict-tgz.php $@
	
flags-evolutionary.php:
	ln -s flags-dict-tgz.php $@

freedict.pot: *.php inc/*.php
	xgettext -o freedict.pot -j *.php inc/*.php

locale/%/LC_MESSAGES/freedict.mo: locale/%/LC_MESSAGES/freedict.po
	msgfmt -c --statistics -o $@ $<

de: locale/de_DE/LC_MESSAGES/freedict.mo

kha: locale/kha_IN/LC_MESSAGES/freedict.mo

ru: locale/ru_RU/LC_MESSAGES/freedict.mo

ku: locale/ku_TR/LC_MESSAGES/freedict.mo

fr: locale/fr_FR/LC_MESSAGES/freedict.mo

ar: locale/ar_EG/LC_MESSAGES/freedict.mo

clean:
	-rm -f locale/ru_RU/LC_MESSAGES/freedict.mo \
	locale/fr_FR/LC_MESSAGES/freedict.mo \
	locale/ku_TR/LC_MESSAGES/freedict.mo \
	locale/kha_IN/LC_MESSAGES/freedict.mo \
	locale/ar_EG/LC_MESSAGES/freedict.mo \
	locale/de_DE/LC_MESSAGES/freedict.mo
	
.PHONY: all freedict.po ~/dict/CVS/freedict-editor/help/C/html/index.html \
	de kha ru ku fr ar

