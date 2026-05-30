# sunnstix's dotfiles

A modern, cross-platform (macOS + Ubuntu) terminal setup managed with **GNU Stow**.

**Stack:** zsh + oh-my-zsh · starship prompt · tmux · LazyVim (neovim) · yazi · fzf · zoxide · lazygit — all themed **Catppuccin Mocha**.

## Install — one command

```bash
git clone https://github.com/sunnstix/dotfiles.git ~/dotfiles && ~/dotfiles/install.sh
```

> Run it in a **real terminal** (not piped) — on Ubuntu it prompts once for `sudo`,
> and `chsh` needs a TTY.

The installer detects your OS and does **everything** end-to-end:
- **macOS** → installs all tools + the Nerd Font via Homebrew.
- **Ubuntu/Debian** → `apt` for `zsh stow tmux eza bat fd-find git-delta fontconfig`,
  and downloads `neovim fzf zoxide starship yazi lazygit` + a Nerd Font into your
  user dirs (apt's versions are too old / absent).

Then it: installs oh-my-zsh + plugins and TPM, **installs JetBrainsMono Nerd Font**
(and points GNOME Terminal at it), stows the packages, builds the bat theme cache,
installs the yazi flavor, installs tmux plugins, syncs LazyVim, and switches your
login shell to zsh.

Flags: `--no-sudo` (skip apt/chsh) · `--stow` (only re-link configs).

### Fonts (the one manual bit on some terminals)
The script installs **JetBrainsMono Nerd Font** and auto-selects it for GNOME
Terminal. Any *other* terminal (iTerm2, kitty, alacritty, wezterm, VS Code/Cursor)
needs you to pick `JetBrainsMono Nerd Font` in its font settings once — otherwise
icons render as boxes.

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
