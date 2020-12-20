.PHONY: build up new webp

HUGO=$(shell which hugo)

all: build

build:
	$(HUGO)

up:
	$(HUGO) server --buildDrafts --disableFastRender --bind=0.0.0.0 --baseURL=192.168.1.248

new:
	cp -p archetypes/default.md content/post/$(TITLE).md

webp:
	docker-compose run --rm cwebp cwebp -q 75 $(SRC) -o $(SRC).webp