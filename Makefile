.POSIX:

AUTO_SLEEP = 2

UNAME = $(shell uname)

SHARDS ?= shards
CRYSTAL ?= crystal
CRFLAGS ?=
SOURCES = src/*.cr
SPECS = spec/*.cr

DESTDIR ?=
PREFIX ?= /usr/local
BINDIR ?= $(DESTDIR)$(PREFIX)/bin
INSTALL = /usr/bin/install

pwd = $(shell pwd)

ifeq (${UNAME},Darwin)
	inotify_program = fswatch
	make_inotifywait = $(inotify_program) -1 -r src spec
	notify_ok = terminal-notifier -appIcon file://$(pwd)/.complete.png \
		-title "crun $(1)" -message passed
	notify_fail = terminal-notifier -appIcon file://$(pwd)/.reject.png \
		-title "crun $(1)" -message failed
else
	inotify_program = inotifywait
	make_inotifywait = $(inotify_program) -qq -e close_write -r src spec
	notify_ok = notify-send -i $(pwd)/spec/icons/complete.svg "crun $(1)" passed
	notify_fail = notify-send -i $(pwd)/spec/icons/reject.svg "crun $(2)" failed
endif

has_inotify = $(shell [ -n "$$(which $(inotify_program))" ] && echo Ok)

tty_notify_ok = printf "\033[1;49;92mcrun $(1) passed\033[0m\n"
tty_notify_fail = printf "\033[1;49;91mcrun $(1) failed\033[0m\n"

ifeq ($(has_inotify),Ok)
	make_notify = \
		( $(MAKE) --no-print-directory $(1) \
			&& $(call tty_notify_ok,$(2)) && $(call notify_ok,$(2)) \
			|| ( $(call tty_notify_fail,$(2)) && $(call notify_fail,$(2)); false ) )
else
	make_notify = \
		( $(MAKE) --no-print-directory $(1) \
			&& $(call tty_notify_ok,$(2)) || ( $(call tty_notify_fail,$(2)); false ) )
endif

.%.png: spec/icons/%.svg
	convert -background none -resize 256x256 $< $@

all: help

auto: ## Run tests suite continuously on writes
	@+while true; do \
		make --no-print-directory tests && \
			echo "⇒ \033[1;49;92mauto tests done\033[0m, sleeping $(AUTO_SLEEP)s…"; \
		sleep $(AUTO_SLEEP); \
		$(call make_inotifywait); \
	done

bin/ameba:
	$(SHARDS) install

binfmt: crun ## Add Linux binfmt support
	echo ":crystal:E::cr::$(BINDIR)/crun:OC" \
		| sudo tee /proc/sys/fs/binfmt_misc/register

check: bin/ameba ## Run Ameba static code check
	./bin/ameba

clean: ## Remove crun builded binary
	rm -f crun

clobber: clean ## Clean and remove editor backup files (*~)
	find . -type f -name \*~ -exec rm -f {} \+
	rm -rf bin lib .crun

crun: $(SOURCES) ## Build crun binary
	$(CRYSTAL) build src/main.cr -o crun $(CRFLAGS)

dev4osx: ## Prepare for dev. on Osx
	brew tap veelenga/tap
	brew install ameba crystal fswatch imagemagick terminal-notifier

githook:
	@printf "#!/bin/sh\nmake tests\n" > .git/hooks/pre-commit
	@chmod a+rx .git/hooks/pre-commit

help: ## Show this help
	@printf '\033[32mtargets:\033[0m\n'
	@grep -E '^[a-zA-Z _-]+:.*?## .*$$' $(MAKEFILE_LIST) |\
		sort |\
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n",$$1,$$2}'

install: crun ## Install crun binary
	$(INSTALL) -m 0755 crun "$(BINDIR)"

format: ## Run Crystal format tool
	$(CRYSTAL) tool format -i src -i spec

png: \
$(patsubst spec/icons/%,.%,$(patsubst %.svg,%.png,$(wildcard spec/icons/*.svg)))

release: $(SOURCES) ## Build crun binary
	$(CRYSTAL) build src/main.cr --release --no-debug -o crun $(CRFLAGS)

sign: release
	shasum -a256 crun > crun.sha256

spec: $(SPECS) crun ## Run crun specs
	$(CRYSTAL) spec

tests: ## Run tests suite
	@+$(call make_notify,format,format) && \
	$(call make_notify,clean,clean) && \
	$(call make_notify,crun,build) && \
	$(call make_notify,spec,spec) && \
	$(call make_notify,check,check)

todo: ## Show fixme and todo comments
	@find . -type f -name \*.cr -exec \
		egrep --color=auto -e '(TODO|FIXME):' {} \+ 2> /dev/null || true

uninstall: ## Uninstall crun binary
	rm -f "$(BINDIR)/crun"
