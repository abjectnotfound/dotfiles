DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
OS := $(shell bin/is-supported bin/is-macos macos $(shell bin/is-supported bin/is-ubuntu ubuntu $(shell bin/is-supported bin/is-arch arch linux)))
HOMEBREW_PREFIX := $(shell bin/is-supported bin/is-arm64 /opt/homebrew /usr/local)
PATH := $(HOMEBREW_PREFIX)/bin:$(DOTFILES_DIR)/bin:$(HOME)/.cargo/bin:$(PATH)
SHELL := env PATH=$(PATH) /bin/bash
SHELLS := /private/etc/shells
BIN := $(HOMEBREW_PREFIX)/bin
export XDG_CONFIG_HOME = $(HOME)/.config
export STOW_DIR = $(DOTFILES_DIR)
export ACCEPT_EULA=Y

.PHONY: test

all: $(OS)

macos: sudo core-macos packages-macos link duti bun firefox-config dock

ubuntu: core-ubuntu link

arch: core-arch packages-arch link

core-macos: brew bash git npm

core-ubuntu:
	apt-get update
	apt-get upgrade -y
	apt-get dist-upgrade -f

stow-ubuntu: core-ubuntu
	is-executable stow || apt-get -y install stow

core-arch:
	pacman -Syu --noconfirm

stow-arch: core-arch
	is-executable stow || pacman -S --noconfirm stow

stow-macos: brew
	is-executable stow || brew install stow

sudo:
ifndef GITHUB_ACTION
	sudo -v
	while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
endif

link: stow-$(OS)
	for FILE in $$(\ls -A runcom); do if [ -f $(HOME)/$$FILE -a ! -h $(HOME)/$$FILE ]; then \
		mv -v $(HOME)/$$FILE{,.bak}; fi; done
	mkdir -p "$(XDG_CONFIG_HOME)"
	@for dir in $$(\ls -A config); do \
		if [ -e "$(XDG_CONFIG_HOME)/$$dir" ] && [ ! -L "$(XDG_CONFIG_HOME)/$$dir" ]; then \
			mv -v "$(XDG_CONFIG_HOME)/$$dir" "$(XDG_CONFIG_HOME)/$$dir.bak"; \
		fi; \
	done
	stow -t "$(HOME)" runcom
	stow -t "$(XDG_CONFIG_HOME)" config

unlink: stow-$(OS)
	stow --delete -t "$(HOME)" runcom
	stow --delete -t "$(XDG_CONFIG_HOME)" config
	for FILE in $$(\ls -A runcom); do if [ -f $(HOME)/$$FILE.bak ]; then \
		mv -v $(HOME)/$$FILE.bak $(HOME)/$${FILE%%.bak}; fi; done

brew:
	is-executable brew || curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash

bash: brew
ifdef GITHUB_ACTION
	if ! grep -q bash $(SHELLS); then \
		brew install bash bash-completion@2 pcre && \
		echo $(shell which bash) | sudo tee -a $(SHELLS) && \
		sudo chsh -s $(shell which bash); \
	fi
else
	if ! grep -q bash $(SHELLS); then \
		brew install bash bash-completion@2 pcre && \
		echo $(shell which bash) | sudo tee -a $(SHELLS) && \
		chsh -s $(shell which bash); \
	fi
endif

git: brew
	brew install git git-extras

npm: brew-packages
	mise use -g node@lts

packages-macos: brew-packages cask-apps node-packages rust-packages

packages-arch: pacman-packages

pacman-packages:
	pacman -S --noconfirm - < $(DOTFILES_DIR)/install/pacmanfile

brew-packages: brew taps
	brew bundle --verbose --file=$(DOTFILES_DIR)/install/Brewfile || true

taps: brew
	@for tap in floatpane/matcha hashicorp/tap teamookla/speedtest; do \
		brew trust $$tap 2>&1 || true; \
	done

cask-apps: brew
	brew bundle --file=$(DOTFILES_DIR)/install/Caskfile || true

vscode-extensions: cask-apps
	for EXT in $$(cat install/Codefile); do code --install-extension $$EXT; done

node-packages: npm
	npm install --force --location global --allow-scripts $(shell cat install/npmfile)

rust-packages: brew-packages
	$(HOMEBREW_PREFIX)/opt/rustup/bin/rustup default stable
	$(HOME)/.cargo/bin/cargo install $(shell cat install/Rustfile)

duti:
	duti -v $(DOTFILES_DIR)/install/duti

bun:
  curl -fsSL https://bun.sh/install | bash

firefox-config:
	$(DOTFILES_DIR)/bin/install-firefox-config

dock:
	$(DOTFILES_DIR)/bin/dot dock

test:
	bats test
