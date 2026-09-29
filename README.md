# .files

These are my dotfiles. Take anything you want, but at your own risk.

Mainly targets macOS systems, but works on Ubuntu and Arch Linux as well.

## Highlights

- Minimal efforts to install everything, using a [Makefile](./Makefile)
- Mostly based around Homebrew, Caskroom and Node.js, latest Bash + GNU Utils, with Zsh and the Starship prompt
- Starship prompt with Zsh and Bash support
- Updated macOS defaults
- Well-organized and easy to customize
- The installation and runcom setup is
  [tested weekly on real Ubuntu and macOS machines](https://github.com/abjectnotfound/dotfiles/actions)
  (Sonoma/14, Sequoia/15, Tahoe/26) using [a GitHub Action](./.github/workflows/dotfiles-installation.yml)
- Supports both Apple Silicon (M1) and Intel chips

## Packages Overview

- [Homebrew](https://brew.sh) (packages: [Brewfile](./install/Brewfile))
- [homebrew-cask](https://github.com/Homebrew/homebrew-cask) (packages: [Caskfile](./install/Caskfile))
- [Node.js + npm LTS](https://nodejs.org/en/download/) (packages: [npmfile](./install/npmfile))
- Latest Git, Bash, Python, GNU coreutils, curl, Ruby
- Editors: VS Code (macOS) / nano (Linux), using `$EDITOR`, `$VISUAL`, `$VISUAL_GIT` and Git `core.editor`
- [Starship](https://starship.rs) prompt, with Zsh (`zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-completions`) and Bash support
- Terminals: [Ghostty](https://ghostty.org) and [WezTerm](https://wezfurlong.org/wezterm/)
- [Firefox Betterfox](https://github.com/yokoffing/Betterfox) config (auto-installed via `make firefox-config`)
- [bun](https://bun.sh) runtime (installed via `make`, added to `PATH`)
- [delta](https://github.com/dandavison/delta) as the Git diff pager
- [topgrade](https://github.com/topgrade-rs/topgrade) for package updates (system and skills steps disabled)
- GitHub CLI (`gh`) as the Git credential helper and for [authenticated git operations](https://cli.github.com/manual/gh_auth_setup_git)

## Installation

On a sparkling fresh installation of macOS:

```bash
sudo softwareupdate -i -a
xcode-select --install
```

The Xcode Command Line Tools includes `git` and `make` (not available on stock macOS). Now there are two options:

1. Install this repo with `curl` available:

```bash
bash -c "`curl -fsSL https://raw.githubusercontent.com/abjectnotfound/dotfiles/main/remote-install.sh`"
```

This will clone or download this repo to `~/.dotfiles` (depending on the availability of `git`, `curl` or `wget`).

1. Alternatively, clone manually into the desired location:

```bash
git clone https://github.com/abjectnotfound/dotfiles.git ~/.dotfiles
```

2. Use the [Makefile](./Makefile) to install the [packages listed above](#packages-overview), and symlink
   [runcom](./runcom) and [config](./config) files (using [stow](https://www.gnu.org/software/stow/)):

```bash
cd ~/.dotfiles
make
```

Running `make` with the Makefile is idempotent. The installation process in the Makefile is tested on every push and every week in this
[GitHub Action](https://github.com/abjectnotfound/dotfiles/actions). Please file an issue in this repo if there are errors.

## Post-Installation

1. Set your Git identity:

```sh
git config --global user.name "your name"
git config --global user.email "your@email.com"
git config --global github.user "your-github-username"
```

2. Configure SSH commit signing with your existing SSH key. The git config is pre-configured for SSH signing via `gpg.format = ssh`.

3. Authenticate [GitHub CLI](https://cli.github.com/manual/gh_auth_login):

```sh
gh auth login
```

4. Configure the [Starship](https://starship.rs) prompt (optional): run `starship preset` to customize.

5. Set macOS [Dock items](./macos/dock.sh) and [system defaults](./macos/defaults.sh):

```sh
dot dock
dot macos
```

6. Install the Firefox config:

```sh
dot firefox-config
```

7. Populate this file with anything you need sourced in each shell:

```sh
mkdir -p $DOTFILES_DIR/local
touch $DOTFILES_DIR/local/.profile
touch $DOTFILES_DIR/local/.env
```

## The `dot` command

```
$ dot help
Usage: dot <command>

Commands:
   clean            Clean up caches (brew, cargo, gem, pip)
   dock             Apply macOS Dock settings
   duti             Set default apps for file types (UTI)
   edit             Open dotfiles in IDE ($VISUAL) and Git GUI ($VISUAL_GIT)
   firefox-config   Install Betterfox user.js into Firefox profiles
   help             This help message
   macos            Apply macOS system defaults
   test             Run tests
   update           Update packages and pkg managers (brew, casks, cargo, pip3, npm, gems, macOS)
```

## What's tracked

- Shell: Bash (`.bash_profile`) and Zsh (`.zshrc`) configs, sourcing shared `system/*` files
- Prompt: Starship (cross-shell)
- Git: Full config with SSH signing, delta pager, VS Code diff/merge tools
- Terminals: Ghostty, WezTerm, Kitty configs
- Editor: Neovim (LazyVim), VS Code
- Tools: Television (67 cable channels), OpenCode, Trippy, btop, htop, mise
- Firefox: Betterfox `user.js` with auto-install script
- macOS: System defaults, Dock, file associations (duti)

## Customize

To customize the dotfiles to your likings, fork this repo and [be the king of your castle!](https://www.webpro.nl/articles/getting-started-with-dotfiles) — the original article explains how to get started with a fork of your own.

## Credits

Many thanks to the [dotfiles community](https://dotfiles.github.io).
