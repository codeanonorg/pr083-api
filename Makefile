NPM := pnpm
DATA := data
DIST := dist
API := src
API_URL := http://localhost:3000
VERSION := $(shell git rev-parse --abbrev-ref HEAD)
SDIST := sdist-$(VERSION).tar.gz

.PHONY: all clean sdist

all: $(DIST)

clean:
	-rm -rf $(API) $(DIST) $(SDIST)

sdist: $(SDIST)

node_modules: package.json pnpm-lock.yaml
	$(NPM) install

$(API): node_modules
	pnpx @openapitools/openapi-generator-cli generate --skip-validate-spec -i $(API_URL)/-json -g typescript-fetch -o $(API)

$(DIST): node_modules $(API)
	pnpx tsc

$(SDIST): README.md LICENSE package.json tsconfig.json $(API) types
	tar cvzf $@ $^