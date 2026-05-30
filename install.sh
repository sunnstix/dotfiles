#!/usr/bin/env bash
# ============================================================================
#  dotfiles installer — works on macOS (Homebrew) and Ubuntu/Debian (apt).
#  Usage:  ./install.sh            # full install
#          ./install.sh --no-sudo  # skip steps that need sudo (apt, chsh)
#          ./install.sh --stow     # only (re)create the stow symlinks
# ============================================================================
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zsh tmux nvim yazi starship git bat)
LB="$HOME/.local/bin"; mkdir -p "$LB"

NO_SUDO=0; STOW_ONLY=0
for a in "$@"; do
  case "$a" in
    --no-sudo) NO_SUDO=1 ;;
    --stow)    STOW_ONLY=1 ;;
  esac
done

case "$OSTYPE" in darwin*) OS=macos ;; *) OS=linux ;; esac
say(){ printf "\n\033[1;35m==>\033[0m %s\n" "$*"; }

# ---------------------------------------------------------------------------
# 1. Dependencies
# ---------------------------------------------------------------------------
install_deps_macos() {
  if ! command -v brew >/dev/null; then
    say "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
  fi
  say "brew install tools"
  brew install zsh stow tmux neovim fzf zoxide starship eza bat fd git-delta lazygit yazi
}

install_deps_linux() {
  if [ "$NO_SUDO" -eq 0 ]; then
    say "apt install (needs sudo)"
    sudo apt-get update -y
    sudo apt-get install -y zsh stow tmux eza bat fd-find git-delta build-essential curl unzip git fontconfig
  else
    say "skipping apt (--no-sudo); assuming zsh/stow/tmux/eza/bat/fd present"
  fi
  # Tools that apt ships too old (or not at all) -> userspace into ~/.local
  command -v starship >/dev/null || { say "starship"; curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$LB"; }
  command -v zoxide   >/dev/null || { say "zoxide";   curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh -s -- --bin-dir "$LB"; }
  if [ ! -x "$HOME/.fzf/bin/fzf" ]; then
    say "fzf"; git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" && "$HOME/.fzf/install" --bin
    ln -sf "$HOME/.fzf/bin/fzf" "$LB/fzf"; ln -sf "$HOME/.fzf/bin/fzf-tmux" "$LB/fzf-tmux"
  fi
  if ! command -v nvim >/dev/null || [ ! -x "$LB/nvim" ]; then
    say "neovim (upstream stable)"; curl -sSL -o /tmp/nvim.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    rm -rf "$HOME/.local/nvim"; mkdir -p "$HOME/.local/nvim"
    tar -xzf /tmp/nvim.tar.gz -C "$HOME/.local/nvim" --strip-components=1; ln -sf "$HOME/.local/nvim/bin/nvim" "$LB/nvim"
  fi
  if ! command -v yazi >/dev/null; then
    say "yazi"; curl -sSL -o /tmp/yazi.zip https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip
    rm -rf /tmp/yazi-x; unzip -q /tmp/yazi.zip -d /tmp/yazi-x
    find /tmp/yazi-x -name yazi -exec cp {} "$LB/yazi" \;; find /tmp/yazi-x -name ya -exec cp {} "$LB/ya" \;; chmod +x "$LB/yazi" "$LB/ya"
  fi
  if ! command -v lazygit >/dev/null; then
    say "lazygit"; LGV=$(curl -sSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -oP '"tag_name": *"v\K[0-9.]+' | head -1)
    curl -sSL -o /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LGV}_Linux_x86_64.tar.gz"
    tar -xzf /tmp/lazygit.tar.gz -C "$LB" lazygit; chmod +x "$LB/lazygit"
  fi
}

# ---------------------------------------------------------------------------
# 1b. Nerd Font (needed for icons in eza/starship/yazi/lazygit)
# ---------------------------------------------------------------------------
install_font() {
  if [ "$OS" = macos ]; then
    say "Nerd Font (Homebrew cask)"
    brew list --cask font-jetbrains-mono-nerd-font >/dev/null 2>&1 \
      || brew install --cask font-jetbrains-mono-nerd-font || true
    return
  fi
  if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
    say "Nerd Font already installed"
  else
    say "Installing JetBrainsMono Nerd Font"
    mkdir -p "$HOME/.local/share/fonts"
    curl -sSL -o /tmp/JetBrainsMono.zip \
      https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip \
      && unzip -o -q /tmp/JetBrainsMono.zip -d "$HOME/.local/share/fonts/JetBrainsMonoNerdFont" \
      && fc-cache -f >/dev/null 2>&1
    rm -f /tmp/JetBrainsMono.zip
  fi
  # Best-effort: point GNOME Terminal's default profile at the Nerd Font
  if command -v gnome-terminal >/dev/null && command -v dconf >/dev/null; then
    local pid; pid="$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d "'")"
    if [ -n "$pid" ]; then
      local base="/org/gnome/terminal/legacy/profiles:/:$pid"
      dconf write "$base/use-system-font" "false" 2>/dev/null || true
      dconf write "$base/font" "'JetBrainsMono Nerd Font 12'" 2>/dev/null || true
      say "Set GNOME Terminal font (reopen the terminal to see icons)"
    fi
  fi
}

# ---------------------------------------------------------------------------
# 2. oh-my-zsh + custom plugins + TPM  (both OSes, no sudo)
# ---------------------------------------------------------------------------
install_zsh_plugins() {
  [ -d "$HOME/.oh-my-zsh" ] || git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
  local C="$HOME/.oh-my-zsh/custom/plugins"
  declare -A P=(
    [zsh-autosuggestions]=https://github.com/zsh-users/zsh-autosuggestions
    [zsh-syntax-highlighting]=https://github.com/zsh-users/zsh-syntax-highlighting
    [zsh-completions]=https://github.com/zsh-users/zsh-completions
    [fzf-tab]=https://github.com/Aloxaf/fzf-tab
  )
  for p in "${!P[@]}"; do [ -d "$C/$p" ] || git clone --depth=1 "${P[$p]}" "$C/$p"; done
  [ -d "$HOME/.config/tmux/plugins/tpm" ] || git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
}

# ---------------------------------------------------------------------------
# 3. Stow (back up real files that would conflict)
# ---------------------------------------------------------------------------
do_stow() {
  say "Stowing packages: ${PACKAGES[*]}"
  local stamp; stamp="$(date +%Y%m%d-%H%M%S)"
  for pkg in "${PACKAGES[@]}"; do
    # back up any existing *real* (non-symlink) target files
    while IFS= read -r -d '' f; do
      rel="${f#"$DOTFILES/$pkg/"}"; tgt="$HOME/$rel"
      if [ -e "$tgt" ] && [ ! -L "$tgt" ]; then
        mkdir -p "$(dirname "$tgt")/.dotfiles-backup-$stamp" 2>/dev/null || true
        mv "$tgt" "$HOME/$rel.bak-$stamp"
        echo "   backed up $tgt -> $rel.bak-$stamp"
      fi
    done < <(find "$DOTFILES/$pkg" -type f -print0)
    stow -v -R -t "$HOME" -d "$DOTFILES" "$pkg"
  done
}

# ---------------------------------------------------------------------------
# 4. Post-install
# ---------------------------------------------------------------------------
post_install() {
  say "bat cache (load Catppuccin themes)"
  (command -v bat >/dev/null && bat cache --build) || (command -v batcat >/dev/null && batcat cache --build) || true
  say "yazi Catppuccin flavor"
  command -v ya >/dev/null && (ya pkg add yazi-rs/flavors:catppuccin-mocha 2>/dev/null || ya pack -a yazi-rs/flavors:catppuccin-mocha 2>/dev/null) || true
  say "tmux plugins (TPM)"
  if [ -x "$HOME/.config/tmux/plugins/tpm/bin/install_plugins" ]; then
    tmux start-server 2>/dev/null || true
    tmux new-session -d -s _tpm_setup 2>/dev/null || true
    "$HOME/.config/tmux/plugins/tpm/bin/install_plugins" || true
    tmux kill-session -t _tpm_setup 2>/dev/null || true
  fi
  say "neovim plugin sync (LazyVim) — first launch also does this"
  command -v nvim >/dev/null && nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
}

# ---------------------------------------------------------------------------
# 5. Default shell -> zsh
# ---------------------------------------------------------------------------
set_shell() {
  [ "$NO_SUDO" -eq 1 ] && { say "skipping chsh (--no-sudo). Run: chsh -s \$(which zsh)"; return; }
  local zsh_path; zsh_path="$(command -v zsh)"
  if [ "${SHELL:-}" != "$zsh_path" ]; then
    say "Changing default shell to zsh (may prompt for password)"
    grep -qx "$zsh_path" /etc/shells 2>/dev/null || echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    chsh -s "$zsh_path" || say "chsh failed — run manually: chsh -s $zsh_path"
  fi
}

# ---------------------------------------------------------------------------
main() {
  if [ "$STOW_ONLY" -eq 1 ]; then do_stow; exit 0; fi
  [ "$OS" = macos ] && install_deps_macos || install_deps_linux
  install_font
  install_zsh_plugins
  do_stow
  post_install
  set_shell
  say "Done. Open a new terminal (zsh). In tmux press prefix+I; in nvim run :checkhealth."
}
main
