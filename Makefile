validate: freedict-database.xml freedict-database.rng
	xmllint --noout --relaxng freedict-database.rng $<

DICTS=$(shell find . -maxdepth 1 -name '???-???' -printf "%f ")

$(DICTS): timestamp
	$(MAKE) -C $@ $@.dict.dz

timestamp:
	touch $@

all-dzs: timestamp $(DICTS)

.PHONY: update-fd-database-with-releases upload-frs debian-build-dep validate all-dzs

