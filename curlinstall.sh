#!/bin/sh
cd $HOME
git clone "https://github.com/pimparoo/zsh-config"
cd zsh-config
sh install.sh
echo -e "zsh;source \"$HOME/.zshrc\"\n or restart zsh"
