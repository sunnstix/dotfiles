# sunnstix's dotfiles

A modern, cross-platform (macOS + Ubuntu) terminal setup managed with **GNU Stow**.

**Stack:** zsh + oh-my-zsh · starship prompt · tmux · LazyVim (neovim) · yazi · fzf · zoxide · lazygit — all themed **Catppuccin Mocha**.

## Install

```bash
git clone https://github.com/sunnstix/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The installer detects your OS:
- **macOS** → installs everything via Homebrew.
- **Ubuntu/Debian** → `apt` for `zsh stow tmux eza bat fd git-delta`, and downloads
  `neovim fzf zoxide starship yazi lazygit` into `~/.local/bin` (apt's versions are too old).

Then it stows the packages, builds the bat theme cache, installs the yazi flavor,
installs tmux plugins (TPM), syncs LazyVim, and switches your login shell to zsh.

Flags: `--no-sudo` (skip apt/chsh) · `--stow` (only re-link configs).

## Layout (stow packages)

| Package | Symlinks to | What |
|---|---|---|
| `zsh`      | `~/.zshrc`                 | shell, plugins, aliases, tool init |
| `starship` | `~/.config/starship.toml`  | prompt |
| `tmux`     | `~/.config/tmux/tmux.conf` | multiplexer + TPM plugins |
| `nvim`     | `~/.config/nvim/`          | LazyVim + Catppuccin |
| `yazi`     | `~/.config/yazi/`          | file manager |
| `git`      | `~/.gitconfig`, delta theme| git + delta diffs |
| `bat`      | `~/.config/bat/`           | `cat` replacement + themes |

Re-link one package after editing: `stow -R -t ~ <package>` (from `~/dotfiles`).

## Machine-local & secrets

Anything machine-specific or secret (tokens, work paths, keychain) lives in
**`~/.zshrc.local`**, which is git-ignored and sourced at the end of `~/.zshrc`.
Never put secrets in tracked files.

## Cheat sheet

See [`docs/CHEATSHEET.md`](docs/CHEATSHEET.md) for keybindings and workflows for
every tool.
