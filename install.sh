#!/bin/bash

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

if [ -e ~/.mouse.zsh ];
then
	if diff ~/.mouse.zsh ./.mouse.zsh > /dev/null;
	then
		echo "mouse.zsh up to date"
		else
			cp .mouse.zsh ~/.mouse.zsh
			echo ".mouse.zsh copied to home"
	fi
fi

echo "Done"
