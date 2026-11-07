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
- [mise](https://mise.jdx.dev) for language runtimes (Node, Python, Ruby, Go, Java, Rust, Bun) and global CLI tools (packages: [config.toml](./config/mise/config.toml))
- Latest Git, Bash, GNU coreutils, curl
- Editors: VS Code (macOS) / nvim (Linux), using `$EDITOR`, `$VISUAL`, `$VISUAL_GIT` and Git `core.editor`
- [Starship](https://starship.rs) prompt, with Zsh (`zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-completions`) and Bash support
- Terminals: [Ghostty](https://ghostty.org) and [WezTerm](https://wezfurlong.org/wezterm/)
- [Firefox Betterfox](https://github.com/yokoffing/Betterfox) config (auto-installed via `make firefox-config`)
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

1. Review the Git identity. It is defined in [config/git/config](./config/git/config) rather than set with
   `git config --global` (`~/.config/git` is symlinked into this repo, so `--global` writes to the tracked file).
   See [Multiple GitHub accounts](#multiple-github-accounts) for how identities switch per repo; if you forked
   this repo, replace the names, emails and keys there with your own.

2. Set up the SSH keys the git config expects (`gpg.format = ssh`):

   | Account | Auth key (`core.sshCommand`) | Signing key (`user.signingkey`) |
   | --- | --- | --- |
   | Personal (default) | `~/.ssh/id_ed25519_abjectnotfound` | `~/.ssh/id_ed25519_abjectnotfound_signing.pub` |
   | Work ([config-rigorai](./config/git/config-rigorai)) | `~/.ssh/id_ed25519` | `~/.ssh/id_ed25519_rigorai_signing.pub` |

   **Signing keys are reused across machines and stored in a password manager.** One signing key per account
   means one key to register on GitHub, one line in [allowed_signers](./config/git/allowed_signers), and one key
   to rotate. Restore each one from the password manager instead of generating a new key:

```sh
# Save the private key and public key from the password manager entry, then:
chmod 600 ~/.ssh/id_ed25519_abjectnotfound_signing
chmod 644 ~/.ssh/id_ed25519_abjectnotfound_signing.pub
# Check the key pair is intact and matches allowed_signers
k=~/.ssh/id_ed25519_abjectnotfound_signing
[ "$(ssh-keygen -y -f $k | cut -d' ' -f2)" = "$(cut -d' ' -f2 $k.pub)" ] && \
  grep -qF "$(cut -d' ' -f2 $k.pub)" ~/.config/git/allowed_signers && echo OK
```

   Protect stored signing keys with a passphrase, since a leak from any machine exposes the key everywhere.
   Alternatively, use your password manager's SSH agent (e.g. 1Password or Bitwarden) and keep only the `.pub`
   file on disk: git signs through the agent when `user.signingkey` points at a public key.

   **Passphrases are entered once per machine** (macOS). Store each key's passphrase in the keychain and load it
   into the agent:

```sh
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_abjectnotfound_signing   # repeat for each key
```

   After that nothing prompts again, including after a reboot:
   - Auth keys: [config/ssh/config](./config/ssh/config) sets `AddKeysToAgent` and `UseKeychain` for `github.com`.
     `make link` adds `Include ~/.config/ssh/config` to the top of `~/.ssh/config`, which stays a local file for
     machine-specific hosts. On personal machines, also run `make ssh-personal` to make the personal auth key
     the default for all other hosts ([config.personal](./config/ssh/config.personal)); skip it on the work machine.
   - Signing keys: git signs with `ssh-keygen`, which ignores `~/.ssh/config` and only avoids prompting when the
     key is already in the agent, so [system/macos/.env](./system/macos/.env) runs `ssh-add --apple-load-keychain`
     in each shell.

   **Auth keys are per machine.** Generate a new one on each machine and add it to the account as an
   *authentication* key, so a single machine's access can be revoked on its own:

```sh
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_abjectnotfound -C "abjectnotfound@$(hostname -s)"
```

   **First time only** (no key in the password manager yet): generate the signing key with
   `ssh-keygen -t ed25519 -f ~/.ssh/<name>_signing`, store both halves in the password manager, add the `.pub` to
   GitHub as a *signing* key, and add a line for it to [allowed_signers](./config/git/allowed_signers).

3. Authenticate [GitHub CLI](https://cli.github.com/manual/gh_auth_login) once per account:

```sh
gh auth login   # personal account
gh auth login   # work account
```

   There is no need to `gh auth switch` afterwards; the [gh shim](#multiple-github-accounts) picks the account per repo.

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

7. Populate these files with anything you need sourced in each shell (`local/` is gitignored, so it stays on this machine):

```sh
mkdir -p $DOTFILES_DIR/local
touch $DOTFILES_DIR/local/.profile
touch $DOTFILES_DIR/local/.env
```

   For example, to skip casks from the [Caskfile](./install/Caskfile) on one machine only (also honored by `make cask-apps`):

```sh
# local/.env
export HOMEBREW_BUNDLE_CASK_SKIP="docker-desktop dropbox"
```

## Multiple GitHub accounts

This setup uses a personal GitHub account by default and a separate work account (here, a GitHub Enterprise
Managed User) for repos in the work organizations. Everything is chosen from the repo's remote URL, so nothing
needs switching by hand.

- **Git** ([config/git/config](./config/git/config)): the `[user]` and `[core]` sections hold the personal
  identity. At the end of the file, `includeIf "hasconfig:remote.*.url:..."` blocks load
  [config-rigorai](./config/git/config-rigorai) for remotes in the work orgs. It overrides the commit email
  (the account's no-reply address), signing key, SSH key (`core.sshCommand`) and `github.user`.
- **gh** ([gh-shims/gh](./gh-shims/gh), put first on `PATH` by `.zshrc`): runs the real `gh` with the token of
  the account named by `git config github.user`. `-R OWNER/REPO` and `gh repo <cmd> OWNER/REPO` are matched
  against the same org list. `gh auth ...` and an explicit `GH_TOKEN` are passed through.
- **Drift warning**: the shim caches which owners each logged-in account belongs to
  (`~/.cache/gh-shim/owners`, refreshed daily). If git would route a repo to a different account, it prints a
  warning in the terminal. Orgs reached only through the enterprise (not as a member) can't be detected.

To add a work org, add both lines for it to the `includeIf` list at the **end** of
[config/git/config](./config/git/config); they must come last so they override the defaults. Org names are
case-sensitive and must match the remote URL:

```ini
[includeIf "hasconfig:remote.*.url:**/NewOrg/**"]
    path = ~/.config/git/config-rigorai
[includeIf "hasconfig:remote.*.url:*:NewOrg/**"]
    path = ~/.config/git/config-rigorai
```

`git clone` of a work repo runs before the remote exists, so it uses the personal SSH key. Clone with the work key explicitly:

```sh
git clone -c core.sshCommand="ssh -i ~/.ssh/id_ed25519 -o IdentitiesOnly=yes" git@github.com:NewOrg/repo.git
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
- Git: Full config with SSH signing, delta pager, VS Code diff/merge tools, and per-org identities ([details](#multiple-github-accounts))
- GitHub CLI: `gh` config and a shim that picks the account per repo
- SSH: shared settings in `~/.config/ssh/config`, included from a local `~/.ssh/config`
- Terminals: Ghostty, WezTerm, Kitty configs
- Editor: Neovim (LazyVim), VS Code
- Tools: Television (67 cable channels), OpenCode, Trippy, btop, htop, mise
- Firefox: Betterfox `user.js` with auto-install script
- macOS: System defaults, Dock, file associations (duti)

## Customize

To customize the dotfiles to your likings, fork this repo and [be the king of your castle!](https://www.webpro.nl/articles/getting-started-with-dotfiles) — the original article explains how to get started with a fork of your own.

## Credits

Many thanks to the [dotfiles community](https://dotfiles.github.io).
