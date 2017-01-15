# NOTE: the assumptions about FREEDICTDIR from this script are WRONG
FREEDICTDIR ?= $(realpath ../..)
erganetoolsdir = $(realpath $(FREEDICTDIR)/tools/ergane)

ifeq (,$(findstring $(la1),$(supported_phonetics)))
# phonetics for language $(la1) not supported - generate final .tei file
# directly, without extension
erganeexport_extension ?=
else
# generate a file with -nophon extension; it will be picked up by the phonetics
# import rule
erganeexport_extension ?= -nophon
endif

$(erganetoolsdir)/zip/%.zip:
	@if [ ! -d $(erganetoolsdir)/zip ]; then \
	  mkdir -p $(erganetoolsdir)/zip; fi
	cd $(erganetoolsdir)/zip && \
	  wget --timestamping http://download.travlang.com/files/$*.zip

# ISO639-2 gives two codes for Czech and Swedish
$(erganetoolsdir)/zip/cze.zip: $(erganetoolsdir)/zip/ces.zip
	ln -s ces.zip $@

$(erganetoolsdir)/zip/swe.zip: $(erganetoolsdir)/zip/sve.zip
	ln -s sve.zip $@

# FreeDict doesn't adhere to ISO639-2 here
$(erganetoolsdir)/zip/nld.zip: $(erganetoolsdir)/zip/dut.zip
	ln -s dut.zip $@

# FreeDict uses "sco" instead of "gae" - a mistake
# "gla" was also suggested - but it is not in ISO639-2
$(erganetoolsdir)/zip/sco.zip: $(erganetoolsdir)/zip/gae.zip
	ln -s gae.zip $@

$(erganetoolsdir)/unzip/%.mdb: $(erganetoolsdir)/zip/%.zip
	@if [ ! -d $(erganetoolsdir)/unzip ]; then \
	  mkdir -p $(erganetoolsdir)/unzip; fi
	unzip -o $< -d $(erganetoolsdir)/unzip
	# the file inside the archive is older than the archive
	touch $@

$(erganetoolsdir)/jet4/%-jet4.mdb: $(erganetoolsdir)/unzip/%.mdb
	@if [ ! -d $(erganetoolsdir)/jet4 ]; then \
	  mkdir -p $(erganetoolsdir)/jet4; fi
	$(erganetoolsdir)/convert-with-access-to-jet4 "$<" "$@"

# name of the postgresql database into which to import the data
#PSQLFLAGS += -d $(USERNAME)

psql = psql $(PSQLFLAGS)

#tables_exist = $(shell psql -c "\\d woordenboek" 2>/dev/null)
# Th columns "SortKey" and "Uitspraak" are missing here, because the
# Woordenboek table of jap.mdb lacks them and we don't need them.
columns = KeyNo, EspKey, XEntry, Type, GType, FType, Omschr, Freq, Volgorde, \
Opm, Opm2

$(erganetoolsdir)/%.schema: $(erganetoolsdir)/jet4/%-jet4.mdb
	mdb-schema $< postgres >$@

$(erganetoolsdir)/%.schema.postgresql: $(erganetoolsdir)/%.schema \
	$(erganetoolsdir)/dan.schema.diff
	cp $< $@
	cd $(erganetoolsdir) && patch -p1 <$(erganetoolsdir)/dan.schema.diff

$(erganetoolsdir)/talen.schema.postgresql: $(erganetoolsdir)/jet4/epo-jet4.mdb
	mdb-schema -T Talen $< postgres >$@

$(erganetoolsdir)/kb_map.schema.postgresql: $(erganetoolsdir)/jet4/epo-jet4.mdb
	mdb-schema -T KB_Map $< postgres >$@

$(erganetoolsdir)/stamps/tables-created: \
	$(erganetoolsdir)/dan.schema.postgresql \
	$(erganetoolsdir)/talen.schema.postgresql \
	$(erganetoolsdir)/kb_map.schema.postgresql
	if [ ! -d $(erganetoolsdir)/stamps ]; then \
	  mkdir -p $(erganetoolsdir)/stamps; fi
	cat $^ | $(psql)
	touch $@

$(erganetoolsdir)/%.csv: $(erganetoolsdir)/jet4/%-jet4.mdb
	# mdb-export always exports all columns, but the
	# table schemata in Ergane differ. so it cannot be used here.
	# note: mdb-sql treats column names case sensitively
	echo "SELECT $(columns) FROM woordenboek" | \
	mdb-sql -HFp $< >$@
	# fix a bug in eng.mdb, entry "porcupine"
	perl -pi -e "s/\r\n//gs" $@

$(erganetoolsdir)/stamps/%-is-in-postgres: $(erganetoolsdir)/%.csv \
	$(erganetoolsdir)/stamps/tables-created
	echo "ALTER TABLE Woordenboek ALTER COLUMN language \
	SET DEFAULT '$*';" | $(psql)
	cat $< | grep -v "^$$" | \
	$(psql) -c "COPY Woordenboek ($(columns)) FROM STDIN NULL ''"
	echo "ALTER TABLE Woordenboek ALTER COLUMN language DROP DEFAULT;" | \
	  $(psql)
	touch $@

$(erganetoolsdir)/stamps/talen-is-in-postgres: \
	$(erganetoolsdir)/jet4/epo-jet4.mdb \
	$(erganetoolsdir)/stamps/tables-created
	echo "SELECT * FROM Talen" | \
	mdb-sql -HFp $< | \
	grep -v "^$$" | \
	$(psql) -c "COPY Talen (TaalCode, TekstNr, Schrift) FROM STDIN NULL ''"
	touch $@

$(erganetoolsdir)/stamps/kb_map-is-in-postgres: \
	$(erganetoolsdir)/jet4/epo-jet4.mdb \
	$(erganetoolsdir)/stamps/tables-created
	echo "SELECT * FROM KB_Map" | \
	mdb-sql -HFp $< | \
	grep -v "^$$" | \
	$(psql) -c "COPY KB_Map (Schrift, KeyASCII, UnicodeVal) FROM STDIN NULL ''"
	touch $@

.PRECIOUS: $(erganetoolsdir)/stamps/%-is-in-postgres $(erganetoolsdir)/%.csv \
	$(erganetoolsdir)/zip/%.zip

# this is the target to build the actual .tei file
%$(erganeexport_extension).tei: LA1=$(shell export LS="$*" && echo "$${LS:0:3}")
%$(erganeexport_extension).tei: LA2=$(shell export LS="$*" && echo "$${LS:4:3}")
.SECONDEXPANSION:
%$(erganeexport_extension).tei: \
	$(erganetoolsdir)/stamps/$$(LA1)-is-in-postgres \
	$(erganetoolsdir)/stamps/$$(LA2)-is-in-postgres \
	$(erganetoolsdir)/stamps/talen-is-in-postgres \
	$(erganetoolsdir)/stamps/kb_map-is-in-postgres
	if [ -r $(LA1)-$(LA2).tei.header ] ; then \
		cp $(LA1)-$(LA2).tei.header $@; \
	else cp $(erganetoolsdir)/default.tei.header $@.tei; fi
	echo "SELECT * FROM woordenboek AS w, woordenboek AS x \
	WHERE w.language='$(LA1)' AND x.language='$(LA2)' \
	AND w.espkey=x.espkey ORDER BY w.xentry, w.type, w.gtype" \
	| psql --no-align --tuples-only --field-separator '	' | \
	ergane-records2tei -v --source-language $(LA1) \
	  --destination-language $(LA2) >>$@
	echo '</body></text></TEI.2>' >>$@

ergane-zip-all:
	cd $(erganetoolsdir)/zip && \
	  wget --timestamping --recursive --level 1 --accept "???.zip" \
	    --no-directories http://download.travlang.com/files/

ergane-zip-update:
	cd $(erganetoolsdir)/zip && for i in ???.zip; do \
	  wget --timestamping http://download.travlang.com/files/$$i; \
	  done

ergane-jet4-update: ergane-zip-update
	for i in $(erganetoolsdir)/zip/???.zip; do \
	  trimbegin=$${i##$(erganetoolsdir)/zip/} && \
	  trimend=$${trimbegin%%.zip} && \
	  $(MAKE) $(erganetoolsdir)/jet4/$$trimend-jet4.mdb; \
	  done

ergane-jet4-all: ergane-zip-all ergane-jet4-update

# for teidiff
old.tei: $(old)
	xmllint --noblanks $(old) >$@

new-oldtei.tei: $(dictname).tei
	xsltproc --nodtdattr $(erganetoolsdir)/newtei2oldtei.xsl $< >$@

new.tei: new-oldtei.tei
	xmllint --noblanks $< >$@

diff: old.tei new.tei
	teidiff $(TEIDIFF) old.tei new.tei -o files

clean::
	rm -f $(erganetoolsdir)/*.schema $(erganetoolsdir)/*.sql \
	$(erganetoolsdir)/*.postgresql $(erganetoolsdir)/*.csv \
	$(dictname).tei $(dictname)-nophon.tei  new.tei old.tei \
	old.tei-new.tei-* new-oldtei.tei
	if [ -r $(erganetoolsdir)/stamps/tables-created ] ; then \
	  echo "DROP TABLE Woordenboek, VersieInfo, altspellings, vfilter" | \
	  $(psql) && rm -f $(erganetoolsdir)/stamps/tables-created \
	  $(erganetoolsdir)/stamps/*-is-in-postgres; fi

.PHONY: clean ergane-zip-update diff
.PRECIOUS: $(erganetoolsdir)/zip/%.zip $(erganetoolsdir)/unzip/%.mdb

# vim:filetype=make:

