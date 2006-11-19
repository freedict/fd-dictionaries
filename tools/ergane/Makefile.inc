erganetoolsdir = $(FREEDICTDIR)/tools/ergane

ifeq (,$(findstring $(la1),$(supported_phonetics)))
# phonetics for language $(la1) not supported - generate final .tei file
# directly, without extension
erganeexport_extension ?=
else
# generate a file with -nophon extension; it will be picked up by the phonetics
# import rule
erganeexport_extension ?= -nophon
endif

$(erganetoolsdir)/zip/???.zip:
	@if [ ! -d $(erganetoolsdir)/zip ]; then \
	  mkdir -p $(erganetoolsdir)/zip; fi
	wget --timestamping http://download.travlang.com/files/???.zip

$(erganetoolsdir)/unzip/%.mdb: $(erganetoolsdir)/zip/%.zip
	@if [ ! -d $(erganetoolsdir)/unzip ]; then \
	  mkdir -p $(erganetoolsdir)/unzip; fi
	unzip -o $< -d $(erganetoolsdir)/unzip
	# the file inside the archive is older than the archive
	touch $@

$(erganetoolsdir)/jet4/%-jet4.mdb: $(erganetoolsdir)/unzip/%.mdb
	@if [ ! -d $(erganetoolsdir)/jet4 ]; then \
	  mkdir -p $(erganetoolsdir)/jet4; fi
	$(erganetoolsdir)/convert-with-access-to-jet4 $< $@

# name of the postgresql database into which to import the data
#PSQLFLAGS += -d $(USERNAME)

psql = psql $(PSQLFLAGS)

#tables_exist = $(shell psql -c "\\d woordenboek" 2>/dev/null)
columns = KeyNo, EspKey, XEntry, Type, GType, FType, Omschr, Freq, Volgorde, \
Opm, Opm2, SortKey, Uitspraak

$(erganetoolsdir)/%.schema: $(erganetoolsdir)/jet4/%-jet4.mdb
	mdb-schema $< postgres >$@

$(erganetoolsdir)/%.schema.postgresql: $(erganetoolsdir)/%.schema \
        $(erganetoolsdir)/dan.schema.diff
	cp $< $@
	cd $(erganetoolsdir) && patch -p1 <$(erganetoolsdir)/dan.schema.diff

$(erganetoolsdir)/stamps/tables-created: $(erganetoolsdir)/dan.schema.postgresql
	if [ ! -d $(erganetoolsdir)/stamps ]; then \
	  mkdir -p $(erganetoolsdir)/stamps; fi
	$(psql) <$<
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

.PRECIOUS: $(erganetoolsdir)/stamps/%-is-in-postgres $(erganetoolsdir)/%.csv

# this is the target to build the actual .tei file
%$(erganeexport_extension).tei: LA1=$(shell export LS="$*" && echo "$${LS:0:3}")
%$(erganeexport_extension).tei: LA2=$(shell export LS="$*" && echo "$${LS:4:3}")
.SECONDEXPANSION:
%$(erganeexport_extension).tei: $(erganetoolsdir)/stamps/$$(LA1)-is-in-postgres \
       $(erganetoolsdir)/stamps/$$(LA2)-is-in-postgres
	if [ -r $(LA1)-$(LA2).tei.header ] ; then \
		cp $(LA1)-$(LA2).tei.header $@; \
	else cp $(erganetoolsdir)/default.tei.header $@.tei; fi
	echo "SELECT * FROM woordenboek AS w, woordenboek AS x \
	WHERE w.language='$(LA1)' AND x.language='$(LA2)' \
	AND w.espkey=x.espkey ORDER BY w.xentry, w.type, w.gtype" \
	| psql --no-align --tuples-only --field-separator '	' | \
	$(toolsdir)/ergane-records2tei >>$@
	# Footer
	echo '</body></text></TEI.2>' >>$@

ergane-zip-update:
	cd $(erganetoolsdir)/zip && for i in ???.zip; do \
	  wget --timestamping http://download.travlang.com/files/$$i; \
	  done

# for teidiff
old.tei: $(old)
	xmllint --noblanks $(old) >$@

new-oldtei.tei: $(dictname).tei
	xsltproc --nodtdattr $(erganetoolsdir)/newtei2oldtei.xsl $< >$@

new.tei: new-oldtei.tei
	xmllint --noblanks $< >$@

diff: old.tei new.tei
	$(toolsdir)/teidiff old.tei new.tei -o files

clean::
	rm -f $(erganetoolsdir)/*.schema $(erganetoolsdir)/*.sql \
	$(erganetoolsdir)/*.postgresql $(erganetoolsdir)/*.csv \
	$(dictname).tei new.tei old.tei old.tei-new.tei-* new-oldtei.tei
	if [ -r $(erganetoolsdir)/stamps/tables-created ] ; then \
	  echo "DROP TABLE Woordenboek, VersieInfo, altspellings, vfilter" | \
	  $(psql) && rm $(erganetoolsdir)/stamps/tables-created \
	  $(erganetoolsdir)/stamps/*-is-in-postgres; fi

.PHONY: clean ergane-zip-update diff

# vim:filetype=make:

