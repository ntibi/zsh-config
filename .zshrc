export PS1="%n@%m [%~] %#> "
export RPS1="%t"

alias e="emacs"
alias q="emacs -q"

export editor=emacs

alias ss="du -a . | sort -n -r | head -n 10"

source ".mouse.zsh"
# zle-toggle-mouse_	to enable mouse

autoload -U colors && colors

autoload -U compinit && compinit # enable completion
zmodload zsh/complist			# load compeltion list
zstyle ":completion:*" menu select # select menu completion

zstyle ":completion:*" group-name "" # group completion

zstyle ":completion:*:warnings" format "Nope !" # custom error

zstyle ":completion:::::" completer _complete _approximate # approx completion after regular one
zstyle ":completion:*:approximate:*" max-errors 2		   # complete 2 errors max
# zstyle ":completion:*:approximate:*" max-errors "reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )" # one error each 3 characters

alias -s c=emacs				# alias {}.c=emacs{file}.c
alias -s h=emacs
alias -s cpp=emacs
alias -s hpp=emacs
alias -s py=emacs
alias -s el=emacs
alias -s emacs=emacs

alias l="ls -lFh"
alias la="ls -lAFh"
alias lt="ls -ltFh"
alias ll="ls -l"
alias grep="grep --color"

alias ressource="source ~/.zshrc"

setopt histignoredups			# ignore dups in history
