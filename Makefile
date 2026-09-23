DOTFILES := $(CURDIR)

.PHONY: tools

all: setup tools

setup: setup-dotfiles setup-programs

setup-dotfiles:
	cd "$$HOME" && "$(DOTFILES)/bin/setup-dotfiles.sh"

setup-programs:
	cd "$$HOME" && "$(DOTFILES)/bin/setup-programs.sh"

tools:
	make -C "$(DOTFILES)/tools" BIN_DIR="$(HOME)/bin"
	$(HOME)/bin/count-commands init
