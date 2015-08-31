[ -e ~/.myzshrc ] && source ~/.myzshrc # load user file


# setup zsh

[ "$TERM" = "xterm" ] && export TERM="xterm-256color"

# Only called once

PWD_FILE=~/.pwd					# last pwd sav file

GET_SHLVL="$([[ $SHLVL -gt 9 ]] && echo "+" || echo $SHLVL)"

GET_SSH="$([[ $(echo $SSH_TTY$SSH_CLIENT$SSH_CONNECTION) != '' ]] && echo '%F{blue}ssh%F{red}:%F{blue}')"


function join_others_shells()	# ask for joining path specified in $PWD_FILE
{
	if [[ -e $PWD_FILE ]]; then
		read -q "R?Go to $(tput setaf 3)$(cat $PWD_FILE)$(tput setaf 7) ? (Y/n):"
		[[ $R = "y" ]] && cd "$(cat $PWD_FILE)"
	fi
}

function check_git_repo()		# check if pwd is a git repo
{
	[[ ! -e ./.git ]]
	REPO=$?
}

function update_pwd_datas()		# update the numbers of files and dirs in .
{
	local v
	v=$(ls -pA1)
	NB_FILES=$(echo $v | grep -v /$ | wc -l)
	NB_DIRS=$(echo $v | grep /$ | wc -l)
}

function update_pwd_save()		# update the $PWD_FILE
{
	[[ $PWD != ~ ]] && echo $PWD > $PWD_FILE
}

function set_git_char()			# set the $GET_GIT_CHAR variable for the prompt
{
	if [ $REPO -eq 1 ];		# if in git repo, get git infos
	then
		local STATUS
		STATUS=$(git status)
		if [[ $STATUS =~ "Changes not staged" ]];
		then GET_GIT="%F{red}+"	# if git diff, wip
		else
			if [[ $STATUS =~ "Changes to be committed" ]];
			then GET_GIT="%F{yellow}+" # changes added
			else
				if [[ $STATUS =~ "is ahead" ]];
				then GET_GIT="%F{green}+" # changes commited
				else GET_GIT="%F{green}=" # changes pushed
				fi
			fi
		fi
	else
		GET_GIT="%F{cyan}o"		# not in git repo
	fi
}


function chpwd()				# chpwd hook
{
	check_git_repo
	update_pwd_datas
	update_pwd_save
}

function periodic()				# every $PERIOD secs
{
	rehash						# rehash path binaries
	check_git_repo
	update_pwd_datas
	update_pwd_save
}
PERIOD=5

function preexec()				# pre execution hook
{
	print -Pn "\e]2;$PWD : $1\a" # print pwd + cmd in window title
}

function precmd()				# pre promt hook
{
	print -Pn "\e]2;$PWD\a"		# print pwd in window title
	
	set_git_char
}


PS1=''
PS1+='%B%F{blue}$GET_SSH'
PS1+='%n%b%F{red}@%B%F{blue}%m%b'
PS1+='%F{red}[%F{magenta}%~%b%F{red}|'
PS1+='%F{green}$NB_FILES%F{red}/%F{blue}$NB_DIRS%F{red}]'
PS1+=' %(0?.%F{green}✔.%F{red}×)'
PS1+='$GET_GIT'
PS1+='%(1j.%F{yellow}►.%F{blue}o)'
PS1+='%F{magenta}$GET_SHLVL'
PS1+='%(0!.%F{red}#.%F{blue}\$)'
PS1+='%F{red}>%f '

PS1_RIGHT="%U%B%F{yellow}%T%u%f"

RPS1=$PS1_RIGHT

# PS1='%B%F{blue}%n%b%F{red}@%B%F{blue}%m%b %F{red}[%B%F{magenta}%~%b%F{red}] %F{red}%#> %f' # light

EDITOR="emacs"
VISUAL="emacs"

export LS_COLORS='fi=1;32:di=1;34:ln=35:so=32:pi=0;33:ex=32:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=1;34:ow=1;34:'

bindkey "$(echotc kl)" backward-char
bindkey "$(echotc kr)" forward-char
bindkey "$(echotc ku)" up-line-or-history
bindkey "$(echotc kd)" down-line-or-history

HISTFILE=~/.zshrc_history
SAVEHIST=1024
HISTSIZE=1024

setopt promptsubst				# compute PS1 at each prompt print
setopt inc_append_history
setopt share_history
setopt histignoredups			# ignore dups in history
setopt hist_expire_dups_first	# remove all dubs in history when full
setopt auto_remove_slash		# remove slash when pressing space in auto completion
setopt nullglob					# remove pointless globs
setopt auto_cd					# './dir' = 'cd dir'
setopt cbases					# c-like bases conversions
setopt emacs
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

zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

zstyle ":completion:*" group-name "" # group completion

zstyle ":completion:*:warnings" format "Nope !" # custom error

zstyle ":completion:::::" completer _complete _approximate # approx completion after regular one
# zstyle ":completion:*:approximate:*" max-errors 2		   # complete 2 errors max
zstyle ":completion:*:approximate:*" max-errors "(( ($#PREFIX+$#SUFFIX)/3 ))" # allow one error each 3 characters

zle -C complete-file complete-word _generic
zstyle ':completion:complete-file::::' completer _files


bindkey -e 						# emacs style

if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  function zle-line-init() { echoti smkx }
  function zle-line-finish() { echoti rmkx }
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
bindkey -s "\el" "ls\n"			 # run ls
bindkey -s "^X^X" "emacs\n"		 # run emacs

bindkey "^[[1;3C" emacs-forward-word # alt + keys to navigate between words
bindkey "^[[1;3D" emacs-backward-word
bindkey "^[[1;5D" backward-word	# same with ctrl
bindkey "^[[1;5C" forward-word

bindkey "^[k" kill-word
bindkey "^w" kill-region		 # emacs-like kill

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

alias ls="ls --color"

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

check_git_repo
update_pwd_datas
update_pwd_save
set_git_char
rehash							# hash commands in path
uname -a						# give some infos about hardware
uptime							# show uptime

join_others_shells				# ask for joining others shells
