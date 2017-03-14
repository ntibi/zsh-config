#!/bin/sh


REPO_BASE="$(dirname "$PWD/$0")"
REPO_ZSHRC="$(realpath $REPO_BASE/zshrc)"

SAVED_PWD="$PWD"

echo "checking for updates..."
git --git-dir $REPO_BASE/.git pull

if [ ! -e "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ];
then
	echo "linking $HOME/.zshrc with ./.zshrc"
	ln -s $REPO_ZSHRC "$HOME/.zshrc"
else
	if [ -L "$HOME/.zshrc" ];
	then
		if [ $(readlink "$HOME/.zshrc") = $(echo $REPO_ZSHRC) ];
		then
			echo "new .zshrc already installed"
		else
			echo "removing old $HOME/.zshrc pointing at $(readlink $HOME/.zshrc)"
			unlink "$HOME/.zshrc"
			echo "linking $HOME/.zshrc with $REPO_ZSHRC"
			ln -s $REPO_ZSHRC "$HOME/.zshrc"
		fi
	else
		echo "linking $HOME/.zshrc with .zshrc"
		echo "old $HOME/.zshrc content is now in $HOME/.oldzshrc"
		cat "$HOME/.zshrc" >> "$HOME/.oldzshrc"
		rm "$HOME/.zshrc"
		ln -s $REPO_ZSHRC "$HOME/.zshrc"
	fi
fi

echo "type 'source $HOME/.zshrc' to apply update"
echo "Done"
