.PHONY: build up new

HUGO=$(shell which hugo)

all: build

build:
	$(HUGO)

up:
	$(HUGO) server --buildDrafts --bind=0.0.0.0 --baseURL=192.168.1.248

new:
	cp -p archetypes/default.md content/post/$(TITLE).md