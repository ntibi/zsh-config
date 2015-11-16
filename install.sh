#!/bin/sh

INSTALL_DIR=$(basename $0)

echo "checking for updates..."
git pull

if [ ! -e "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ];
then
	echo "linking $HOME/.zshrc with ./.zshrc"
	ln -s "$iNSTALL_DIR/.zshrc" "$HOME/.zshrc"
else
	if [ -L "$HOME/.zshrc" ];
	then
		if [ $(readlink "$HOME/.zshrc") = $(echo "$iNSTALL_DIR/.zshrc") ];
		then
			echo "new .zshrc already installed"
		else
			echo "removing old $HOME/.zshrc pointing at $(readlink $HOME/.zshrc)"
			unlink "$HOME/.zshrc"
			echo "linking $HOME/.zshrc with .zshrc"
			ln -s "$iNSTALL_DIR/.zshrc" "$HOME/.zshrc"
		fi
	else
		echo "linking $HOME/.zshrc with .zshrc"
		echo "old $HOME/.zshrc content is now in $HOME/.oldzshrc"
		cat "$HOME/.zshrc" >> "$HOME/.oldzshrc"
		rm "$HOME/.zshrc"
		ln -s "$iNSTALL_DIR/.zshrc" "$HOME/.zshrc"
	fi
fi

echo "type 'source $HOME/.zshrc' to apply update"
echo "Done"

