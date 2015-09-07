#!/bin/sh

echo "checking for updates..."
git pull

if [ ! -e ~/.zshrc ] && [ ! -L ~/.zshrc ];
then
	echo "linking ~/.zshrc with ./.zshrc"
	ln -s "$PWD/.zshrc" "$HOME/.zshrc"
else
	if [ -L ~/.zshrc ];
	then
		if [ $(readlink ~/.zshrc) = $(echo "$PWD/.zshrc") ];
		then
			echo "new .zshrc already installed"
		else
			echo "removing old ~/.zshrc pointing at $(readlink ~/.zshrc)"
			unlink ~/.zshrc
			echo "linking ~/.zshrc with .zshrc"
			ln -s "$PWD/.zshrc" "$HOME/.zshrc"
		fi
	else
		echo "linking ~/.zshrc with .zshrc"
		echo "old ~/.zshrc content is now in ~/.oldzshrc"
		cat ~/.zshrc >> ~/.oldzshrc
		rm ~/.zshrc
		ln -s ./.zshrc ~/.zshrc
	fi
fi

echo "type 'source ~/.zshrc' to apply update"
echo "Done"

