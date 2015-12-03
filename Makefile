update-fd-database-with-releases:
	tools/extractdata.pl -r

debian-build-dep:
	sudo -u root aptitude install libxml-dom-perl dictfmt xsltproc \
	autoconf autotools-dev libxslt-dev libgtkhtml3.14-dev \
	libglade2-dev scrollkeeper xmlto openoffice.org-draw \
	libapache2-mod-php5 realpath dbview intltool rsync dictzip \
	libxml-libxml-perl opensp git

SFACCOUNT ?= micha137

upload-frs:
	rsync --archive --partial --progress --protect-args --rsh=ssh frs/freedict/ "$(SFACCOUNT),freedict@frs.sourceforge.net:/home/frs/project/f/fr/freedict/"

validate: freedict-database.xml freedict-database.rng
	xmllint --noout --relaxng freedict-database.rng $<

DICTS=$(shell find . -maxdepth 1 -name '???-???' -printf "%f ")

$(DICTS): timestamp
	$(MAKE) -C $@ $@.dict.dz

timestamp:
	touch $@

all-dzs: timestamp $(DICTS)

.PHONY: update-fd-database-with-releases upload-frs debian-build-dep validate all-dzs

