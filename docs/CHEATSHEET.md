# Cheat Sheet — your new terminal

Everything below reflects *this* config. Prefix keys: **tmux = `Ctrl-a`**, **LazyVim leader = `Space`**.

---

## 🐚 zsh + oh-my-zsh

| Action | Keys / command |
|---|---|
| Accept grey autosuggestion | `→` (right arrow) or `Ctrl-Space` |
| Accept one word of suggestion | `Alt-→` |
| Fuzzy history search (atuin) | `Ctrl-r` |
| Fuzzy file insert into command | `Ctrl-t` |
| Fuzzy `cd` into subdir | `Alt-c` |
| Prepend `sudo` to last command | `Esc` `Esc` (double-tap) |
| `cd` by just typing a dir name | `AUTO_CD` is on — `Documents` ↵ |
| Pop back through dirs | `cd -` then `Tab` shows the stack |
| Extract any archive | `extract file.tar.zst` |

**Modern command aliases:** `ls/ll/la/lt` → eza (icons, git status) · `cat` → bat · `vim/v` → nvim · `lg` → lazygit · `tree` → eza tree · `glog` → pretty git graph.

**fzf-tab:** just press `Tab` on any completion — you get an fzf picker with a live preview (dir listing via eza, file contents via bat). `,`/`.` switch preview groups.

---

## ⭐ starship (prompt)

Shows: OS · user · directory · git branch+status · language versions (node/python/rust/go) · docker context · last-command duration. Edit `~/.config/starship.toml`. Run `starship explain` to see what each segment means.

---

## 🪟 tmux  (prefix = `Ctrl-a`)

| Action | Keys |
|---|---|
| New session (named) | `tmux new -s work` |
| Attach / list | `tmux a -t work` / `tmux ls` |
| Detach | `prefix d` |
| **Split vertical / horizontal** | `prefix \|` / `prefix -` |
| Move between panes | `Ctrl-h/j/k/l` (no prefix! works into nvim too) |
| Resize pane | `prefix H/J/K/L` (repeatable) |
| New / next / prev window | `prefix c` / `prefix n` / `prefix p` |
| Jump to window N | `prefix 1..9` |
| Rename window | `prefix ,` |
| Zoom pane (toggle fullscreen) | `prefix z` |
| Copy mode (scroll) | `prefix [` then vim keys; `v` select, `y` yank, `q` quit |
| Reload config | `prefix r` |
| **Install plugins** (first run) | `prefix I` |
| Update plugins | `prefix U` |
| Save / restore session | `prefix Ctrl-s` / `prefix Ctrl-r` (auto every 15 min) |

> First time in tmux, press `prefix I` (capital i) to fetch the plugins, then `prefix r`.

---

## 📝 LazyVim (neovim)  — leader = `Space`

| Action | Keys |
|---|---|
| **Find file (fuzzy)** | `Space Space` or `Space f f` |
| Live grep (search in files) | `Space /` or `Space s g` |
| Recent files | `Space f r` |
| File explorer (neo-tree) | `Space e` |
| Buffers list | `Space ,` |
| Next / prev buffer | `Shift-l` / `Shift-h` |
| Close buffer | `Space b d` |
| Window split | `Space w v` / `Space w s` |
| Move between windows | `Ctrl-h/j/k/l` (also into tmux) |
| Which-key popup (discover keys) | press `Space` and wait |
| Code action | `Space c a` |
| Rename symbol | `Space c r` |
| Hover docs | `K` |
| Go to definition | `g d` |
| References | `g r` |
| Format | `Space c f` |
| Toggle terminal | `Ctrl-/` |
| Lazygit (inside nvim) | `Space g g` |
| Command palette / commands | `:` |
| Plugin manager | `:Lazy` |
| LSP/health check | `:checkhealth` / `:LazyHealth` |
| Mason (install LSPs) | `:Mason` |
| Save / quit | `:w` / `:q` (or `Space q q`) |

> First launch installs plugins automatically. Run `:checkhealth` once to spot missing deps.

---

## 🗂️ yazi (file manager) — launch with `y` (cd's to where you quit)

| Action | Keys |
|---|---|
| Move | `h j k l` (left=parent, right=enter/open) |
| Top / bottom | `g g` / `G` |
| Toggle hidden files | `.` |
| Select / toggle | `Space` ; visual select `v` |
| Copy / cut / paste | `y` / `x` / `p` |
| Delete (trash) / delete permanently | `d` / `D` |
| Rename | `r` |
| Create file / dir | `a` (end name with `/` for a dir) |
| Search / filter | `s` (fd) · `f` (filter) |
| Find next/prev | `n` / `N` |
| Shell on current file | `;` (interactive) / `:` (block) |
| Tabs | `t` new, `1..9` switch |
| Open with… | `o` |
| Quit (and cd there) | `q` |
| Help | `~` or `F1` |

---

## 🔎 fzf (fuzzy finder)

- Standalone: `fzf` (uses fd, respects .gitignore). Type to filter; `Enter` selects.
- In a query: `nvim $(fzf)`. Pipe anything: `git branch | fzf`.
- Multi-select: `Tab`. Preview pane shows file contents (bat) or dir tree (eza).
- Shell integration keys are `Ctrl-t`, `Ctrl-r`, `Alt-c` (see zsh section).

---

## 🕰️ atuin (smart shell history) — owns `Ctrl-r`

| Action | Keys / command |
|---|---|
| Search history (fuzzy, frecency-ranked) | `Ctrl-r` |
| In the search UI: filter scope | `Ctrl-r` cycles global / host / session / dir |
| Accept (paste to prompt) / run | `Enter` (paste) · `Tab` (paste w/o run) |
| Stats | `atuin stats` |
| Search from CLI | `atuin search <term>` |

Up-arrow stays normal history (atuin runs with `--disable-up-arrow`). Atuin also
feeds the grey **autosuggestions** — they're now frecency-ranked, not just "most recent".

## 🚀 zoxide (smart cd)

| Action | Command |
|---|---|
| Jump to best match | `z partial-name` |
| Interactive pick (fzf) | `zi` |
| It learns from every `cd` | just use the shell normally |

Example: after visiting `~/rvw/main/firmware` once, `z firm` jumps straight there.

---

## 🌳 lazygit — run `lg` (or `Space g g` in nvim)

| Action | Keys |
|---|---|
| Stage / unstage file | `Space` (on the file) |
| Stage all | `a` |
| Commit | `c` |
| Amend | `A` |
| Push / pull | `P` / `p` |
| Switch / create branch | `Space` in branches panel / `n` |
| View / navigate panels | `1..5` or `Tab` |
| Diff hunks | scroll; `Space` to stage a hunk |
| Resolve conflicts | `Enter` on file, pick sides |
| Quit / help | `q` / `?` |

---

## 🤖 claude (Claude Code)

| Action | Command / keys |
|---|---|
| Start in a project | `claude` |
| One-shot prompt | `claude -p "explain this repo"` |
| Resume last session | `claude -c` |
| Slash commands | type `/` (e.g. `/init`, `/review`) |
| Run a shell cmd inline | prefix a line with `!` |
| Reference a skill | `/<skill-name>` |
| Plan mode toggle | `Shift-Tab` (in TUI) |

Pairs great with tmux: keep `claude` in one pane, your editor/tests in others
(`Ctrl-h/l` to hop between them).

---

## The 30-second mental model

1. `tmux` is your **window manager** for the terminal (sessions/windows/panes).
2. Inside a pane you run `nvim` (edit), `lg` (git), `y` (files), `claude` (AI).
3. `Ctrl-h/j/k/l` moves seamlessly between **tmux panes and nvim splits**.
4. `z` to jump dirs, `Ctrl-r`/`Ctrl-t` to fuzzy-find, `Tab` for fzf completions.
5. Everything is Catppuccin Mocha and lives in `~/dotfiles` (edit → it's live, thanks to stow).
