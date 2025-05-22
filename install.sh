#!/usr/bin/env bash

set -euo pipefail

readonly BAT_THEME_LINK="https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme"


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
    ln -s tmux.conf ~/.tmux.conf
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

function setup_fonts() {
    brew install --cask font-code-new-roman-nerd-font
}



install_brew
brew install < brew_packages.txt
install_bat_theme
setup_tmux
setup_fonts