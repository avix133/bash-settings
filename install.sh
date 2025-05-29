#!/usr/bin/env bash

_SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

set -euo pipefail

readonly BAT_THEME_LINK="https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme"
readonly TMUX_CONFIG_DIR="$HOME/.config/tmux"

function install_bat_theme() {
  mkdir -p "$(bat --config-dir)/themes"
  cd "$(bat --config-dir)/themes"
  curl -O $BAT_THEME_LINK
  bat cache --build
}

function install_brew() {
  if [ -x "$(command -v brew)" ]; then
    echo "brew is already installed"
  else
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
}

function setup_tmux() {
  mkdir -p "$TMUX_CONFIG_DIR"
  ln -s "${_SCRIPT_DIR}/tmux.conf" "$TMUX_CONFIG_DIR/tmux.conf"
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  git clone https://github.com/ThePrimeagen/tmux-sessionizer.git "$HOME/.local/scripts/"
}

function setup_fonts() {
  brew install --cask font-code-new-roman-nerd-font
}

install_brew
brew install <brew_packages.txt
install_bat_theme
setup_tmux
setup_fonts

