#!/bin/sh

echo "checking for updates..."
git pull

if [ ! -e ~/.zshrc ];
then
	echo "linking ~/.zshrc with ./.zshrc"
	ln -s ./.zshrc ~/.zshrc
else
	if [ -L ~/.zshrc ];
	then
		if [ $(readlink -f ~/.zshrc) = $(echo "$PWD/.zshrc") ];
		then
			echo "new .zshrc already installed"
		else
			echo "removing old ~/.zshrc pointing at $(readlink ~/.zshrc)"
			rm ~/.zshrc
			echo "linking ~/.zshrc with .zshrc"
			ln -s ./.zshrc ~/.zshrc
		fi
	else
		echo "linking ~/.zshrc with .zshrc"
		echo "old ~/.zshrc content is now in ~/.myzshrc"
		cat ~/.zshrc >> ~/.myzshrc
		rm ~/.zshrc
		ln -s ./.zshrc ~/.zshrc
	fi
fi

echo "type 'source ~/.zshrc' to apply update"
echo "Done"

