.POSIX:

SHARDS = shards
CRYSTAL = crystal
CRFLAGS =
SOURCES = src/*.cr
SPECS = spec/*.cr

DESTDIR =
PREFIX = /usr/local
BINDIR = $(DESTDIR)$(PREFIX)/bin
INSTALL = /usr/bin/install

pwd = $(shell pwd)

all: help

bin/ameba:
	$(SHARDS) install

check: bin/ameba ## Run Ameba static code check
	./bin/ameba

clean: ## Remove crun builded binary
	rm -f crun

clobber: clean ## Clean and remove editor backup files (*~)
	find . -type f -name \*~ -exec rm -f {} \+
	rm -rf bin lib

crun: $(SOURCES) ## Build crun binary
	$(CRYSTAL) build src/main.cr -o crun $(CRFLAGS)

help: ## Show this help
	@printf '\033[32mtargets:\033[0m\n'
	@grep -E '^[a-zA-Z _-]+:.*?## .*$$' $(MAKEFILE_LIST) |\
		sort |\
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n",$$1,$$2}'

install: crun ## Install crun binary
	$(INSTALL) -m 0755 crun "$(BINDIR)"

uninstall: ## Uninstall crun binary
	rm -f "$(BINDIR)/crun"

format: ## Run Crystal format tool
	$(CRYSTAL) tool format -i src -i spec

release: $(SOURCES) ## Build crun binary
	$(CRYSTAL) build src/main.cr --release --no-debug -o crun $(CRFLAGS)

spec: $(SPECS) crun ## Run crun specs
	$(CRYSTAL) spec

todo: ## Show fixme and todo comments
	@find . -type f -name \*.cr -exec \
		egrep --color=auto -e '(TODO|FIXME):' {} \+ 2> /dev/null || true
