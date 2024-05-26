SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:

URL := https://www.ssa.gov/oact/babynames/names.zip

.PHONY: build
build: names.csv names-male.csv names-female.csv

.PHONY: clean
clean:

names.csv: names/NationalReadMe.pdf
	{ echo "Name,Gender" ; cat names/*.txt | cut -d "," -f 1,2 | sort -u ; } > $@

names-male.csv: names.csv
	awk -F, '$$2 == "M" {print $$1}' < $< > $@

names-female.csv: names.csv
	awk -F, '$$2 == "F" {print $$1}' < $< > $@

names/NationalReadMe.pdf: names.zip | names
	unzip names.zip -d names/

names:
	mkdir -p $@

.INTERMEDIATE: names.zip
names.zip:
	curl --silent $(URL) > $@
