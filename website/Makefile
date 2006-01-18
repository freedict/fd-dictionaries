freedict.po: freedict.pot
	msgmerge -U locale/de_DE/LC_MESSAGES/freedict.po freedict.pot
	msgmerge -U locale/kha_IN/LC_MESSAGES/freedict.po freedict.pot
	msgmerge -U locale/ru_RU/LC_MESSAGES/freedict.po freedict.pot
	msgmerge -U locale/ku_TR/LC_MESSAGES/freedict.po freedict.pot

~/dict/CVS/freedict-editor/help/C/html/index.html:
	$(MAKE) -C ~/dict/CVS/freedict-editor/help/C html

editordoc.html: ~/dict/CVS/freedict-editor/help/C/html/index.html
	ln -s $< $@

freedict.pot: *.php inc/*.php
	xgettext -o freedict.pot -j *.php inc/*.php

locale/%/LC_MESSAGES/freedict.mo: locale/%/LC_MESSAGES/freedict.po
	msgfmt -c --statistics -o $@ $<

de: locale/de_DE/LC_MESSAGES/freedict.mo

kha: locale/kha_IN/LC_MESSAGES/freedict.mo

ru: locale/ru_RU/LC_MESSAGES/freedict.mo

ku: locale/ku_TR/LC_MESSAGES/freedict.mo

.PHONY: freedict.po ~/dict/CVS/freedict-editor/help/C/html/index.html
