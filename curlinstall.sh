#!/bin/sh
cd $HOME
git clone "https://github.com/pimparoo/zsh-config"
cd zsh-config
sh install.sh
source "$HOME/.zshrc"
