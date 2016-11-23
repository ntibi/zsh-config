#!/bin/sh

SAVED_PWD="$PWD"

cd "$PWD/$(dirname $0)"

echo "checking for updates..."
git pull

if [ ! -e "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ];
then
	echo "linking $HOME/.zshrc with ./.zshrc"
	ln -s "$(pwd)/.zshrc" "$HOME/.zshrc"
else
	if [ -L "$HOME/.zshrc" ];
	then
		if [ $(readlink "$HOME/.zshrc") = $(echo "$(pwd)/.zshrc") ];
		then
			echo "new .zshrc already installed"
		else
			echo "removing old $HOME/.zshrc pointing at $(readlink $HOME/.zshrc)"
			unlink "$HOME/.zshrc"
			echo "linking $HOME/.zshrc with $(pwd)/.zshrc"
			ln -s "$(pwd)/.zshrc" "$HOME/.zshrc"
		fi
	else
		echo "linking $HOME/.zshrc with .zshrc"
		echo "old $HOME/.zshrc content is now in $HOME/.oldzshrc"
		cat "$HOME/.zshrc" >> "$HOME/.oldzshrc"
		rm "$HOME/.zshrc"
		ln -s "$(pwd)./.zshrc" "$HOME/.zshrc"
	fi
fi

echo "type 'source $HOME/.zshrc' to apply update"
echo "Done"

cd "$SAVED_PWD"
