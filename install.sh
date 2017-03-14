#!/bin/sh


REPO_BASE="$(dirname "$PWD/$0")"
REPO_ZSHRC="$(readlink -f $REPO_BASE/zshrc)"

DEST="$HOME/.zshrc"

echo "checking for updates..."
git --git-dir $REPO_BASE/.git pull

if [ ! -e $DEST ] && [ ! -L $DEST ];
then
	echo "linking $DEST with $REPO_ZSHRC"
	ln -s $REPO_ZSHRC $DEST
else
	if [ -L $DEST ];
	then
		if [ $(readlink $DEST) = $(echo $REPO_ZSHRC) ];
		then
			echo "new .zshrc already installed"
		else
			echo "removing old $DEST pointing at $(readlink $DEST)"
			unlink $DEST
			echo "linking $DEST with $REPO_ZSHRC"
			ln -s $REPO_ZSHRC $DEST
		fi
	else
		echo "linking $DEST with $REPO_ZSHRC"
		cat $DEST >> "$HOME/.oldzshrc"
		echo "old $DEST content is now in $HOME/.oldzshrc"
		rm $DEST
		ln -s $REPO_ZSHRC $DEST
	fi
fi

echo "type 'source $DEST' to apply update"
echo "Done"
