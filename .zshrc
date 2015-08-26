[ -e ~/.myzshrc ] && source ~/.myzshrc # load my user file


# setup zsh

PS1='%B%F{blue}%n%b%F{red}@%B%F{blue}%m%b %F{red}[%B%F{magenta}%~%b%F{red}] %F{cyan}$([[ $? -ne 0 ]] && echo "×" || echo "✔")$([[ $(jobs) != "" ]] && echo "►" || echo "○")%#%F{red}> %f' # heavy
# PS1='%B%F{blue}%n%b%F{red}@%B%F{blue}%m%b %F{red}[%B%F{magenta}%~%b%F{red}] %F{red}%#> %f' # light

RPS1="%B%F{yellow}%T%f"

if [[ $(echo $SSH_TTY$SSH_CLIENT$SSH_CONNECTION) != "" ]]
then
	PS1 = echo $PS1 | sed 's/%n/%F{blue}ssh%F{red}:%F{blue}%n/g';
fi


export EDITOR="emacs -q"
export VISUAL="emacs -q"

bindkey "$(echotc kl)" backward-char
bindkey "$(echotc kr)" forward-char
bindkey "$(echotc ku)" up-line-or-history
bindkey "$(echotc kd)" down-line-or-history

HISTFILE=~/.zshrc_history
SAVEHIST=512
HISTSIZE=512

setopt promptsubst
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
zstyle ":completion:*:approximate:*" max-errors 2		   # complete 2 errors max
# zstyle ":completion:*:approximate:*" max-errors "reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )" # allow one error each 3 characters

zle -C complete-file complete-word _generic
zstyle ':completion:complete-file::::' completer _files


bindkey -e 						# emacs style

if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  function zle-line-init() {
    echoti smkx
  }
  function zle-line-finish() {
    echoti rmkx
  }
  zle -N zle-line-init
  zle -N zle-line-finish
fi


insert_sudo () { zle beginning-of-line; zle -U "sudo " }
zle -N insert-sudo insert_sudo
bindkey "^[s" insert-sudo

autoload -z edit-command-line
zle -N edit-command-line

bindkey "[/" complete-file		# complete files only
bindkey "^X^E" edit-command-line # edit line with $EDITOR
bindkey "^x^T" zle-toggle-mouse
bindkey "^w" kill-region		 # emacs-like kill
bindkey -s "\el" "ls\n"			 # run ls
bindkey -s "^X^X" "emacs\n"		 # run emacs
bindkey "^[[1;3C" emacs-forward-word # alt + keys to navigate between words
bindkey "^[[1;3D" emacs-backward-word

bindkey -s "^X^M" "make\n"		 # make

if [[ "${terminfo[kcbt]}" != "" ]]; then
  bindkey "${terminfo[kcbt]}" reverse-menu-complete # shift tab for backward completion
fi

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

alias l="ls -G"

alias l="ls -lFh"				# list + classify + human readable
alias la="ls -lAFh"				# l with hidden files
alias lt="ls -ltFh"				# l with modification date sort
alias ll="ls -l"				# simple list
alias grep="grep --color"
alias egrep="egrep --color=auto"

alias ressource="source ~/.zshrc"

alias e="emacs"
alias q="emacs -q"				# fast emacs

alias ss="du -a . | sort -nr | head -n10" # get the 10 biggest files

alias .="ls"

uname -a
uptime
