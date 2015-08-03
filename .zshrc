[ -e ~/.myzshrc ] && source ~/.myzshrc # load my user file


# setup zsh

export PS1="%n@%m [%~] %#> "
export RPS1="%t"

export EDITOR="emacs -q"
export VISUAL="emacs -q"

HISTFILE=~/.zshrc_history
SAVEHIST=512
HISTSIZE=512

setopt inc_append_history
setopt share_history
setopt histignoredups			# ignore dups in history
setopt hist_expire_dups_first	# remove all dubs in history when full
setopt auto_remove_slash		# remove slash when pressing space in auto completion
setopt nullglob					# remove pointless globs
setopt auto_cd					# './dir' = 'cd dir'
unsetopt rm_star_silent			# ask for confirmation if 'rm *'
unsetopt beep					# no sounds
# setopt print_exit_value			# print exit value if non 0

source ~/.mouse.zsh				# zle-toggle-mouse_	to enable mouse

autoload -U colors && colors	# cool colors

autoload -U compinit && compinit # enable completion
zmodload zsh/complist			# load compeltion list

zstyle ':completion:*:rm:*' ignore-line yes # remove suggestion if already in selection
zstyle ':completion:*:mv:*' ignore-line yes # same
zstyle ':completion:*:cp:*' ignore-line yes # same

zstyle ":completion:*" menu select # select menu completion

zstyle ':completion:*' list-colors '' # enable colors in completion

zstyle ":completion:*" group-name "" # group completion

zstyle ":completion:*:warnings" format "Nope !" # custom error

zstyle ":completion:::::" completer _complete _approximate # approx completion after regular one
# zstyle ":completion:*:approximate:*" max-errors 2		   # complete 2 errors max
zstyle ":completion:*:approximate:*" max-errors "reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )" # allow one error each 3 characters

bindkey -e 						# emacs style

autoload -z edit-command-line
zle -N edit-command-line

bindkey "^X^E" edit-command-line # edit line with $EDITOR
bindkey "^w" kill-region		 # emacs-like kill
bindkey -s "\el" "ls\n"			 # run ls
bindkey -s "^X^X" "emacs\n"		 # run emacs
bindkey -s "^X^M" "make\n"		 # make

if [[ "${terminfo[kcuu1]}" != "" ]]; then
	bindkey "${terminfo[kcuu1]}" up-line-or-search # smart search if line is not empty when keyup
fi

if [[ "${terminfo[kcud1]}" != "" ]]; then
	bindkey "${terminfo[kcud1]}" down-line-or-search # same for keydown
fi


# useful aliases

alias -s c=emacs				# alias {file}.c=emacs{file}.c
alias -s h=emacs
alias -s cpp=emacs
alias -s hpp=emacs
alias -s py=emacs
alias -s el=emacs
alias -s emacs=emacs

alias l="ls -lFh"				# list + classify + human readable
alias la="ls -lAFh"				# l with hidden files
alias lt="ls -ltFh"				# l with modification date sort
alias ll="ls -l"				# simple list
alias grep="grep --color"

alias ressource="source ~/.zshrc"

alias e="emacs"
alias q="emacs -q"				# fast emacs

alias ss="du -a . | sort -nr | head -n10" # get the 10 biggest files

alias .="ls"

uname -a
uptime
