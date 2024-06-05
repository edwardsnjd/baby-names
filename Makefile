SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:

US_NAMES_URL := https://www.ssa.gov/oact/babynames/names.zip
US_NAMES_ZIP := us-names.zip
US_NAMES_WORKING_DIR := us-names
US_NAMES_MARKER := $(US_NAMES_WORKING_DIR)/NationalReadMe.pdf

US_NAMES_TARGET := us-names.csv
US_NAMES_MALE_TARGET := us-names-male.csv
US_NAMES_FEMALE_TARGET := us-names-female.csv

.PHONY: build
build: $(US_NAMES_TARGET) $(US_NAMES_FEMALE_TARGET) $(US_NAMES_MALE_TARGET)

.PHONY: clean
clean:

$(US_NAMES_TARGET): $(US_NAMES_MARKER)
	{ echo "Name,Gender" ; cat names/*.txt | cut -d "," -f 1,2 | sort -u ; } > $@

$(US_NAMES_MALE_TARGET): $(US_NAMES_TARGET)
	awk -F, '$$2 == "M" {print $$1}' < $< > $@

$(US_NAMES_FEMALE_TARGET): $(US_NAMES_TARGET)
	awk -F, '$$2 == "F" {print $$1}' < $< > $@

$(US_NAMES_MARKER): $(US_NAMES_ZIP) | $(US_NAMES_WORKING_DIR)
	unzip $(US_NAMES_ZIP) -d $(US_NAMES_WORKING_DIR)/

$(US_NAMES_WORKING_DIR):
	mkdir -p $@

.INTERMEDIATE: $(US_NAMES_ZIP)
$(US_NAMES_ZIP):
	curl --silent $(US_NAMES_URL) > $@
