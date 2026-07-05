BUILD ?= ../build
XMLLINT ?= xmllint
JING ?= jing
CURL ?= curl

ODD := freedict-P5.xml
ODD_SCHEMA := $(BUILD)/tei_odds.rng
ODD_SCHEMA_URL := https://tei-c.org/release/xml/tei/custom/schema/relaxng/tei_odds.rng

.PHONY: all validate-odd clean

all: validate-odd

$(ODD_SCHEMA):
	$(CURL) -fL -o $@ $(ODD_SCHEMA_URL)

validate-odd: $(ODD_SCHEMA) $(ODD)
	$(JING) $(ODD_SCHEMA) $(ODD)

clean:
	rm -f $(ODD_SCHEMA)
