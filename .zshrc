# # # # # # # #
# TODO:
#
# Don't list all the files in back if there is too many of them
# Set the backup path dynamically instead of "/tmp/backup"
# Add pagination in the back function
#
# Set a nice PS4
#
# Create a working todo function
#
# try the zcurses module (zmodload zsh/curses)
#
# # # # # # # #

[ -e ~/.myzshrc ] && source ~/.myzshrc # load user file if any

TERM="xterm-256color" && [[ $(tput colors) == 256 ]] || echo "can't use xterm-256color :/" # check if xterm-256 color is available, or if we are in a dumb shell


# USEFUL VARS #

PERIOD=5			  # period used to hook periodic function (in sec)

PWD_FILE=~/.pwd					# last pwd sav file
CA_FILE=~/.ca					# cd aliases sav file

DEF_C="$(tput sgr0)"

OS="$(uname)"					# get the os name

UPDATE_TERM_TITLE="yep" # set to update the term title according to the path and the currently executed line
UPDATE_CLOCK="yep"	  # set to update the top-right clock every second

# (UN)SETTING ZSH (COOL) OPTIONS #

setopt promptsubst				# compute PS1 at each prompt print
setopt inc_append_history
setopt share_history
setopt histignoredups			# ignore dups in history
setopt hist_expire_dups_first	# remove all dubs in history when full
setopt auto_remove_slash		# remove slash when pressing space in auto completion
setopt nullglob					# remove pointless globs
setopt auto_cd					# './dir' = 'cd dir'
setopt cbases					# c-like bases conversions
setopt emacs					# enable emacs like keybindigs
setopt flow_control				# enable C-q and C-s to control the flooow
setopt completeinword			# complete from anywhere
setopt shwordsplit				# sh like word split
# setopt print_exit_value			# print exit value if non 0

unsetopt beep					# no disturbing sounds


case "$(uname)" in
	*Darwin*)					# Mac os
		PM="brew install"
		alias update="brew update && brew upgrade"
		LS_COLORS='exfxcxdxbxexexabagacad'
		alias ls="ls -G";;
	*cygwin*)
		PM="pact install"
		LS_COLORS='fi=1;32:di=1;34:ln=35:so=32:pi=0;33:ex=32:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=1;34:ow=1;34:'
		alias ls="ls --color=always";;
	*Linux*|*)
		PM="sudo apt-get install"
		alias update="sudo apt-get update && sudo apt-get upgrade"
		LS_COLORS='fi=1;32:di=1;34:ln=35:so=32:pi=0;33:ex=32:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=1;34:ow=1;34:'
		alias ls="ls --color=always";;
esac



# PS1 FUNCTIONS #

function check_git_repo()		# check if pwd is a git repo
{
	git rev-parse > /dev/null 2>&1 && REPO=1 || REPO=0
}

function update_pwd_datas()		# update the numbers of files and dirs in .
{
	local v
	v=$(ls -pA1)
	NB_FILES=$(echo "$v" | grep -v /$ | wc -l | tr -d ' ')
	NB_DIRS=$(echo "$v" | grep /$ | wc -l | tr -d ' ')
}

function update_pwd_save()		# update the $PWD_FILE
{
	[[ $PWD != ~ ]] && echo $PWD > $PWD_FILE
}

function set_git_branch()
{
	if [ $REPO -eq 1 ]; then		# if in git repo, get git infos
		GIT_BRANCH="$(git branch | grep \* | cut -d\  -f2)";
	else
		GIT_BRANCH="";
	fi
}

function set_git_char()			# set the $GET_GIT_CHAR variable for the prompt
{
	if [ $REPO -eq 1 ];		# if in git repo, get git infos
	then
		local STATUS
		STATUS=$(git status 2> /dev/null)
		if [[ $STATUS =~ "Changes not staged" ]];
		then GET_GIT="%F{196}+"	# if git diff, wip
		else
			if [[ $STATUS =~ "Changes to be committed" ]];
			then GET_GIT="%F{214}+" # changes added
			else
				if [[ $STATUS =~ "is ahead" ]];
				then GET_GIT="%F{46}+" # changes commited
				else GET_GIT="%F{46}=" # changes pushed
				fi
			fi
		fi
	else
		GET_GIT="%F{240}o"		# not in git repo
	fi
}


PRE_CLOCK="$(tput setaf 226;tput smul;tput bold;tput civis)" # caching termcaps strings
POST_CLOCK="$(tput cnorm;tput sgr0;)"
function clock()				# displays the time in the top right corner
{
	if [ ! -z $UPDATE_CLOCK ]; then
		tput sc;
		tput cup 0 $(( $(tput cols) - 6));
		echo "$PRE_CLOCK$(date +%R)$POST_CLOCK";
		tput rc;
	fi
}


# CALLBACK FUNCTIONS #

function chpwd()				# chpwd hook
{
	check_git_repo
	set_git_branch
	update_pwd_datas
	update_pwd_save
}

function periodic()				# every $PERIOD secs - triggered by promt print
{
	check_git_repo
	set_git_branch
	update_pwd_datas
	update_pwd_save
}

function preexec()				# pre execution hook
{
	[ -z $UPDATE_TERM_TITLE ] || print -Pn "\e]2;$PWD : $1\a" # set 'pwd + cmd' set term title
}

function precmd()				# pre promt hook
{
	clock
	[ -z $UPDATE_TERM_TITLE ] || print -Pn "\e]2;$PWD\a"		# set pwd as term title
	
	set_git_char
}


# USEFUL USER FUNCTIONS #

function ca()					# add cd alias (ca <alias_name> || ca <alias_name> <aliased path>)
{
	local a
	local p
	p=$(pwd)
	if [ "$#" -ne 1 ] && [ "$#" -ne 2 ]; then
		echo "Usage: ca alias (path)";
		return;
	fi;
	if [ "$#" -eq 2 ]; then
		[ ${2:0:1} = '/' ] && p="$2" || p+="/$2"
	fi;
	a=$1
	touch $CA_FILE;
	if [ "$(grep "^$a=" $CA_FILE)" != "" ]; then
		echo "replacing old '$a' alias"
		sed -i "s/^$a=.*$//g" $CA_FILE;
		sed -i "/^$/d" $CA_FILE;
	fi;
	echo "$a=$p" >> $CA_FILE;
}

function dca()					# delete cd alias (dca <alias 1> <alias 2> ... <alias n>)
{
	local a
	if [ -e $CA_FILE ] && [ "$#" -gt 0 ]; then
		for a in "$@"
		do
			sed -i "s/^$a=.*$//g" $CA_FILE;
		done
		sed -i "/^$/d" $CA_FILE;
	fi
}

function sca()					# show cd aliases
{
	[ -e $CA_FILE ] && cat $CA_FILE | egrep --color=always "^[^=]+" || echo "No cd aliases yet";
}

function cd()					# cd wrap to use aliases - priority over real path instead of alias
{
	local a
	local p
	if [ -e $CA_FILE ] && [ "$#" -eq 1 ] && [ ! -d $1 ]; then
		a="$(command grep -o "^$1=.*$" $CA_FILE)";
		if [ "$a" != "" ]; then
			p="$(echo $a | cut -d'=' -f2)"
			builtin cd "$p" 2> /dev/null && echo $p || echo "Invalid alias '$a'" 1>&2;
			return 0;
		fi;
	fi;
	builtin cd "$@" 2> /dev/null || echo "Nope" 1>&2;
}

function showcolors()			# display the 256 colors by shades - useful to get pimpy colors
{
	for c in {0..15}; do tput setaf $c ; echo -ne " $c "; done # 16 colors
	echo
	for s in {16..51}; do		# all the color tints
		for ((i = $s; i < 232; i+=36)); do
			tput setaf $i ; echo -ne " $i ";
		done;
		echo
	done
	for c in {232..255}; do tput setaf $c ; echo -ne " $c "; done # grey tints
	echo
}

function error()				# give error nb to get the corresponding error string
{
	python -c "import os; print os.strerror($?)";
}

function join_others_shells()	# ask for joining path specified in $PWD_FILE if not already in it
{
	if [[ -e $PWD_FILE ]] && [[ $(pwd) != $(cat $PWD_FILE) ]]; then
		read -q "?Go to $(tput setaf 3)$(cat $PWD_FILE)$(tput setaf 7) ? (Y/n):"  && cd "$(cat $PWD_FILE)"
	fi
}

function loop()					# loop parameter command every $LOOP_INT seconds (default 1)
{
	local d
	[ -z "$LOOP_INT" ] && LOOP_INT=1
	while true
	do
		clear
		d=$(date +%s)
		$@
		while [ "$(( $(date +%s) - d ))" -lt "$LOOP_INT" ]; do sleep 0.1; done
	done
}

function pc()			  		# percent of the home taken by this dir/file
{
	local subdir
	local dir

	if [ "$#" -eq 0 ]; then
		subdir=.
		dir=$HOME
	else if [ "$#" -eq 1 ]; then
			 subdir=$1
			 dir=$HOME
		 else if [ "$#" -eq 2 ]; then
				  subdir=$1
				  dir=$2
			  else
				  echo "Usage: pc <dir/file a>? <dir b>? to get the % of the usage of b by a"
				  return 1
			  fi
		 fi
	fi
	echo "$(($(du -sx $subdir | cut -f1) * 100 / $(du -sx $dir | cut -f1)))" "%"
}

function tmp()					# starts a new shubshell in /tmp
{
	env STARTUP_CMD="cd /tmp" zsh;
}

function -() 					# if 0 params, acts like 'cd -', else, act like the regular '-'
{
	[[ $# -eq 0 ]] && cd - || builtin - "$@"
}


# faster find allowing easier parameters in disorder
function ff()
{
	local p
	local name=""
	local type=""
	local additional=""
	local hidden=" -not -regex .*/\..*" # hide hidden files by default
	local root="."
	for p in "$@"; do
		if $(echo $p | grep -Eq "^n?[herwxbcdflps]$"); # is it a type ?
		then
			if $(echo $p | grep -q "n"); then # handle command negation
				neg=" -not"
				p=${p/n/}		# remove the 'n' from p, to get the real type
			else
				neg=""
			fi
			case $p in
				h) [ -z $neg ] && hidden="" || hidden=" -not -regex .*/\..*";;
				e) additional+="$neg -empty";;
				r) additional+="$neg -readable";;
				w) additional+="$neg -writable";;
				x) additional+="$neg -executable";;
				*) type+=$([ -z "$type" ] && echo "$neg -type $p" || echo " -or $neg -type $p");;
			esac
		else if [ -d $p ];		# is it a path ?
			 then
				 root=$p
			 else				# then its a name !
				 name+="$([ -z "$name" ] && echo " -name $p" || echo " -or -name $p")";
			 fi
		fi
	done
	if [ -t ]; then				# disable colors if piped
		find -O3 $(echo $root $name $additional $hidden $([ ! -z "$type" ] && echo "(") $type $([ ! -z "$type" ] && echo ")") | sed 's/ +/ /g') 2>/dev/null | grep --color=always "^\|[^/]*$" # re split all to spearate parameters and colorize filename
	else
		find -O3 $(echo $root $name $additional $hidden $type | sed 's/ +/ /g') 2>/dev/null
	fi
}

function colorcode()  			# get the code to set the corresponding fg color
{
	for c in "$@"; do
		tput setaf $c;
		echo -e "\"$(tput setaf $c | cat -v)\""
	done
}

function colorize() 			# cmd | colorize <exp1> <color1> <exp2> <color2> ... to colorize expr with color # maybe change the syntax to <regex>:fg:bg?:mod? ...
{
	local i
	local last
	local params
	local col
	i=0
	params=""
	col=""
	for c in "$@"; do
		case $c in
			"black") 	col=0;;
			"red") 		col=1;;
			"green") 	col=2;;
			"yellow") 	col=3;;
			"blue") 	col=4;;
			"purple") 	col=5;;
			"cyan") 	col=6;;
			"white") 	col=7;;
			*) 			col=$c;;
		esac
		if [ "$((i % 2))" = "1" ]; then
			params+=" -e s/($last)/$(tput setaf $col)\1$(tput sgr0)/g" # investigate about ```MDR=""; MDR="-e"; echo $MDR```
		else
			last=$c
		fi
		i=$(( i + 1))
	done
	if [ "$c" = "$last" ]; then
		echo "Usage: cmd | colorize <exp1> <color1> <exp2> <color2> ..."
		return
	fi
	sed -re $(echo $params) 2>/dev/null || echo "Usage: cmd | colorize <exp1> <color1> <exp2> <color2> ..."
}

function ts()					# timestamps operations (`ts` to get current, `ts <timestamp>` to know how long ago, `ts <timestamp1> <timestamp2>` timestamp diff)
{
	local delta;
	if [ $# = 0 ]; then
		date +%s;
	elif [ $# = 1 ]; then
		delta=$(( $(date +%s) - $1 ));
		if [ $delta -gt 30758400 ]; then echo -n "$(( delta / 30758400 )) y "; delta=$(( delta % 30758400 )); fi
		if [ $delta -gt 86400 ]; then echo -n "$(( delta / 86400 )) d "; delta=$(( delta % 86400 )); fi
		if [ $delta -gt 3600 ]; then echo -n "$(( delta / 3600 )) h "; delta=$(( delta % 3600 )); fi
		if [ $delta -gt 60 ]; then echo -n "$(( delta / 60 )) m "; delta=$(( delta % 60 )); fi
		echo "$delta s ago";
	elif [ $# = 2 ]; then
			delta=$(( $2 - $1 ))
			[ $delta -lt 0 ] && delta=$(( -delta ))
		if [ $delta -gt 30758400 ]; then echo -n "$(( delta / 30758400 )) y "; delta=$(( delta % 30758400 )); fi
		if [ $delta -gt 86400 ]; then echo -n "$(( delta / 86400 )) d "; delta=$(( delta % 86400 )); fi
		if [ $delta -gt 3600 ]; then echo -n "$(( delta / 3600 )) h "; delta=$(( delta % 3600 )); fi
		if [ $delta -gt 60 ]; then echo -n "$(( delta / 60 )) m "; delta=$(( delta % 60 )); fi
		echo "$delta s";
	fi
}

function rrm()					# real rm
{
	command rm $@;
}

function rm()					# safe rm with timestamped backup
{
	if [ $# -gt 0 ]; then
		local backup;
		local idir;
		local rm_params;
		idir="";
		rm_params="";
		backup="/tmp/backup/$(date +%s)";
		command mkdir -p "$backup";
		for i in "$@"; do
			if [ ${i:0:1} = "-" ]; then # if $i is an args list, save them
				rm_params+="$i";
			elif [ -e $i ] || [ -d $i ]; then # $i exist ?
				if [ ${i:0:4} = "/tmp" ]; then # really remove files if they are in /tmp
					command rm "$rm_params" "$i";
				else
					[ ! ${i:0:1} = "/" ] && i="$PWD/$i"; # if path is not absolute, make it absolute
					i="$(realpath $i)";						# simplify the path
					idir="$(dirname $i)";
					command mkdir -p "$backup/$idir";
					mv "$i" "$backup$i";
				fi
			else				# $i is not a param list nor a file/dir
				echo "'$i' not found" 1>&2;
			fi
		done
	fi
}

function back()
{
	local files;
	local peek;
	local backs;
	local to_restore=""
	local nb=1;

	[ -d /tmp/backup ] || return
	back=($(command ls -t1 /tmp/backup/))
	for b in $back; do
		files=$(find /tmp/backup/$b -type f)
		if [ ! $#files -eq 0 ]; then
			peek=""
			for f in $files; do peek+="$(basename $f), "; done
			peek=${peek:0:(-2)}; # remove the last ', '
			[ $#peek -gt $COLUMNS ] && peek="$(echo $peek | head -c $(( COLUMNS - 3 )) )..." # truncate and add '...' at the end if the peek is too large
			echo "\033[31m#$nb$DEF_C: \033[4;32m$(ts $b)$DEF_C: \033[34m$(echo $files | wc -w)$DEF_C file(s)"
			echo "$peek";
			echo;
			nb=$(( nb + 1 ));
		fi
	done
	echo -n "> "; tput setaf 1;
	read to_restore;
	tput sgr0;
	if [ ! -z $back[to_restore] ]; then
		files=$(find /tmp/backup/$back[to_restore] -type f)
		if [ ! -z $files ]; then
			for f in $files; do echo $f; done | command sed -r -e "s|/tmp/backup/$back[to_restore]||g" -e "s|/home/$USER|~|g"
			read -q "?Restore ? (Y/n): " && cp -R $(realpath /tmp/backup/$back[to_restore]/*) /
		else
			echo "No such back"
		fi
	else
		echo "No such back"
	fi
}


function ft()					# find text in .
{								# I (ignore binary) n (line number) H (print fn each line)
	command find . -type f -exec grep --color=auto -InH -e "$@" {} +
}

function installed()
{
	if [ $# -eq 1 ]; then
		[ "$(type $1)" = "$1 not found" ] || return 0 &&  return 1
	fi
}

function xtrace()				# debug cmd line with xtrace
{
	set -x;
	$@
}

function ftselect()
{
	typeset -A pos
	
	for p in $@; do
		echo "[ ]: $p"
	done
}


# LESS USEFUL USER FUNCTIONS #


function race()					# race between tokens given in parameters
{
	cat /dev/urandom | tr -dc "0-9A-Za-z" | command egrep --line-buffered -ao "$(echo $@ | sed "s/[^A-Za-z0-9]/\|/g")" | nl
}

function work()					# work simulation
{
	clear;
	text="$(cat $(find ~ -type f -name "*.cpp" 2>/dev/null | head -n25) | sed ':a;$!N;$!ba;s/\/\*[^​*]*\*\([^/*​][^*]*\*\|\*\)*\///g')"
	arr=($(echo $text))
	i=0
	cat /dev/zero | head -c $COLUMNS | tr '\0' '='
	while true
	do
		read -sk;
		echo -n ${text[$i]};
		i=$(( i + 1 ))
	done
	echo
}

function hack()					# hollywood hacker cat
{
	tput setaf 2; cat $@ | pv -qL 25
}

function window()				# prints weather info
{
	curl -s "http://www.wunderground.com/q/zmw:00000.37.07156" | grep "og:title" | cut -d\" -f4 | sed 's/&deg;/ degrees/';
}


# PS1 VARIABLES #

SEP_C="%F{242}"					# separator color
ID_C="%F{33}"					# id color
PWD_C="%F{201}"					# pwd color
GB_C="%F{208}"					# git branch color
NBF_C="%F{46}"					# files number color
NBD_C="%F{26}"					# dir number color
TIM_C="%U%B%F{220}"				# time color

GET_SHLVL="$([[ $SHLVL -gt 9 ]] && echo "+" || echo $SHLVL)" # get the shell level (0-9 or + if > 9)

GET_SSH="$([[ $(echo $SSH_TTY$SSH_CLIENT$SSH_CONNECTION) != '' ]] && echo ssh$SEP_C:)" # 'ssh:' before username if logged in ssh


# PS1_INFO="X" to activate INFO, PS1_INFO="" to desactivate
PS1_SSH="X"
PS1_USER="X"
PS1_MACHINE="X"
PS1_WD="X"
PS1_GIT_BRANCH="X"
PS1_DIR_INFOS="X"
PS1_RETURN_STATUS="X"
PS1_GIT_STATUS="X"
PS1_JOBS="X"
PS1_SHLVL="X"
PS1_USER_LEVEL="X"
function setps1()
{
	PS1=''																									# simple quotes for post evaluation
	[ ! -z $PS1_SSH ] 			&& 	PS1+='$ID_C$GET_SSH'													# 'ssh:' if in ssh
	[ ! -z $PS1_USER ] 			&&	PS1+='$ID_C%n'															# username
	[ ! -z $PS1_MACHINE ]			&& 	PS1+='${SEP_C}@$ID_C%m'												# @machine
	if [ ! -z $PS1_WD ] || [ ! -z $PS1_GIT_BRANCH ] || [ ! -z $PS1_DIR_INFOS ]; then 						# print separators if there is infos inside
		PS1+='${SEP_C}['
	fi
	[ ! -z $PS1_WD ] 				&& 	PS1+='$PWD_C%~${SEP_C}' 											# current short path
	if [ ! -z $GIT_BRANCH ] && [ ! -z $PS1_WD ]; then
		PS1+="${SEP_C}:";
	fi
	[ ! -z $PS1_GIT_BRANCH ] 		&& 	PS1+='${GB_C}$GIT_BRANCH' 											# get current branch
	if [ ! -z $PS1_WD ] || [ ! -z $PS1_GIT_BRANCH ]; then
		PS1+="${SEP_C}|";
	fi
	[ ! -z $PS1_DIR_INFOS ] 		&& 	PS1+='$NBF_C$NB_FILES${SEP_C}/$NBD_C$NB_DIRS${SEP_C}' 				# nb of files and dirs in .
	if [ ! -z $PS1_WD ] || [ ! -z $PS1_GIT_BRANCH ] || [ ! -z $PS1_DIR_INFOS ]; then 						# print separators if there is infos inside
		PS1+="]%f%k "
	fi
	[ ! -z $PS1_RETURN_STATUS ] 	&& 	PS1+='%(0?.%F{82}o.%F{196}x)' 										# return status of last command (green O or red X)
	[ ! -z $PS1_GIT_STATUS ] 		&& 	PS1+='$GET_GIT'														# git status (red + -> dirty, orange + -> changes added, green + -> changes commited, green = -> changed pushed)
	[ ! -z $PS1_JOBS ] 			&& 	PS1+='%(1j.%(10j.%F{208}+.%F{226}%j).%F{210}%j)' 						# number of running/sleeping bg jobs
	[ ! -z $PS1_SHLVL ] 			&& 	PS1+='%F{205}$GET_SHLVL'						 					# static shlvl
	[ ! -z $PS1_USER_LEVEL ] 		&& 	PS1+='%(0!.%F{196}#.%F{26}\$)'					 					# static user level
	PS1+='${SEP_C}>%f%k '
}
setps1

# RPS1="$TIM_C%T%u%f%b"		# right part of the PS1



bindkey "$(echotc kl)" backward-char # dunno why but everybody is doing it
bindkey "$(echotc kr)" forward-char	 # looks like termcaps stuff
bindkey "$(echotc ku)" up-line-or-history # arrows keys compatibility on dumb terms maybe ?
bindkey "$(echotc kd)" down-line-or-history

# SETTING STUFF #

EDITOR="emacs"					# variables set for git editor and edit-command-line
VISUAL="emacs"

HISTFILE=~/.zshrc_history
SAVEHIST=65536
HISTSIZE=65536

CLICOLOR=1

# ZSH FUNCTIONS LOAD #

autoload add-zsh-hook			# control the hooks (chpwd, precmd, ...)
autoload zed					# zsh editor

# autoload predict-on			# fish like suggestion (with bundled lags !)
# predict-on

autoload -z edit-command-line	# edit command line with $EDITOR
zle -N edit-command-line

autoload -U colors && colors	# cool colors

autoload -U compinit
compinit						# enable completion
zmodload zsh/complist			# load compeltion list


# SETTING UP ZSH COMPLETION STUFF #

zstyle ':completion:*:rm:*' ignore-line yes # remove suggestion if already in selection
zstyle ':completion:*:mv:*' ignore-line yes # same
zstyle ':completion:*:cp:*' ignore-line yes # same

zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path .zcache

zstyle ":completion:*" menu select # select menu completion

zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

zstyle ":completion:*" group-name "" # group completion

zstyle ":completion:*:warnings" format "Nope !" # custom error

zstyle ":completion:::::" completer _complete _approximate # approx completion after regular one
# zstyle ":completion:*:approximate:*" max-errors 2		   # complete 2 errors max
zstyle ":completion:*:approximate:*" max-errors "(( ($#PREFIX+$#SUFFIX)/3 ))" # allow one error each 3 characters

zle -C complete-file complete-word _generic
zstyle ':completion:complete-file::::' completer _files

zstyle ":completion:*:descriptions" format "%B%d%b"

# Homemade functions completion

_ff() { _alternative "args:type:(( 'h:search in hidden files' 'e:search for empty files' 'r:search for files with the reading right' 'w:search for files with the writing right' 'x:search for files with the execution right' 'b:search for block files' 'c:search for character files' 'd:search for directories' 'f:search for regular files' 'l:search for symlinks' 'p:search for fifo files' 'nh:exclude hidden files' 'ne:exclude empty files' 'nr:exclude files with the reading right' 'nw:exclude files with the writing right' 'nx:exclude files with the execution right' 'nb:exclude block files' 'nc:exclude character files' 'nd:exclude directories' 'nf:exclude regular files' 'nl:exclude symlinks symlinks' 'np:exclude fifo files' 'ns:exclude socket files'))" "*:root:_files" }
compdef _ff ff


# ZSH KEY BINDINGS #


# SHELL COMMANDS BINDS #

# C-v or 'cat -v' to get the keycode
bindkey -s "^[j" "^Ujoin_others_shells\n" # join_others_shells user function
bindkey -s "^[r" "^Uressource\n"		  # source ~/.zshrc
bindkey -s "^[e" "^Uerror\n"			  # run error user function
bindkey -s "^[s" "^Asudo ^E"	# insert sudo
bindkey -s "\el" "^Uls\n"		# run ls
bindkey -s "^X^M" "^Umake\n"	# make
bindkey -s "^[g" "^A^Kgit commit -m\"\"^[OD"
bindkey -s "^[c" "^A^Kgit checkout 		"


# ZLE FUNCTIONS #

bindkey -e 						# emacs style key binding


function get_terminfo_name()	# get the terminfo name according to the keycode
{
	for k in "${(@k)terminfo}"; do
		[ "$terminfo[$k]" = "$@" ] && echo $k
	done
}

function up-line-or-search-prefix () # smart up search (search in history anything matching before the cursor)
{
	local CURSOR_before_search=$CURSOR
	zle up-line-or-search "$LBUFFER"
	CURSOR=$CURSOR_before_search
}
zle -N up-line-or-search-prefix

function down-line-or-search-prefix () # same with down
{
	local CURSOR_before_search=$CURSOR
	zle down-line-or-search "$LBUFFER"
	CURSOR=$CURSOR_before_search
}
zle -N down-line-or-search-prefix


function goto-right-matching-delimiter () # explicit name
{
       L_DELIMS="[({";
       R_DELIMS="])}";
       local i=0;
       local start;
       local end;
       local sav=$CURSOR;
       local old;
       local balance=0;
	   CURSOR=$(( CURSOR + 1 ));
       start=$BUFFER[$CURSOR];
       for i in $(seq $#L_DELIMS); do
           [ "$L_DELIMS[$i]" = "$start" ] && end="$R_DELIMS[$i]";
       done
       if [ $#end -eq 1 ]; then
               balance=1;
               CURSOR=$(( CURSOR + 1 ));
               while [ $balance -ne 0 ] && [ "$CURSOR" -le $#BUFFER ]; do
                       if [ "$BUFFER[$CURSOR]" = "$start" ]; then balance=$(( balance + 1 ));
					   elif [ "$BUFFER[$CURSOR]" = "$end" ]; then balance=$(( balance - 1 ));
					   fi
                       old=$CURSOR;
                       [ $balance -ne 0 ] && CURSOR=$(( CURSOR + 1 ));
               done
               [ $CURSOR = $#BUFFER ] && CURSOR=$sav;
       fi
}
zle -N goto-right-matching-delimiter

function goto-left-matching-delimiter () # yea
{
       L_DELIMS="[({";
       R_DELIMS="])}";
       local i=0;
       local start;
       local end;
       local sav=$CURSOR;
       local old;
       local balance=0;
	   CURSOR=$(( CURSOR ));
       start=$BUFFER[$CURSOR];
       for i in $(seq $#R_DELIMS); do
           [ "$R_DELIMS[$i]" = "$start" ] && end="$L_DELIMS[$i]";
       done
       if [ $#end -eq 1 ]; then
               balance="-1";
               CURSOR=$(( CURSOR - 1 ));
               while [ $balance -ne 0 ] && [ "$CURSOR" -ge 0 ]; do
                       if [ "$BUFFER[$CURSOR]" = "$start" ]; then balance=$(( balance - 1 ));
					   elif [ "$BUFFER[$CURSOR]" = "$end" ]; then balance=$(( balance + 1 ));
					   fi
                       old=$CURSOR;
                       [ $balance -ne 0 ] && CURSOR=$(( CURSOR - 1 ));
               done
               [ $CURSOR = $#BUFFER ] && CURSOR=$sav;
       fi
}
zle -N goto-left-matching-delimiter


function save-line()			# save the current line at its state in ~/.saved_commands
{
	echo $BUFFER >> ~/.saved_commands
}
zle -N save-line

# ZSH FUNCTIONS BINDS #

typeset -A key				# associative array with more explicit names

key[up]=$terminfo[kcuu1]
key[down]=$terminfo[kcud1]
key[left]=$terminfo[kcub1]
key[right]=$terminfo[kcuf1]

key[C-up]="^[[1;5A"
key[C-down]="^[[1;5B"
key[C-left]="^[[1;5D"
key[C-right]="^[[1;5C"

key[M-up]="^[[1;3A"
key[M-down]="^[[1;3B"
key[M-left]="^[[1;3D"
key[M-right]="^[[1;3C"

key[S-up]=$terminfo[kri]
key[S-down]=$terminfo[kind]
key[S-left]=$terminfo[kLFT]
key[S-right]=$terminfo[kRIT]

key[tab]=$terminfo[kRIT]
key[S-tab]=$terminfo[cbt]

key[C-space]="^@"


bindkey $key[M-right] goto-right-matching-delimiter
bindkey $key[M-left] goto-left-matching-delimiter

bindkey "[/" complete-file		# complete files only
bindkey "^X^E" edit-command-line # edit line with $EDITOR

function ctrlz() { suspend }; zle -N ctrlz
bindkey "^X^Z" ctrlz			# ctrl z zsh

bindkey $key[C-left] backward-word
bindkey $key[C-right] forward-word

bindkey "^[k" kill-word
bindkey "^w" kill-region		 # emacs-like kill

bindkey $key[S-tab] reverse-menu-complete # shift tab for backward completion

bindkey $key[C-space] save-line

bindkey $key[C-up] up-line-or-search-prefix # ctrl + arrow = smart completion
bindkey $key[C-down] down-line-or-search-prefix

bindkey $key[up] up-line-or-history # up/down scroll through history
bindkey $key[down] down-line-or-history

# USEFUL ALIASES #

alias l="ls -lFh"				# list + classify + human readable
alias la="ls -lAFh"				# l with hidden files
alias lt="ls -ltFh"				# l with modification date sort
alias ll="ls -lFh"				# simple list
alias .="ls"

alias gb="git branch"
alias gc="git checkout"

alias mkdir="mkdir -pv"			# create all the needed parent directories + inform user about creations

alias grep="grep --color=always"
alias egrep="egrep --color=always"
installed tree && alias tree="tree -C"		   # -C colorzzz
installed colordiff && alias diff="colordiff" # diff with nicer colors
alias less="less -R"			# -R Raw control chars

alias ressource="source ~/.zshrc"
alias res="source ~/.zshrc"

alias emacs="emacs -nw"
alias xemacs="command emacs"
alias emax="command emacs"
alias x="command emacs"
alias e="emacs"
alias qmacs="emacs -q"
alias q="emacs -q"

alias ss="du -a . | sort -nr | head -n10" # get the 10 biggest files
alias df="df -Tha --total"		# disk usage infos
alias fps="ps | head -n1  && ps aux | grep -v grep | grep -i -e VSZ -e " # fps <processname> to get ps infos only for the matching processes
alias tt="tail --retry -fn0"	# real time tail a log
alias dzsh="zsh --norcs --xtrace" # debugzsh

alias roadtrip='while true; do cd $(ls -pa1 | grep "/$" | grep -v "^\./$" | sort --random-sort | head -n1); echo -ne "\033[2K\r>$(pwd)"; done' # visit your computer

check_git_repo
update_pwd_datas
update_pwd_save
set_git_char
rehash							# hash commands in path

# join_others_shells				# ask for joining others shells

[ "$STARTUP_CMD" != "" ] && eval $STARTUP_CMD && unset STARTUP_CMD; # execute user defined commands after init

