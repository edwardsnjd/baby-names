SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:

# Targets

US_NAMES_TARGET := us-names.csv
US_NAMES_MALE_TARGET := us-names-male.csv
US_NAMES_FEMALE_TARGET := us-names-female.csv
US_NAMES_TARGETS := $(US_NAMES_TARGET) $(US_NAMES_FEMALE_TARGET) $(US_NAMES_MALE_TARGET)

WELSH_MALE_NAMES_TARGET := welsh-names-male.csv
WELSH_FEMALE_NAMES_TARGET := welsh-names-female.csv
WELSH_NAMES_TARGETS := $(WELSH_MALE_NAMES_TARGET) $(WELSH_FEMALE_NAMES_TARGET)

SCOTTISH_MALE_NAMES_TARGET := scottish-names-male.csv
SCOTTISH_FEMALE_NAMES_TARGET := scottish-names-female.csv
SCOTTISH_NAMES_TARGETS := $(SCOTTISH_MALE_NAMES_TARGET) $(SCOTTISH_FEMALE_NAMES_TARGET)

.PHONY: build
build: $(US_NAMES_TARGETS) $(WELSH_NAMES_TARGETS) $(SCOTTISH_NAMES_TARGETS)

.PHONY: clean
clean:

# US names recipes

US_NAMES_URL := https://www.ssa.gov/oact/babynames/names.zip
US_NAMES_ZIP := us-names.zip
US_NAMES_WORKING_DIR := us-names
US_NAMES_MARKER := $(US_NAMES_WORKING_DIR)/NationalReadMe.pdf

$(US_NAMES_TARGET): $(US_NAMES_MARKER)
	{ echo "Name,Gender" ; cat names/*.txt | cut -d "," -f 1,2 | sort -u ; } > $@

$(US_NAMES_MALE_TARGET): $(US_NAMES_TARGET)
	awk -F, '$$2 == "M" {print $$1}' < $< > $@

$(US_NAMES_FEMALE_TARGET): $(US_NAMES_TARGET)
	awk -F, '$$2 == "F" {print $$1}' < $< > $@

.INTERMEDIATE: $(US_NAMES_MARKER)
$(US_NAMES_MARKER): $(US_NAMES_ZIP) | $(US_NAMES_WORKING_DIR)
	unzip $(US_NAMES_ZIP) -d $(US_NAMES_WORKING_DIR)/

.INTERMEDIATE: $(US_NAMES_WORKING_DIR)
$(US_NAMES_WORKING_DIR):
	mkdir -p $@

.INTERMEDIATE: $(US_NAMES_ZIP)
$(US_NAMES_ZIP):
	curl --silent $(US_NAMES_URL) > $@

# Welsh names recipes

WELSH_MALE_NAMES_URLS := https://www.welshboysnames.co.uk/
WELSH_MALE_NAMES_URLS += https://www.welshboysnames.co.uk/names-e-l/
WELSH_MALE_NAMES_URLS += https://www.welshboysnames.co.uk/names-m-w/
WELSH_MALE_NAMES_HTML := welsh-names-male.html

WELSH_FEMALE_NAMES_URLS := https://welshgirlsnames.co.uk/
WELSH_FEMALE_NAMES_URLS += https://welshgirlsnames.co.uk/names-e-h/
WELSH_FEMALE_NAMES_URLS += https://welshgirlsnames.co.uk/names-i-to-y/
WELSH_FEMALE_NAMES_HTML := welsh-names-female.html

$(WELSH_MALE_NAMES_TARGET): $(WELSH_MALE_NAMES_HTML)
	sed -E 's|<a href="https://www.welshboysnames.co.uk[^"]+">[^<]+</a>|\n&\n|g' < $< | grep -E '^<a href="https://www.welsh' | sed -E 's/.*>([^<]+)<.*/\1/' | sort -u | grep -v ' ' > $@

.INTERMEDIATE: $(WELSH_MALE_NAMES_HTML)
$(WELSH_MALE_NAMES_HTML):
	curl --silent $(WELSH_MALE_NAMES_URLS) > $@

$(WELSH_FEMALE_NAMES_TARGET): $(WELSH_FEMALE_NAMES_HTML)
	sed -E 's|<a href="https://welshgirlsnames.co.uk[^"]+">[^<]+</a>|\n&\n|g' < $< | grep -E '^<a href="https://welsh' | sed -E 's/.*>([^<]+)<.*/\1/' | sort -u | grep -v ' ' > $@

.INTERMEDIATE: $(WELSH_FEMALE_NAMES_HTML)
$(WELSH_FEMALE_NAMES_HTML):
	curl --silent $(WELSH_FEMALE_NAMES_URLS) > $@

# Scottish names recipes

SCOTTISH_NAMES_URL := https://www.nrscotland.gov.uk/files/statistics/pop-names-07-t4.csv
SCOTTISH_NAMES_CSV := scottish-names.csv

$(SCOTTISH_MALE_NAMES_TARGET): $(SCOTTISH_NAMES_CSV)
	cut -d, -f1 < $< | tail +3 | sort -u > $@

$(SCOTTISH_FEMALE_NAMES_TARGET): $(SCOTTISH_NAMES_CSV)
	cut -d, -f4 < $< | tail +3 | sort -u > $@

.INTERMEDIATE: $(SCOTTISH_NAMES_CSV)
$(SCOTTISH_NAMES_CSV):
	curl -s $(SCOTTISH_NAMES_URL) | tail +3 > $@
