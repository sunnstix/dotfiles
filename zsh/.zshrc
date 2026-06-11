# ============================================================================
#  ~/.zshrc  —  managed in ~/dotfiles (stow package: zsh)
#  Stack: oh-my-zsh (plugins) + starship (prompt) + fzf + zoxide + yazi
# ============================================================================

# ---------------------------------------------------------------------------
# PATH  (prepend = highest priority). ~/.local/bin holds our user-space tools.
# ---------------------------------------------------------------------------
typeset -U path PATH                      # keep PATH entries unique
path=(
  "$HOME/bin"
  "$HOME/.local/bin"
  "$HOME/.fzf/bin"
  "$HOME/.pyenv/bin"
  $path
)
export PATH

# ---------------------------------------------------------------------------
# OS detection + Homebrew (macOS / Linuxbrew). Puts brew tools on PATH.
# ---------------------------------------------------------------------------
case "$OSTYPE" in
  darwin*) OS=macos ;;
  linux*)  OS=linux ;;
  *)       OS=other ;;
esac
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  [ -x "$_brew" ] && eval "$("$_brew" shellenv)" && break
done
unset _brew

# ---------------------------------------------------------------------------
# XDG base dirs (a lot of tools below respect these)
# ---------------------------------------------------------------------------
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LESS="-R"                          # pass through colors

# ---------------------------------------------------------------------------
# Oh-My-Zsh
# ---------------------------------------------------------------------------
# User completion scripts (e.g. ant, other CLI tools)
fpath=("$HOME/.local/share/zsh/completions" $fpath)

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""                              # empty: starship owns the prompt
zstyle ':omz:update' mode auto            # auto-update OMZ in the background
DISABLE_MAGIC_FUNCTIONS=true              # avoid paste slowdowns/quirks
ENABLE_CORRECTION=false

# Plugin load order matters:
#  - fzf-tab must come AFTER fzf is on PATH and BEFORE autosuggestions/highlighting
#  - zsh-syntax-highlighting MUST be last
plugins=(
  git                       # tons of git aliases (gst, gco, gp, ...)
  sudo                      # press ESC twice to prepend sudo to the last command
  extract                   # `extract file.tar.gz` handles any archive
  command-not-found
  fzf-tab                   # replace zsh tab-completion menu with an fzf picker
  zsh-autosuggestions       # fish-like grey suggestions from history
  zsh-completions           # extra completion definitions
  zsh-syntax-highlighting   # <-- keep LAST
)
# autosuggestions: suggest from history first, then fall back to a
# completion-based guess when nothing in history matches.
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6c7086"   # Catppuccin overlay0 (subtle grey)
source "$ZSH/oh-my-zsh.sh"

# ---------------------------------------------------------------------------
# History (zsh-native — replaces the old bash-style settings)
# ---------------------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY           # record timestamps
setopt INC_APPEND_HISTORY         # write as you go, not just on exit
setopt SHARE_HISTORY              # share across live sessions
setopt HIST_IGNORE_ALL_DUPS       # drop older dups
setopt HIST_IGNORE_SPACE          # " cmd" (leading space) is not recorded
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY                # show !! expansion before running

# Quality-of-life options
setopt AUTO_CD                    # `..` or a dir name = cd into it
setopt AUTO_PUSHD                 # cd maintains a directory stack
setopt PUSHD_IGNORE_DUPS
setopt INTERACTIVE_COMMENTS       # allow # comments in interactive shell
setopt NO_BEEP

# ---------------------------------------------------------------------------
# Completion styling (works with fzf-tab)
# ---------------------------------------------------------------------------
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # case-insensitive
zstyle ':completion:*' menu no                              # let fzf-tab take over
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# fzf-tab: preview directory contents with eza, files with bat
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath'
zstyle ':fzf-tab:complete:*:*' fzf-preview \
  '[[ -d $realpath ]] && eza -1 --color=always --icons $realpath || bat --color=always --style=numbers --line-range=:200 $realpath 2>/dev/null'
zstyle ':fzf-tab:*' fzf-flags --height=60% --layout=reverse --border
zstyle ':fzf-tab:*' switch-group ',' '.'

# ---------------------------------------------------------------------------
# fzf  (latest build in ~/.fzf). `fzf --zsh` wires CTRL-T / CTRL-R / ALT-C.
# ---------------------------------------------------------------------------
if command -v fzf >/dev/null; then
  source <(fzf --zsh)
  # Catppuccin Mocha colors + use fd for traversal (respects .gitignore)
  export FZF_DEFAULT_OPTS=" \
    --height 60% --layout=reverse --border --margin=1 --padding=1 \
    --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
    --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
    --color=selected-bg:#45475a"
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:300 {} 2>/dev/null || eza -1 --color=always {}'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --level=2 {}'"
fi

# ---------------------------------------------------------------------------
# zoxide  (smarter cd). `z foo` jumps to best match, `zi` is interactive.
# ---------------------------------------------------------------------------
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# ---------------------------------------------------------------------------
# atuin  (SQLite-backed, frecency-ranked shell history; takes over Ctrl-R)
# Initialized AFTER fzf so atuin owns Ctrl-R. Up-arrow stays default history.
# ---------------------------------------------------------------------------
command -v atuin >/dev/null && eval "$(atuin init zsh --disable-up-arrow)"

# ---------------------------------------------------------------------------
# yazi  (file manager). `y` opens it and cd's to wherever you quit.
# ---------------------------------------------------------------------------
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# ---------------------------------------------------------------------------
# ssh: a remote tmux turns on mouse/focus reporting in our LOCAL terminal.
# On a hard disconnect the cleanup escape never arrives, so the terminal is
# left streaming mouse codes. Reset terminal reporting after ssh exits.
# ---------------------------------------------------------------------------
ssh() {
  # Ghostty sets TERM=xterm-ghostty, which most remotes don't have a terminfo
  # entry for -> "missing or unsuitable terminal" + garbled output. Fall back
  # to xterm-256color (universally present) only when we're in Ghostty.
  local term="$TERM"
  [ "$term" = "xterm-ghostty" ] && term="xterm-256color"
  TERM="$term" command ssh "$@"
  local rc=$?
  # disable: mouse (1000/1002/1003), focus (1004), SGR & urxvt ext (1006/1015)
  printf '\e[?1000l\e[?1002l\e[?1003l\e[?1004l\e[?1006l\e[?1015l'
  stty sane 2>/dev/null
  return $rc
}

# ---------------------------------------------------------------------------
# pyenv  (you use this; kept from the old config, Linux-clean)
# ---------------------------------------------------------------------------
if command -v pyenv >/dev/null; then
  export PYENV_ROOT="$HOME/.pyenv"
  eval "$(pyenv init - zsh)"
  command -v pyenv-virtualenv-init >/dev/null && eval "$(pyenv virtualenv-init -)"
fi

# ---------------------------------------------------------------------------
# Go
# ---------------------------------------------------------------------------
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
path+=("/usr/local/go/bin" "$GOBIN")

# ---------------------------------------------------------------------------
# Node Version Manager (nvm) — load lazily only if installed
# ---------------------------------------------------------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# ---------------------------------------------------------------------------
# Java 17 (cross-platform: macOS java_home, else Linux openjdk path)
# ---------------------------------------------------------------------------
if [ "$OS" = macos ] && /usr/libexec/java_home -v 17 >/dev/null 2>&1; then
  export JAVA_HOME="$(/usr/libexec/java_home -v 17)"
  path=("$JAVA_HOME/bin" $path)
elif [ -d "/usr/lib/jvm/java-17-openjdk-amd64" ]; then
  export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
  path=("$JAVA_HOME/bin" $path)
fi

# ---------------------------------------------------------------------------
# Aliases — modern CLI replacements
# ---------------------------------------------------------------------------
# eza (ls)
alias ls='eza --icons --group-directories-first'
alias l='eza -1 --icons --group-directories-first'
alias ll='eza -lah --icons --group-directories-first --git'
alias la='eza -a --icons --group-directories-first'
alias lt='eza --tree --level=2 --icons --group-directories-first'
alias tree='eza --tree --icons'
# bat (cat). Debian ships the binary as `batcat`.
if command -v batcat >/dev/null && ! command -v bat >/dev/null; then
  alias bat='batcat'
fi
alias cat='bat --paging=never'
export BAT_THEME="Catppuccin Mocha"
# fd is `fdfind` on Debian/Ubuntu
command -v fdfind >/dev/null && ! command -v fd >/dev/null && alias fd='fdfind'
# editors / tools
alias vim='nvim'
alias vi='nvim'
alias v='nvim'
alias lg='lazygit'
alias cl='clear'
# safer + friendlier
alias mkdir='mkdir -p'
alias df='df -h'
alias du='du -h'
alias grep='grep --color=auto'
[ "$OS" = linux ] && alias ip='ip --color=auto'   # GNU ip only (not on macOS)
# clipboard: `echo foo | clip`  /  `clip < file`  /  `paste-clip` to read it back.
# Native backend when local (macOS pbcopy, Wayland wl-copy, X11 xclip/xsel);
# OSC52 fallback when remote, so `clip` over SSH reaches your LOCAL clipboard
# (relies on tmux `set-clipboard on`, which is set in tmux.conf).
if command -v pbcopy >/dev/null; then
  alias clip='pbcopy'; alias paste-clip='pbpaste'
elif command -v wl-copy >/dev/null; then
  alias clip='wl-copy'; alias paste-clip='wl-paste'
elif command -v xclip >/dev/null; then
  alias clip='xclip -selection clipboard'; alias paste-clip='xclip -selection clipboard -o'
elif command -v xsel >/dev/null; then
  alias clip='xsel --clipboard --input'; alias paste-clip='xsel --clipboard --output'
else
  unalias clip 2>/dev/null; unalias paste-clip 2>/dev/null
  clip() { printf '\033]52;c;%s\a' "$(base64 | tr -d '\n')" > /dev/tty; }
fi
alias cpwd='pwd | tr -d "\n" | clip'   # copy current directory path

# git extras (OMZ git plugin adds many; a couple of personal favorites)
alias gst='git status'
alias glog="git log --graph --abbrev-commit --decorate --date=relative \
  --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(bold blue)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"

# ---------------------------------------------------------------------------
# Keybindings
# ---------------------------------------------------------------------------
bindkey '^ ' autosuggest-accept   # Ctrl-Space: accept the grey autosuggestion

# ---------------------------------------------------------------------------
# Starship prompt  (config: ~/.config/starship.toml)
# ---------------------------------------------------------------------------
command -v starship >/dev/null && eval "$(starship init zsh)"

# ---------------------------------------------------------------------------
# Local, machine-specific overrides (NOT tracked in git)
# ---------------------------------------------------------------------------
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
