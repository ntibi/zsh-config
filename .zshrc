# # # # # # # #
#
# Loading .myzshrc and .prezshrc
#
# USEFUL VARS
#	defines useful variables
#
# (UN)SETTING ZSH (COOL) OPTIONS
#	(un)setting zsh opts
#
# PS1 FUNCTIONS
#	prompt related functions
#
# CALLBACK FUNCTIONS
#	defining callbacks functions
#
# USEFUL USER FUNCTIONS
#	defining useful shell functions
#
# LESS USEFUL USER FUNCTIONS
#	defining less useful shell functions
#
# ZSH FUNCTIONS LOAD
#	loading of useful builtin zsh functions
#
# SETTING UP ZSH COMPLETION STUFF
#
# HOMEMADE FUNCTIONS COMPLETION
#	setting zsh completions for user functions
#
# SHELL COMMANDS BINDS
#	keybinds to shell commands
#
# ZLE FUNCTIONS
#	shell functions using zsh line editor
#
# ZSH FUNCTIONS BINDS
#	binds to user and builtin zle functions
#
# USEFUL ALIASES
#	yes
#
# MANDATORY FUNCTIONS CALLS
#	functions calls setting datas for the first time
#
# Loading .postzshrc
#
# # # # # # # #
#
# Todo:
#
# Split the main file
# Optimize all the callbacks
#


if [ ! $(echo "$0" | grep -s "zsh") ]; then
	echo "error: Not in zsh" 1>&2
	return;
fi

[ -e ~/.myzshrc ] && source ~/.myzshrc # load user file if any
[ -e ~/.preszhrc ] && source ~/.preszhrc


### USEFUL VARS ###

_TERM="$TERM"
TERM="xterm-256color" && [[ $(tput colors) == 256 ]] || echo "can't use xterm-256color :/" # check if xterm-256 color is available, or if we are in a dumb shell

typeset -Ug PATH				# do not accept doubles
typeset -Ag abbrev				# global associative array to define abbrevations

WORDCHARS="*?_-.[]~=/&;!#$%^(){}<>|"

PERIOD=5			  # period used to hook periodic function (in sec)

PWD_FILE=~/.pwd					# last pwd sav file


OS="$(uname | tr "A-Z" "a-z")"	# get the os name

UPDATE_TERM_TITLE="" # set to update the term title according to the path and the currently executed line
UPDATE_CLOCK=""		 # set to update the top-right clock every second

EDITOR="emacs"
VISUAL="emacs"
PAGER="less"

HISTFILE=~/.zshrc_history
SAVEHIST=65536
HISTSIZE=65536

CLICOLOR=1

case "$OS" in
	(*darwin*)					# Mac os
		LS_COLORS='exfxcxdxbxexexabagacad';;
	(*cygwin*)					# cygwin
		LS_COLORS='fi=1;32:di=1;34:ln=35:so=32:pi=0;33:ex=32:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=1;34:ow=1;34:';;
	(*linux*|*)					# Linux
		LS_COLORS='fi=1;34:di=1;34:ln=35:so=32:pi=0;33:ex=32:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=1;34:ow=1;34:';;
esac

DEF_C="$(tput sgr0)"

C_BLACK="$(tput setaf 0)"
C_RED="$(tput setaf 1)"
C_GREEN="$(tput setaf 2)"
C_YELLOW="$(tput setaf 3)"
C_BLUE="$(tput setaf 4)"
C_PURPLE="$(tput setaf 5)"
C_CYAN="$(tput setaf 6)"
C_WHITE="$(tput setaf 7)"
C_GREY="$(tput setaf 8)"


### (UN)SETTING ZSH (COOL) OPTIONS ###

setopt prompt_subst				# compute PS1 at each prompt print
setopt inc_append_history
setopt share_history
setopt hist_ignore_dups			# ignore dups in history
setopt hist_expire_dups_first	# remove all dubs in history when full
setopt auto_remove_slash		# remove slash when pressing space in auto completion
setopt null_glob				# remove pointless globs
setopt auto_cd					# './dir' = 'cd dir'
setopt auto_push_d					# './dir' = 'cd dir'
setopt c_bases					# c-like bases conversions
setopt c_precedences			# c-like operators
setopt emacs					# enable emacs like keybindigs
setopt flow_control				# enable C-q and C-s to control the flooow
setopt complete_in_word			# complete from anywhere
setopt clobber					# i aint no pussy
setopt extended_glob			# used in matching im some functions
setopt multi_os					# no more tee !
setopt cd_able_vars				# hash -d mdr=~/my/long/path/; cd mdr
setopt hist_fcntl_lock

[ ! -z "$EMACS" ] && unsetopt zle # allow zsh to work under emacs
unsetopt beep					# no disturbing sounds


### PS1 FUNCTIONS ###

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
	[[ $PWD != "$HOME" ]] && echo $PWD > $PWD_FILE
}

function set_git_branch()
{
	if [ $REPO -eq 1 ]; then		# if in git repo, get git infos
		GIT_BRANCH="$(git branch | grep \* | cut -d\  -f2-)";
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
		sched | command grep -q clock || sched +10 clock # if no clock update in sched, set one in 10s
	else
		trap - WINCH
	fi
}


SEP_C="%F{242}"					# separator color
ID_C="%F{33}"					# id color
PWD_C="%F{201}"					# pwd color
GB_C="%F{208}"					# git branch color
NBF_C="%F{46}"					# files number color
NBD_C="%F{26}"					# dir number color
TIM_C="%U%B%F{220}"				# time color

GET_SHLVL="$([[ $SHLVL -gt 9 ]] && echo "+" || echo $SHLVL)" # get the shell level (0-9 or + if > 9)

GET_SSH="$([[ $(echo $SSH_TTY$SSH_CLIENT$SSH_CONNECTION) != '' ]] && echo ssh$SEP_C:)" # 'ssh:' before username if logged in ssh



_PS1=()
_PS1_DOC=()

_ssh=1				;_PS1_DOC+="be prefixed if connected in ssh"
_user=2				;_PS1_DOC+="print the username"
_machine=3			;_PS1_DOC+="print the machine name"
_wd=4				;_PS1_DOC+="print the current working directory"
_git_branch=5		;_PS1_DOC+="print the current git branch if any"
_dir_infos=6		;_PS1_DOC+="print the nb of files and dirs in '.'"
_return_status=7	;_PS1_DOC+="print the return status of the last command (true/false)"
_git_status=8		;_PS1_DOC+="print the status of git with a colored char (clean/dirty/...)"
_jobs=9				;_PS1_DOC+="print the number of background jobs"
_shlvl=10			;_PS1_DOC+="print the current sh level (shell depth)"
_user_level=11		;_PS1_DOC+="print the current user level (root or not)"
_end_char=12		;_PS1_DOC+="print a nice '>' at the end"

function setprompt()			# set a special predefined prompt or update the prompt according to the prompt vars
{
	case $1 in
		("superlite") _PS1=("" "" "" "" "" "" "" "" "" "" "X" "");;
		("lite") _PS1=("X" "X" "X" "" "" "" "" "" "" "" "X" "X");;
		("nogit") _PS1=("X" "X" "X" "X" "" "X" "X" "" "X" "X" "X" "X");;
		("classic") _PS1=("X" "X" "X" "X" "" "" "" "" "" "" "X" "X");;
		("complete") _PS1=("X" "X" "X" "X" "X" "X" "X" "X" "X" "X" "X" "X");;
	esac
	PS1=''																								# simple quotes for post evaluation
	[ ! -z $_PS1[$_ssh] ] 			&& 	PS1+='$ID_C$GET_SSH'												# 'ssh:' if in ssh
	[ ! -z $_PS1[$_user] ] 			&&	PS1+='$ID_C%n'														# username
	if [ ! -z $_PS1[$_user] ] && [ ! -z $_PS1[$_machine] ]; then
		PS1+='${SEP_C}@'
	fi
	[ ! -z $_PS1[$_machine] ]		&& 	PS1+='$ID_C%m'												# @machine
	if [ ! -z $_PS1[$_wd] ] || ( [ ! -z $GIT_BRANCH ] && [ ! -z $_PS1[$_git_branch] ]) || [ ! -z $_PS1[$_dir_infos] ]; then 					# print separators if there is infos inside
		PS1+='${SEP_C}['
	fi
	[ ! -z $_PS1[$_wd] ] 			&& 	PS1+='$PWD_C%~' 													# current short path
	if ( [ ! -z $_PS1[$_git_branch] ] && [ ! -z $GIT_BRANCH ] ) && [ ! -z $_PS1[$_wd] ]; then
		PS1+="${SEP_C}:";
	fi
	[ ! -z $_PS1[$_git_branch] ] 	&& 	PS1+='${GB_C}$GIT_BRANCH' 											# get current branch
	if ([ ! -z $_PS1[$_wd] ] || ( [ ! -z $GIT_BRANCH ] && [ ! -z $_PS1[$_git_branch] ])) && [ ! -z $_PS1[$_dir_infos] ]; then
		PS1+="${SEP_C}|";
	fi
	[ ! -z $_PS1[$_dir_infos] ] 	&& 	PS1+='$NBF_C$NB_FILES${SEP_C}/$NBD_C$NB_DIRS' 				# nb of files and dirs in .
	if [ ! -z $_PS1[$_wd] ] || ( [ ! -z $GIT_BRANCH ] && [ ! -z $_PS1[$_git_branch] ]) || [ ! -z $_PS1[$_dir_infos] ]; then 					# print separators if there is infos inside
		PS1+="${SEP_C}]%f%k"
	fi
	if ([ ! -z $_PS1[$_wd] ] || [ ! -z $_PS1[$_dir_infos] ]) || [ ! -z $_PS1[$_return_status] ] || [ ! -z $_PS1[$_git_status] ] || [ ! -z $_PS1[$_jobs] ] || [ ! -z $_PS1[$_shlvl] ] || [ ! -z $_PS1[$_user_level] ]; then
		PS1+="%f%k "
	fi
	[ ! -z $_PS1[$_return_status] ] && 	PS1+='%(0?.%F{82}o.%F{196}x)' 										# return status of last command (green O or red X)
-	[ ! -z $_PS1[$_git_status] ] 	&& 	PS1+='$GET_GIT'														# git status (red + -> dirty, orange + -> changes added, green + -> changes commited, green = -> changed pushed)
	[ ! -z $_PS1[$_jobs] ] 			&& 	PS1+='%(1j.%(10j.%F{208}+.%F{226}%j).%F{210}%j)' 					# number of running/sleeping bg jobs
	[ ! -z $_PS1[$_shlvl] ] 		&& 	PS1+='%F{205}$GET_SHLVL'						 					# static shlvl
	[ ! -z $_PS1[$_user_level] ] 	&& 	PS1+='%(0!.%F{196}#.%F{26}\$)'					 					# static user level
	[ ! -z $_PS1[$_end_char] ] 		&& 	PS1+='${SEP_C}>'
	[ ! -z "$PS1" ] 				&& 	PS1+="%f%k "
}

function pimpprompt()			# pimp the PS1 variables one by one
{
	local response;
	_PS1=("" "" "" "" "" "" "" "" "" "" "" "");
	echo "Do you want your prompt to:"
	for i in $(seq "$#_PS1"); do
		_PS1[$i]="X";
		setprompt;
		print "$_PS1_DOC[$i] like this ?\n$(print -P "$PS1")"
		read -q "response?(Y/n): ";
		if [ $response != "y" ]; then
		   	_PS1[$i]="";
			setprompt;
		fi
		echo;
		echo;
	done
}


PS4="%N:%i> ";
function setps4()				# toggle PS4 (xtrace prompt) between verbose and default
{
	case "$PS4" in
		("%b%N:%I %_
%B")
			PS4="%N:%i> ";
			;;
		(*)
			PS4="%b%N:%I %_
%B";
	esac 
}


### CALLBACK FUNCTIONS ###

function chpwd()				# chpwd hook
{
	check_git_repo
	set_git_branch
	update_pwd_datas
	update_pwd_save
	setprompt					# update the prompt
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
	[ -z $UPDATE_TERM_TITLE ] || printf "\e]2;%s : %s\a" "${PWD/~/~}" "$1" # set 'pwd + cmd' set term title
}

function precmd()				# pre promt hook
{
	[ -z $UPDATE_CLOCK ] || clock
	[ -z $UPDATE_TERM_TITLE ] || printf "\e]2;%s\a" "${PWD/~/~}" # set pwd as term title
	
	set_git_char
}


### USEFUL USER FUNCTIONS ###


function escape()				# escape a string
{
	printf "%q\n" "$@";
}

function showcolors()			# display the 256 colors by shades - useful to get pimpy colors
{
	tput setaf 0;
	for c in {0..15}; do tput setab $c ; printf " % 2d " "$c"; done # 16 colors
	tput sgr0; echo;
	tput setaf 0;
	for s in {16..51}; do		# all the color tints
		for ((i = $s; i < 232; i+=36)); do
			tput setab $i ; printf "% 4d " "$i";
		done
		tput sgr0; echo; tput setaf 0;
	done
	for c in {232..255}; do tput setaf $((255 - c + 232)); tput setab $c ; printf "% 3d" "$c"; done # grey tints
	tput sgr0; echo;
}

function error()				# give error nb to get the corresponding error string
{
	python -c "import os; print os.strerror($?)";
}

function join_others_shells()	# ask for joining path specified in $PWD_FILE if not already in it
{
	if [[ -e $PWD_FILE ]] && [[ $(pwd) != $(cat $PWD_FILE) ]]; then
		read -q "?Go to $C_YELLOW$(cat $PWD_FILE)$C_WHITE ? (Y/n):" && cd "$(cat $PWD_FILE)"
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
				(h) [ -z $neg ] && hidden="" || hidden=" -not -regex .*/\..*";;
				(e) additional+="$neg -empty";;
				(r) additional+="$neg -readable";;
				(w) additional+="$neg -writable";;
				(x) additional+="$neg -executable";;
				(*) type+=$([ -z "$type" ] && echo "$neg -type $p" || echo " -or $neg -type $p");;
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

function colorize() 			# cmd | colorize <exp1> (f/b)?<color1> <exp2> (f/b)?<color2> ... to colorize expr with color
{								# ie: cat log.log | colorize WARNING byellow ERROR bred DEBUG green INFO yellow "[0-9]+" 125 "\[[^\]]+\]" 207
	local -i i
	local last
	local params
	local col
	local background;
	i=0
	params=()
	col=""
	if [ $# -eq 0 ]; then
		echo "Usage: colorize <exp1> <color1> <exp2> <color2> ..." 1>&2
		return ;
	fi
	for c in "$@"; do
		if [ "$((i % 2))" -eq 1 ]; then
			case "$c[1]" in
				(b*)
					background="1";
					c="${c[2,$#c]}";;
				(f*)
					background="";
					c="${c[2,$#c]}";;
			esac
			case $c in
				("black") 	col=0;;
				("red") 	col=1;;
				("green") 	col=2;;
				("yellow") 	col=3;;
				("blue") 	col=4;;
				("purple") 	col=5;;
				("cyan") 	col=6;;
				("white") 	col=7;;
				(*) 		col=$c;;
			esac
			if [ $#background -ne 0 ]; then
				col="$(tput setab $col)";
			else
				col="$(tput setaf $col)";
			fi
			params+="-e";
			params+="s/(${last//\//\\/})/$col\1$DEF_C/g"; # replace all / by \/ to don't fuck the regex
		else
			last=$c
		fi
		i+=1;
	done
	if [ "$c" = "$last" ]; then
		echo "Usage: cmd | colorize <exp1> <color1> <exp2> <color2> ..."
		return
	fi
	# sed -r $params
	sed --unbuffered -r $params
}

function ts()					# timestamps operations (`ts` to get current, `ts <timestamp>` to know how long ago, `ts <timestamp1> <timestamp2>` timestamp diff)
{
	local -i delta;
	local -i ts1=$(echo $1 | grep -Eo "[0-9]+" | cut -d\  -f1);
	local -i ts2=$(echo $2 | grep -Eo "[0-9]+" | cut -d\  -f1);
	local sign;

	if [ $# = 0 ]; then
		date +%s;
	elif [ $# = 1 ]; then
		delta=$(( $(date +%s) - $ts1 ));
		if [ $delta -lt 0 ]; then
			delta=$(( -delta ));
			sign="in the future";
		else
			sign="ago";
		fi
		if [ $delta -gt 30758400 ]; then echo -n "$(( delta / 30758400 ))y "; delta=$(( delta % 30758400 )); fi
		if [ $delta -gt 86400 ]; then echo -n "$(( delta / 86400 ))d "; delta=$(( delta % 86400 )); fi
		if [ $delta -gt 3600 ]; then echo -n "$(( delta / 3600 ))h "; delta=$(( delta % 3600 )); fi
		if [ $delta -gt 60 ]; then echo -n "$(( delta / 60 ))m "; delta=$(( delta % 60 )); fi
		echo "${delta}s $sign";
	elif [ $# = 2 ]; then
		delta=$(( $ts2 - $ts1 ));
		if [ $delta -lt 0 ]; then
			delta=$(( -delta ));
		fi
		if [ $delta -gt 30758400 ]; then echo -n "$(( delta / 30758400 ))y "; delta=$(( delta % 30758400 )); fi
		if [ $delta -gt 86400 ]; then echo -n "$(( delta / 86400 ))d "; delta=$(( delta % 86400 )); fi
		if [ $delta -gt 3600 ]; then echo -n "$(( delta / 3600 ))h "; delta=$(( delta % 3600 )); fi
		if [ $delta -gt 60 ]; then echo -n "$(( delta / 60 ))m "; delta=$(( delta % 60 )); fi
		echo "${delta}s";
	fi
}

function rrm()					# real rm
{
	if [ "$1" != "$HOME" -a "$1" != "/" ]; then
		command rm $@;
	fi
}

RM_BACKUP_DIR="$HOME/.backup"
function rm()					# safe rm with timestamped backup
{
	if [ $# -gt 0 ]; then
		local backup;
		local idir;
		local rm_params;
		local i;
		idir="";
		rm_params="";
		backup="$RM_BACKUP_DIR/$(date +%s)";
		for i in "$@"; do
			if [ ${i:0:1} = "-" ]; then # if $i is an args list, save them
				rm_params+="$i";
			elif [ -f "$i" ] || [ -d "$i" ] || [ -L "$i" ] || [ -p "$i" ]; then # $i exist ?
				[ ! ${i:0:1} = "/" ] && i="$PWD/$i"; # if path is not absolute, make it absolute
				i=${i:A};		# simplify the path
				idir="$(dirname $i)";
				command mkdir -p "$backup/$idir";
				mv "$i" "$backup$i";
			else				# $i is not a param list nor a file/dir
				echo "'$i' not found" 1>&2;
			fi
		done
	fi
}

function save()					# backup the files
{
	if [ $# -gt 0 ]; then
		local backup;
		local idir;
		local rm_params;
		local i;
		idir="";
		rm_params="";
		backup="$RM_BACKUP_DIR/$(date +%s)";
		command mkdir -p "$backup";
		for i in "$@"; do
			if [ ${i:0:1} = "-" ]; then # if $i is an args list, save them
				rm_params+="$i";
			elif [ -f "$i" ] || [ -d "$i" ] || [ -L "$i" ] || [ -p "$i" ]; then # $i exist ?
				[ ! ${i:0:1} = "/" ] && i="$PWD/$i"; # if path is not absolute, make it absolute
				i=${i:A};						# simplify the path
				idir="$(dirname $i)";
				command mkdir -p "$backup/$idir";
				if [ -d "$i" ]; then
					cp -R "$i" "$backup$i";
				else
					cp "$i" "$backup$i";
				fi
			else				# $i is not a param list nor a file/dir
				echo "'$i' not found" 1>&2;
			fi
		done
	fi
}

CLEAR_LINE="$(tput sgr0; tput el1; tput cub 2)"
function back()					# list all backuped files
{
	local files;
	local peek;
	local backs;
	local to_restore="";
	local peeks_nbr=$(( (LINES) / 3 ));
	local b;
	local -i i;
	local key;

	[ -d $RM_BACKUP_DIR ] || return
	back=( $(command ls -t1 $RM_BACKUP_DIR/) );
	i=1;
	while [ $i -le $#back ] && [ -z "$to_restore" ]; do
		b=$back[i];
		files=( $(find $RM_BACKUP_DIR/$b -type f) )
		if [ ! $#files -eq 0 ]; then
			peek=""
			for f in $files; do peek+="$(basename $f), "; if [ $#peek -ge $COLUMNS ]; then break; fi; done
			peek=${peek:0:(-2)}; # remove the last ', '
			[ $#peek -gt $COLUMNS ] && peek="$(echo $peek | head -c $(( COLUMNS - 3 )) )..." # truncate and add '...' at the end if the peek is too large
			echo "$C_RED#$i$DEF_C: $C_GREEN$(ts $b)$DEF_C: $C_BLUE$(echo $files | wc -w)$DEF_C file(s) ($C_CYAN$(du -sh $RM_BACKUP_DIR/$b | cut -f1)$DEF_C)"
			echo "$peek";
			echo;
		fi
		if [ $(( i % $peeks_nbr == 0 || i == $#back )) -eq 1 ]; then
			key="";
			echo -n "> $C_GREEN";
			read -sk1 key;
			case "$(echo -n $key | cat -e)" in
				("^[")
					echo -n "$CLEAR_LINE";
					read -sk2 key; # handle 3 characters arrow key press as next
					i=$(( i + 1 ));;
				("$"|" ")			# hangle enter and space as next
					echo -n "$CLEAR_LINE";
					i=$(( i + 1 ));;
				(*)				# handle everything else as a first character of backup number
					echo -n $key; # print the silently read key on the prompt
					read to_restore;
					to_restore="$key$to_restore";;
			esac
			echo -n "$DEF_C"
		else
			i=$(( i + 1 ));
		fi
	done
	if [ ! -z "$back[to_restore]" ]; then
		files=( $(find $RM_BACKUP_DIR/$back[to_restore] -type f) )
		if [ ! -z "$files" ]; then
			for f in $files; do echo $f; done | command sed -r -e "s|$RM_BACKUP_DIR/$back[to_restore]||g" -e "s|/home/$USER|~|g"
			read -q "?Restore ? (Y/n): " && cp --backup=t -R $RM_BACKUP_DIR/$back[to_restore]/*(:A) / # create file.~1~ if file already exists
			echo;
		else
			echo "No such back"
		fi
	else
		echo "No such back"
	fi
}


function ft()					# find arg1 in all files from arg2 or .
{
	command find ${2:=.} -type f -exec grep --color=always -InH -e "$1" {} +; # I (ignore binary) n (line number) H (print fn each line)
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

function title()				# set the title of the term, or toggle the title updating if no args
{
	if [ "$#" -ne "0" ]; then
		print -Pn "\e]2;$@\a"
		UPDATE_TERM_TITLE=""
	else
		if [ -z "$UPDATE_TERM_TITLE" ]; then
			UPDATE_TERM_TITLE="X"
		else
			print -Pn "\e]2;\a"
			UPDATE_TERM_TITLE=""
		fi
	fi
}

function loadconf()				# load a visual config
{
	case "$1" in
		(lite)					# faster, lighter
			UPDATE_TERM_TITLE="";
			UPDATE_CLOCK="";
			setprompt lite;
			;;
		(static)				# nicer, cooler, but without clock update nor title update
			UPDATE_TERM_TITLE="";
			UPDATE_CLOCK="";
			setprompt complete;
			;;
		(complete|*)			# nicer, cooler
			UPDATE_TERM_TITLE="X";
			UPDATE_CLOCK="X";
			setprompt complete;
			;;
	esac
}

function uc()					# remove all? color escape chars
{
	if [ $# -eq 0 ]; then
		sed -r "s/\[([0-9]{1,2}(;[0-9]{1,2})?(;[0-9]{1,3})?)?[mGK]//g"
	else
		$@ | sed -r "s/\[([0-9]{1,2}(;[0-9]{1,2})?(;[0-9]{1,3})?)?[mGK]//g"
	fi
}

function hscroll()				# test
{
	local string;
	local -i i=0;
	local key;
	local crel="$(tput cr;tput el)";
	local -i cols="$(tput cols)"
	[ $# -eq 0 ] && return ;
	string="$(cat /dev/zero | tr "\0" " " | head -c $cols)$@";
	trap "tput cnorm; return;" INT
	tput civis;
	while [ $i -le $#string ]; do
		echo -n ${string:$i:$cols};
		read -sk 3 key;
		echo -en "$crel";
		case $(echo "$key" | cat -v) in
			("^[[C")
				i=$(( i - 1 ));;
			("^[[D")
				i=$(( i + 1 ));;
		esac
	done
	tput cnorm;
}

function iter()					# iter elt1 elt2 ... - command -opt1 -opt2 ...
{
	local i;
	local command;
	local sep;
	local elts;

	elts=();
	command=();
	for i in $@; do
		if [ ! -z "$sep" ]; then
			command+="$i";
		elif [ "$i" = "-" ]; then
			sep="-";
		else
			elts+="$i";
		fi
	done
	for i in $elts; do
		eval ${=command//{}/$i};		# perform word split on the array
	done
}

function c()					# simple calculator
{
	echo $(($@));
}

function d2h()					# decimal to hexa
{ echo $(( [#16]$1 )); }

function h2d()					# hexa to decimal
{ echo $(( 16#$1 )); }

function d2b()					# decimal to binary
{ echo $(( [#2]$1 )); }

function h2b()					# binary to decimal
{ echo $(( 2#$1 )); }

function h2b()					# hexa to binary
{ echo $(( [#2]16#$1 )); }

function b2h()					# binary to hexa
{ echo $(( [#16]2#$1 )); }


function add-abbrev()			# add a dynamic abbreviation
{
	if [ $# -eq 2 ]; then
		abbrev+=("$1" "$2");
		if [[ "$2" =~ "^[A-Za-z0-9 _\"'\.\-]+$" ]]; then
			alias -- "$1"="$2";
		fi
	else
		echo "Usage: add-abbrev 'word' 'abbrev'" >&2;
	fi
}

function show-abbrevs()			# list all the defined abbreviations
{
	local -i pad;

	for k in "${(@k)abbrev}"; do
		[ $#k -gt $pad ] && pad=$#k;
	done
	(( pad+=2 ));
	for k in "${(@k)abbrev}"; do
		printf "$C_BLUE%-${pad}s$C_GREY->$DEF_C  \"$C_GREEN%s$DEF_C\"\n" "$k" "$abbrev[$k]";
	done
}

function show-aliases()			# list all aliases
{
	local -i pad;

	for k in "${(@k)aliases}"; do
		[ $#k -gt $pad ] && pad=$#k;
	done
	(( pad+=2 ));
	for k in "${(@k)aliases}"; do
		printf "$C_BLUE%-${pad}s$C_GREY->$DEF_C  \"$C_GREEN%s$DEF_C\"\n" "$k" "$aliases[$k]";
	done
}

function mkback()				# create a backup file of . or the specified dir/file
{
	local toback;
	local backfile;

	if [ -e "$1" ] && [ "$1" != "." ] ; then
		toback="$1";
		backfile="$(basename ${1:A})";
	else
		toback=".";
		backfile="$(basename $(pwd))";
	fi
	backfile+="-$(date +%s).back.tar.gz";
	printf "Backing up %s in %s\n" "$toback" "$backfile";
	tar -cf - "$toback"  | pv -F " %b %r - %e  %t" -s "$(du -sb | cut -d"	" -f1 )" | gzip --best > "$backfile";
}

BLOG_FILE="$HOME/.blog"
function blog()					# blog or blog "text" to log it in a file; blog -v to view the logs
{
	if [ "$1" = "-v" ]; then
		[ -f "$BLOG_FILE" ] && less -S "$BLOG_FILE";
	else
		trap "" INT
		date "+%D %T" | tee -a "$BLOG_FILE"
		if [ $# -eq 0 ]; then
			cat >> "$BLOG_FILE"
		else
			echo "$@" >> "$BLOG_FILE"
		fi
		echo -e "\n" >> "$BLOG_FILE"
		trap - INT
	fi
}

function kbd()
{
	case $1 in
		(caps-ctrl)
			setxkbmap -option ctrl:nocaps;; # caps lock is a ctrl key
		(caps-esc)
			setxkbmap -option caps:escape;; # caps lock is an alt key
		(caps-super)
			setxkbmap -option caps:super;; # caps lock is a super key
		(us)
			setxkbmap us;;
		(fr)
			setxkbmap fr;;
	esac
}

function popup()
{
	trap "tput cnorm; tput rc; return;" INT;
	local -i x y;
	local msg;
	x=-1;
	y=-1;
	while getopts "x:y:" opt 2>/dev/null ; do
		case $opt in
			(x) x=$OPTARG;;
			(y) y=$OPTARG;;
			(*) echo "Invalid option" >&2;
				return;;
		esac
	done
	shift $(( $OPTIND - 1 ));
	msg="$*";
	tput civis;
	tput sc;
	tput cup $y $x;
	print "$msg";
	read -sk1;
	tput rc;
	tput cnorm;
}


### LESS USEFUL USER FUNCTIONS ###

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

function useless_fractal()
{
	local lines columns a b p q i pnew;
	clear;
	((columns=COLUMNS-1, lines=LINES-1, colour=0));
	bi=$((3.0/lines));
	ai=$((3.0/columns));
	for ((b=-1.5; b<=1.5; b+=$bi)); do
		for ((a=-2.0; a<=1; a+=$ai)); do
			for ((p=0.0, q=0.0, i=0; p*p+q*q < 4 && i < 32; i++)); do
				((pnew=p*p-q*q+a, q=2*p*q+b, p=pnew));
			done
			echo -n "\\e[4$(( (i/4)%8 ))m ";
			# echo -n "\\e[48;5;$(( ((i/4)%23) + 232 ))m ";
		done
		echo;
	done
}


### ZSH FUNCTIONS LOAD ###

autoload add-zsh-hook			# control the hooks (chpwd, precmd, ...)
autoload zed					# zsh editor
autoload zargs					# xargs like in shell
autoload _setxkbmap				# load setxkbmap autocompletion

# autoload predict-on			# fish like suggestion (with bundled lags !)
# predict-on

autoload -z edit-command-line	# edit command line with $EDITOR
zle -N edit-command-line

autoload -U colors && colors	# cool colors

autoload -U compinit
compinit						# enable completion
zmodload zsh/complist			# load compeltion list


### SETTING UP ZSH COMPLETION STUFF ###

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case insensitive completion
zstyle ':completion:*:(rm|emacs):*' ignore-line yes # remove suggestion if already in selection
zstyle ':completion:*' ignore-parents parent pwd		  # avoid stupid ./../currend_dir

zstyle ":completion:*" menu select # select menu completion

zstyle ':completion:*:*' list-colors ${(s.:.)LS_COLORS} # ls colors for files/dirs completion

zstyle ":completion:*" group-name "" # group completion

zstyle ":completion:*:warnings" format "Nope !" # custom error

zstyle ":completion:::::" completer _complete _approximate # approx completion after regular one
zstyle ":completion:*:approximate:*" max-errors "(( ($#BUFFER)/3 ))" # allow one error each 3 characters

zle -C complete-file complete-word _generic
zstyle ':completion:complete-file::::' completer _files

zstyle ':completion:*' file-sort modification # newest files at first

zstyle ":completion:*:descriptions" format "%B%d%b" # completion group in bold

zstyle ':completion::complete:*' use-cache on # completion caching
zstyle ':completion:*' cache-path ~/.zcache # cache path

compdef _gnu_generic gdb emacs htop curl tr pv objdump # parse gnu getopts --help
compdef _setxkbmap setxkbmap	# activate setxkbmap autocompletion


### HOMEMADE FUNCTIONS COMPLETION ###

_ff() { _alternative "args:type:(( 'h:search in hidden files' 'e:search for empty files' 'r:search for files with the reading right' 'w:search for files with the writing right' 'x:search for files with the execution right' 'b:search for block files' 'c:search for character files' 'd:search for directories' 'f:search for regular files' 'l:search for symlinks' 'p:search for fifo files' 'nh:exclude hidden files' 'ne:exclude empty files' 'nr:exclude files with the reading right' 'nw:exclude files with the writing right' 'nx:exclude files with the execution right' 'nb:exclude block files' 'nc:exclude character files' 'nd:exclude directories' 'nf:exclude regular files' 'nl:exclude symlinks symlinks' 'np:exclude fifo files' 'ns:exclude socket files'))" "*:root:_files" }
compdef _ff ff

_setprompt() { _arguments "1:prompt:(('complete:prompt with all the options' 'classic:classic prompt' 'lite:lite prompt' 'superlite:super lite prompt' 'nogit:default prompt without the git infos'))" }
compdef _setprompt setprompt

_loadconf() { _arguments "1:visual configuration:(('complete:complete configuration' 'static:complete configuration without the dynamic title and clock updates' 'lite:smaller configuration'))" }
compdef _loadconf loadconf

_kbd() { _alternative "1:layouts:(('us:qwerty keyboard layout' 'fr:azerty keyboard layout'))" "2:capslock rebinds:(('caps-ctrl:capslock as control' 'caps-esc:capslock as escape' 'caps-super:capslock as super'))" }
compdef _kbd kbd


### SHELL COMMANDS BINDS ###

# C-v or 'cat -v' to get the keycode
bindkey -s "^[j" "^A^Kjoin_others_shells\n" # join_others_shells user function
bindkey -s "^[r" "^Uressource\n"		  # source ~/.zshrc
bindkey -s "^[e" "^Uerror\n"			  # run error user function
bindkey -s "^[s" "^Asudo ^E"	# insert sudo
bindkey -s "\el" "^Uls\n"		# run ls

bindkey -s ";;" "~"


### ZLE FUNCTIONS ###

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
}; zle -N up-line-or-search-prefix

function down-line-or-search-prefix () # same with down
{
	local CURSOR_before_search=$CURSOR
	zle down-line-or-search "$LBUFFER"
	CURSOR=$CURSOR_before_search
}; zle -N down-line-or-search-prefix

function open-delims() # open and close quoting chars and put the cursor at the beginning of the quoting
{
	if [ $# -eq 2 ]; then
		BUFFER="$LBUFFER$1$2$RBUFFER"
		CURSOR+=$#1;
	fi
}; zle -N open-delims

function sub-function() zle open-delims "\$(" ")"
zle -N sub-function

function simple-quote() zle open-delims \' \'
zle -N simple-quote

function double-quote() zle open-delims \" \"
zle -N double-quote

function save-line()			# save the current line at its state in ~/.saved_commands
{
	echo $BUFFER >> ~/.saved_commands
}; zle -N save-line

function ctrlz()
{
	suspend;
}; zle -N ctrlz

function clear-and-accept()		# clear the screen and accepts the line
{
	zle clear-screen;
	[ $#BUFFER -ne 0 ] && zle accept-line;
}; zle -N clear-and-accept

function move-text-right()		# shift text after cursor to the right
{
	BUFFER="${BUFFER:0:$CURSOR} ${BUFFER:$CURSOR}";
	CURSOR+=1;
}; zle -N move-text-right

function move-text-left()		# shift text after cursor to the left
{
	if [ $CURSOR -ne 0 ]; then
		BUFFER="${BUFFER:0:$((CURSOR-1))}${BUFFER:$CURSOR}";
		CURSOR+=-1;
	fi
}; zle -N move-text-left

function shift-arrow()			# emacs-like shift selection
{
	((REGION_ACTIVE)) || zle set-mark-command;
	zle $1;
}; zle -N shift-arrow

function select-left() shift-arrow backward-char; zle -N select-left
function select-right() shift-arrow forward-char; zle -N select-right

function get-word-at-point()
{
	echo "${LBUFFER/* /}${RBUFFER/ */}";
}; zle -N get-word-at-point

function magic-abbrev-expand()	# expand the last word in the complete corresponding abbreviation if any
{
	local MATCH;
	local tmp;
	tmp=${LBUFFER%%(#m)[_a-zA-Z0-9\[\]/\-]#};
	MATCH=${abbrev[$MATCH]};
	if [ ! -z "$MATCH" ]; then
		LBUFFER="$tmp${(e)MATCH}";
	else
		case "$KEYS" in
			("	") zle expand-or-complete;;
			(*) zle .self-insert;;
		esac
	fi
}; zle -N magic-abbrev-expand

function self-insert-hook() # hook after each non-binded key pressed
{
	
}; zle -N self-insert-hook

function self-insert()			# call pre hook, insert key, and cal post hook
{
	zle .self-insert;
	zle self-insert-hook;
}; zle -N self-insert

function show-kill-ring()
{
	local kr;
	kr="=> $CUTBUFFER";
	for k in $killring; do
		kr+=", $k"
	done
	zle -M "$kr";
}; zle -N show-kill-ring


### ZSH FUNCTIONS BINDS ###

bindkey -e				  # load emacs style key binding


typeset -Ag key			  # associative array with more explicit names

key[up]=$terminfo[kcuu1]
key[down]=$terminfo[kcud1]
key[left]=$terminfo[kcub1]
key[right]=$terminfo[kcuf1]

key[C-up]="^[[1;5A"
key[C-down]="^[[1;5B"
key[C-left]="^[[1;5D"
key[C-right]="^[[1;5C"
# key[C-up]="^[[A"				# when on old terms
# key[C-down]="^[[B"
# key[C-left]="^[[D"
# key[C-right]="^[[C"

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

key[enter]=$terminfo[cr]
key[M-enter]="^[^J"
case "$OS" in
	(*cygwin*) 	key[C-enter]="^^";;
	(*) 		key[C-enter]="^J";;
esac

key[F1]=$terminfo[kf1]
key[F2]=$terminfo[kf2]
key[F3]=$terminfo[kf3]
key[F4]=$terminfo[kf4]
key[F5]=$terminfo[kf5]
key[F6]=$terminfo[kf6]
key[F7]=$terminfo[kf7]
key[F8]=$terminfo[kf8]
key[F9]=$terminfo[kf9]
key[F10]=$terminfo[kf10]
key[F11]=$terminfo[kf11]
key[F12]=$terminfo[kf12]



bindkey "^I" magic-abbrev-expand
# bindkey " " magic-abbrev-expand	# a bit too intrusive

bindkey $key[left] backward-char
bindkey $key[right] forward-char

bindkey $key[M-right] move-text-right
bindkey $key[M-left] move-text-left

bindkey "^X^E" edit-command-line # edit line with $EDITOR

bindkey "^Z" ctrlz			# ctrl z zsh

bindkey "^D" delete-char

bindkey "^X^X" exchange-point-and-mark

bindkey "^X^K" show-kill-ring

bindkey "\`\`" sub-function
bindkey "\'\'" simple-quote
bindkey "\"\"" double-quote

bindkey $key[C-left] backward-word
bindkey $key[C-right] forward-word

bindkey "^[k" kill-word
bindkey "^W" kill-region		 # emacs-like kill

bindkey "^Y" yank				# paste
bindkey "^[y" yank-pop			# rotate yank array

bindkey $key[S-tab] reverse-menu-complete # shift tab for backward completion

bindkey "^[=" save-line

bindkey $key[C-up] up-line-or-search-prefix # ctrl + arrow = smart completion
bindkey $key[C-down] down-line-or-search-prefix

bindkey $key[up] up-line-or-history # up/down scroll through history
bindkey $key[down] down-line-or-history

bindkey $key[S-right] select-right # emacs like shift selection
bindkey $key[S-left] select-left

bindkey $key[C-enter] clear-and-accept

bindkey $key[F1] run-help
bindkey $key[F5] clear-screen

### USEFUL ALIASES ###

case "$OS" in
	(*darwin*)					# Mac os
		alias update="brew update && brew upgrade";
		add-abbrev "install" "brew install ";
		alias ls="ls -G";;
	(*cygwin*)					# cygwin
		alias ls="ls --color=auto";
		add-abbrev "install" "apt-cyg install ";;
	(*linux*|*)					# Linux
		alias update="sudo apt-get update && sudo apt-get upgrade";
		add-abbrev "install" "apt-get install ";
		alias ls="ls --color=auto";;
esac


add-abbrev "ll"		"| less"
add-abbrev "tt"		"| tail -n"
add-abbrev "hh"		"| head -n"
add-abbrev "lc"		"| wc -l"
add-abbrev "gg"		"| grep -E "
add-abbrev "gv"		"| grep -Ev "
add-abbrev "ce"		"| cat -e"
add-abbrev "cutf"	"| cut -d\  -f"
add-abbrev "T"		"| tee "
add-abbrev "tf"		"tail -fn10"
add-abbrev "e"		"$EDITOR "
add-abbrev "pp"		"$PAGER "
add-abbrev "gb"		"git branch "
add-abbrev "branch"	"git branch "
add-abbrev "gc"		"git commit -m"
add-abbrev "commit"	"git commit -m"
add-abbrev "gk"		"git checkout "
add-abbrev "py"		"python "
add-abbrev "res"	"ressource"
add-abbrev "pull"	"git pull "
add-abbrev "fetch"	"git fetch "
add-abbrev "push"	"git push "
add-abbrev "gp"		"git push "
add-abbrev "s2e"	"1>&2"
add-abbrev "e2s"	"2>&1"
add-abbrev "ns"		"1> /dev/null"
add-abbrev "ne"		"2> /dev/null"
add-abbrev "col"	'${COLUMNS}'
add-abbrev "lin"	'${LINES}'
add-abbrev "wd"		'$(pwd)'
add-abbrev "rr"		'$(echo *(om[1]))'



alias l="ls -lFh"				# list + classify + human readable
alias la="ls -lAFh"				# l with hidden files
alias lt="ls -ltFh"				# l with modification date sort
alias lt="ls -ltFh"				# l with modification date sort
alias l1="ls -1"				# one result per line

alias mkdir="mkdir -pv"			# create all the needed parent directories + inform user about creations

alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
installed tree && alias tree="tree -C"		  # -C colorzzz
installed colordiff && alias diff="colordiff" # diff with nicer colors
installed rsync && alias cpr="rsync -a --stats --progress" || alias cpr="cp -R" # faster
alias less="less -RS"			# -R Raw control chars, -S to truncate the long lines instead of folding them

alias ressource="source ~/.zshrc"

alias emacs="emacs -nw"			# default emacs is in console
alias xemacs="command emacs"	# x one is not
alias emax="command emacs"
alias x="command emacs"
alias e="emacs"
alias qmacs="emacs -q"			# faster with no config files loaded
alias q="emacs -q"

alias size="du -sh"								# get the size of smthing
alias fatfiles="du -a . | sort -nr | head -n10" # get the 10 biggest files
alias df="df -Tha --total"		# disk usage infos
alias fps="ps | head -n1  && ps aux | grep -v grep | grep -i -e 'USER.*PID.*%CPU.*%MEM.*VSZ.*RSS TTY.*STAT.*START.*TIME COMMAND.*' -e " # fps <processname> to get ps infos only for the matching processes
alias tt="tail --retry -fn0"	# real time tail a log
alias dzsh="zsh --norcs --xtrace" # debugzsh

alias trunc='sed "s/^\(.\{0,$COLUMNS\}\).*$/\1/g"' # truncate too long lines


### MANDATORY FUNCTIONS CALLS ###

check_git_repo
set_git_branch
update_pwd_datas
update_pwd_save
set_git_char
loadconf static
title
rehash							# hash commands in path

trap clock WINCH

[ -e ~/.postzshrc ] && source ~/.postzshrc # load user file if any

# join_others_shells				# ask to join others shells

[ "$STARTUP_CMD" != "" ] && eval $STARTUP_CMD && unset STARTUP_CMD; # execute user defined commands after init

