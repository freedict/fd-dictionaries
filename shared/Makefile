BUILD ?= ../build
XMLLINT ?= xmllint
JING ?= jing
CURL ?= curl
JAVA ?= java
UNZIP ?= unzip
ANT ?= ant
APT_CACHE ?= apt-cache
DPKG ?= dpkg

ODD := freedict-P5.xml
ODD_SCHEMA := $(BUILD)/tei_odds.rng
ODD_SCHEMA_URL := https://tei-c.org/release/xml/tei/custom/schema/relaxng/tei_odds.rng
P5SUBSET := $(BUILD)/p5subset.xml
P5SUBSET_URL := https://tei-c.org/release/xml/tei/odd/p5subset.xml

GENERATED_SCHEMAS := freedict-P5.rng freedict-P5.dtd freedict-P5.sch

# required for generation from ODD → RNG, DTD and friends
MIN_SAXON_VERSION ?= 12.0
SAXON_VERSION ?= 13.0
SAXON_JAR := $(BUILD)/Saxon-HE-$(SAXON_VERSION).jar
SAXON_URL := https://repo1.maven.org/maven2/net/sf/saxon/Saxon-HE/$(SAXON_VERSION)/Saxon-HE-$(SAXON_VERSION).jar

XMLRESOLVER_VERSION ?= 6.0.23
XMLRESOLVER_JAR := $(BUILD)/xmlresolver-$(XMLRESOLVER_VERSION).jar
XMLRESOLVER_DATA_JAR := $(BUILD)/xmlresolver-$(XMLRESOLVER_VERSION)-data.jar
XMLRESOLVER_URL := https://repo1.maven.org/maven2/org/xmlresolver/xmlresolver/$(XMLRESOLVER_VERSION)/xmlresolver-$(XMLRESOLVER_VERSION).jar
XMLRESOLVER_DATA_URL := https://repo1.maven.org/maven2/org/xmlresolver/xmlresolver/$(XMLRESOLVER_VERSION)/xmlresolver-$(XMLRESOLVER_VERSION)-data.jar
SAXON_CP := $(SAXON_JAR):$(XMLRESOLVER_JAR):$(XMLRESOLVER_DATA_JAR)
SAXON_CP_ABS := $(abspath $(SAXON_JAR)):$(abspath $(XMLRESOLVER_JAR)):$(abspath $(XMLRESOLVER_DATA_JAR))
ANT_XML_RESOLVER_JAR ?= $(firstword $(wildcard /usr/share/java/xml-resolver.jar /usr/share/java/xml-resolver-*.jar /usr/share/java/xml-commons-resolver*.jar))

TEI_XSL_VERSION ?= 7.60.0
TEI_XSL_ARCHIVE := $(BUILD)/tei-xsl-$(TEI_XSL_VERSION).zip
TEI_XSL_DIR := $(BUILD)/tei-xsl-$(TEI_XSL_VERSION)
TEI_XSL_STYLESHEET_DIR := $(abspath $(TEI_XSL_DIR)/xml/tei/stylesheet)
TEI_XSL_URL := https://github.com/TEIC/Stylesheets/releases/download/v$(TEI_XSL_VERSION)/tei-xsl-$(TEI_XSL_VERSION).zip

LOCAL_SAXON_JAR := $(firstword $(wildcard /usr/share/java/Saxon-HE.jar /usr/share/java/saxon-he.jar))
SCHEMA_IDENT ?= freedict-P5
ANT_LIB_CP := $(SAXON_CP_ABS):$(ANT_XML_RESOLVER_JAR)
SCHEMA_ANT_COMMON := -f build-to.xml -lib "$(ANT_LIB_CP)" -Dprofile=default -DselectedSchema=$(SCHEMA_IDENT) -DdefaultSource=file://$(abspath $(P5SUBSET))
SCHEMA_ANT_COMMON += -DinputFile="$(abspath $(ODD))"

.PHONY: all validate-odd schemas dependencies check-dependencies fetch-dependencies clean

all: validate-odd

schemas: dependencies validate-odd $(GENERATED_SCHEMAS)

$(ODD_SCHEMA):
	mkdir -p $(BUILD)
	$(CURL) -fL -o $@ $(ODD_SCHEMA_URL)

validate-odd: $(ODD_SCHEMA) $(ODD)
	$(JING) $(ODD_SCHEMA) $(ODD)

dependencies: check-dependencies fetch-dependencies

check-dependencies:
	@set -eu; \
	echo "Checking schema generation dependencies"; \
	if [ -n "$(LOCAL_SAXON_JAR)" ]; then \
		version=`$(JAVA) -cp "$(LOCAL_SAXON_JAR)" net.sf.saxon.Transform '-?' 2>&1 | sed -n 's/^Saxon[^ ]*HE \([^ ]*\).*/\1/p' | sed 's/J$$//'`; \
		echo "Installed Saxon: $$version ($(LOCAL_SAXON_JAR))"; \
		if command -v $(DPKG) >/dev/null 2>&1 && $(DPKG) --compare-versions "$$version" ge "$(MIN_SAXON_VERSION)"; then \
			echo "Installed Saxon is new enough."; \
		else \
			echo "Installed Saxon is older than required $(MIN_SAXON_VERSION)."; \
		fi; \
	else \
		echo "Installed Saxon: not found"; \
	fi; \
	if command -v $(APT_CACHE) >/dev/null 2>&1; then \
		echo "Debian package candidates:"; \
		$(APT_CACHE) policy libsaxonhe-java ant tei-xsl 2>/dev/null | sed 's/^/  /'; \
	fi; \
	if command -v $(ANT) >/dev/null 2>&1; then \
		$(ANT) -version; \
	else \
		echo "Installed Ant: not found"; \
		echo "Ant is a hard dependency."; \
		if command -v $(APT_CACHE) >/dev/null 2>&1; then \
			echo "Install it with: sudo apt install ant"; \
		fi; \
		echo "Alternatively provide ANT=/path/to/ant."; \
		exit 1; \
	fi; \
	if [ -n "$(ANT_XML_RESOLVER_JAR)" ] && [ -f "$(ANT_XML_RESOLVER_JAR)" ]; then \
		echo "Installed Ant XML resolver: $(ANT_XML_RESOLVER_JAR)"; \
	else \
		echo "Installed Ant XML resolver: not found"; \
		echo "Apache XML Commons Resolver is required so Ant xmlcatalog entries are honored."; \
		if command -v $(APT_CACHE) >/dev/null 2>&1; then \
			echo "Debian package candidate:"; \
			$(APT_CACHE) policy libxml-commons-resolver1.1-java 2>/dev/null | sed 's/^/  /'; \
			echo "Install it with: sudo apt install libxml-commons-resolver1.1-java"; \
		fi; \
		echo "Alternatively provide ANT_XML_RESOLVER_JAR=/path/to/xml-resolver.jar."; \
		exit 1; \
	fi

fetch-dependencies: $(SAXON_JAR) $(XMLRESOLVER_JAR) $(XMLRESOLVER_DATA_JAR) $(TEI_XSL_STYLESHEET_DIR)/rng/build-to.xml

$(P5SUBSET):
	mkdir -p $(BUILD)
	$(CURL) -fL -o $@ $(P5SUBSET_URL)

$(SAXON_JAR):
	@set -eu; \
	mkdir -p $(BUILD); \
	if [ -n "$(LOCAL_SAXON_JAR)" ]; then \
		version=`$(JAVA) -cp "$(LOCAL_SAXON_JAR)" net.sf.saxon.Transform '-?' 2>&1 | sed -n 's/^Saxon[^ ]*HE \([^ ]*\).*/\1/p' | sed 's/J$$//'`; \
	else \
		version="not installed"; \
	fi; \
	if [ "$$version" != "not installed" ] && command -v $(DPKG) >/dev/null 2>&1 && $(DPKG) --compare-versions "$$version" ge "$(MIN_SAXON_VERSION)"; then \
		echo "Using installed Saxon $$version; not downloading $(SAXON_JAR)."; \
		ln -sf "$(LOCAL_SAXON_JAR)" "$@"; \
	else \
		echo "Saxon $$version is missing or too old; upstream Saxon $(SAXON_VERSION) is required."; \
		if [ "$${FD_FETCH_DEPS:-}" != "yes" ]; then \
			printf "Download Saxon $(SAXON_VERSION) into $(BUILD)? [y/N] "; \
			read answer; \
			case "$$answer" in y|Y|yes|YES) ;; *) echo "Aborting dependency download."; exit 1;; esac; \
		fi; \
		$(CURL) -fL -o "$@" "$(SAXON_URL)"; \
	fi

$(XMLRESOLVER_JAR):
	mkdir -p $(BUILD)
	$(CURL) -fL -o $@ $(XMLRESOLVER_URL)

$(XMLRESOLVER_DATA_JAR):
	mkdir -p $(BUILD)
	$(CURL) -fL -o $@ $(XMLRESOLVER_DATA_URL)

$(TEI_XSL_STYLESHEET_DIR)/rng/build-to.xml: $(TEI_XSL_ARCHIVE)
	mkdir -p $(TEI_XSL_DIR)
	$(UNZIP) -q -o $(TEI_XSL_ARCHIVE) -d $(TEI_XSL_DIR)
	test -f $@

$(TEI_XSL_ARCHIVE):
	@set -eu; \
	mkdir -p $(BUILD); \
	echo "TEI Stylesheets are required for ODD expansion and schema generation."; \
	if [ "$${FD_FETCH_DEPS:-}" != "yes" ]; then \
		printf "Download TEI Stylesheets $(TEI_XSL_VERSION) into $(BUILD)? [y/N] "; \
		read answer; \
		case "$$answer" in y|Y|yes|YES) ;; *) echo "Aborting dependency download."; exit 1;; esac; \
	fi; \
	$(CURL) -fL -o "$@" "$(TEI_XSL_URL)"

freedict-P5.rng: $(ODD) check-dependencies fetch-dependencies $(P5SUBSET)
	cd $(TEI_XSL_STYLESHEET_DIR)/rng && $(ANT) $(SCHEMA_ANT_COMMON) -DoutputFile="$(abspath $@)"

freedict-P5.dtd: $(ODD) check-dependencies fetch-dependencies $(P5SUBSET)
	cd $(TEI_XSL_STYLESHEET_DIR)/dtd && $(ANT) $(SCHEMA_ANT_COMMON) -DoutputFile="$(abspath $@)"

freedict-P5.sch: $(ODD) check-dependencies fetch-dependencies $(P5SUBSET)
	cd $(TEI_XSL_STYLESHEET_DIR)/schematron && $(ANT) $(SCHEMA_ANT_COMMON) -Dodd=true -DoutputFile="$(abspath $@)"
	rm -f $(ODD).processedodd

clean:
	rm -f $(ODD_SCHEMA) $(P5SUBSET) $(ODD).processedodd
