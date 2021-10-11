NPM := pnpm
DATA := data
DIST := dist
API := src
API_URL := http://localhost:3000
VERSION := $(shell git describe --abbrev=0 --tags)
SDIST := sdist-$(VERSION).tar.gz

.PHONY: all clean sdist

all: $(DIST)

clean:
	-rm -rf $(API) $(DIST) $(SDIST)

fullclean: clean
	-rm -rf $(DATA)

sdist: $(SDIST)

node_modules: package.json pnpm-lock.yaml
	$(NPM) install

$(DATA):
	mkdir -p $@

$(DATA)/openapi.json: $(DATA)
	wget $(API_URL)/-json -O $@

$(API): node_modules $(DATA)/openapi.json
	pnpx @openapitools/openapi-generator-cli generate --skip-validate-spec -i $(API_URL)/-json -g typescript-fetch -o $(API)

$(DIST): node_modules $(API)
	pnpx tsc

$(SDIST): README.md LICENSE package.json tsconfig.json $(DATA) $(API) types
	tar cvzf $@ $^