#!/bin/bash

if [ ! -e ~/.zshrc ];
then
	echo "linking ~/.zshrc with ./.zshrc"
	ln -s ./.zshrc ~/.zshrc
else
	if [ -L ~/.zshrc ];
	then
		if [ $(readlink -f ~/.zshrc) = $(echo "$PWD/.zshrc") ];
		then
			echo "new config already installed"
		else
			echo "removing old ~/.zshrc pointing at $(readlink ~/.zshrc)"
			rm ~/.zshrc
			echo "linking ~/.zshrc with ./.zshrc"
			ln -s ./.zshrc ~/.zshrc
		fi
		else
			echo "linking ~/.zshrc with ./.zshrc"
			echo "old ~/.zshrc content is now in ~/.myzshrc"
			cat ~/.zshrc >> ~/.myzshrc
			rm ~/.zshrc
			ln -s ./.zshrc ~/.zshrc
	fi
fi

cp .mouse.zsh ~/.mouse.zsh
echo ".mouse.zsh copied to home"

echo "Done"
