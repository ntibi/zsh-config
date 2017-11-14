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
# Optimize all the callbacks
# improve cd hashed dirs completion (_cd_hashed_dir)
# improve remove-abbrev completion (with abbrevated command in completion help)
# find out how vi-match-bracket works
#


[ -e ~/.myzshrc ] && source ~/.myzshrc # load user file if any
[ -e ~/.preszhrc ] && source ~/.preszhrc


### USEFUL VARS ###

typeset -Ug PATH				# do not accept doubles

typeset -Ag abbrev				# global associative array to define abbrevations
typeset -Ag abbrev_curmov		# cursor movement after abbrev
typeset -Ag abbrev_autopipe		# autopipe for abbrev
typeset -Ag abbrev_beginning	# abbrev can not be used anywhere, only in beginning of line

WORDCHARS="*?_-.[]~=/&;!#$%^(){}<>|" # for the word-movement

PERIOD=5			  # period used to hook periodic function (in sec)

PWD_FILE=~/.pwd					# last pwd sav file


OS="$(uname | tr "A-Z" "a-z")"	# get the os name

UPDATE_TERM_TITLE="" # set to update the term title according to the path and the currently executed line
UPDATE_CLOCK=""		 # set to update the top-right clock every second

EDITOR="vi"
VISUAL="vi"
PAGER="less"

HISTFILE=~/.zshrc_history
SAVEHIST=65536
HISTSIZE=65536

CLICOLOR=1

LOCAL_CONF_FILE="~/.myzshrc"	# use like this: ${~LOCAL_CONF_FILE}

case "$OS" in
	(*darwin*)					# mac os
		LS_COLORS='exfxcxdxbxexexabagacad';;
    (*bsd*)                     # bsd
		LS_COLORS='exfxcxdxbxexexabagacad';;
	(*cygwin*)					# cygwin
		LS_COLORS='fi=1;32:di=1;34:ln=35:so=32:pi=0;33:ex=32:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=1;34:ow=1;34:';;
	(*linux*|*)					# linux
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
setopt share_history			# one history file to rule them all
setopt hist_ignore_dups			# ignore dups in history
setopt hist_expire_dups_first	# remove all dubs in history when full
setopt auto_remove_slash		# remove slash when pressing space in auto completion
setopt null_glob				# remove pointless globs
setopt auto_cd					# './dir' = 'cd dir'
setopt auto_push_d				# for the cd -
setopt c_bases					# c-like bases conversions
setopt c_precedences			# c-like operators
setopt emacs					# enable emacs like keybindigs
setopt flow_control				# enable C-q and C-s to control the flooow
setopt complete_in_word			# complete from anywhere
setopt clobber					# i aint no pussy
setopt extended_glob			# used in matching im some functions
setopt multi_os					# no more tee !
setopt cd_able_vars				# hash -d mdr=~/my/long/path/; cd mdr
setopt interactive_comments		# allow comments after command in interactive session
setopt hist_ignore_space        # do not append to history the commands starting with a space

[[ ! -z "$EMACS" ]] && unsetopt zle # allow zsh to work under emacs
unsetopt beep					# no disturbing sounds


### PS1 FUNCTIONS ###

function check_git_repo()		# check if pwd is a git repo
{
	git rev-parse > /dev/null 2>&1 && REPO=1 || REPO=0
}

function update_pwd_datas()		# update the numbers of files and dirs in .
{
	local f d
	f=( *(.D) )
	d=( *(/D) )
	NB_FILES=$#f
	NB_DIRS=$#d
}

function update_pwd_save()		# update the $PWD_FILE
{
	[[ $PWD != "$HOME" ]] && echo $PWD > $PWD_FILE
}

function set_git_branch()
{
	if [[ $REPO -eq 1 ]]; then		# if in git repo, get git infos
		GIT_BRANCH="$(git branch | grep \* | cut -d\  -f2-)";
	else
		GIT_BRANCH="";
	fi
}

function set_git_char()			# set the $GET_GIT_CHAR variable for the prompt
{
	if [[ "$REPO" -eq 1 ]];		# if in git repo, get git infos
	then
		local STATUS
		STATUS=$(git status 2> /dev/null)
		if [[ "$STATUS" =~ "Changes not staged" ]];
		then GET_GIT="%F{196}+"	# if git diff, wip
		else
			if [[ "$STATUS" =~ "Changes to be committed" ]];
			then GET_GIT="%F{214}+" # changes added
			else
				if [[ "$STATUS" =~ "is ahead" ]];
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
	if [[ ! -z $UPDATE_CLOCK ]]; then
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
HN_C="%F{33}"					# hostname color
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
		("classic") _PS1=("X" "X" "X" "X" "X" "" "X" "X" "X" "X" "X" "X");;
		("complete") _PS1=("X" "X" "X" "X" "X" "X" "X" "X" "X" "X" "X" "X");;
	esac
	PS1=''																								# simple quotes for post evaluation
	[ ! -z $_PS1[$_ssh] ] 			&& 	PS1+='$ID_C$GET_SSH'												# 'ssh:' if in ssh
	[ ! -z $_PS1[$_user] ] 			&&	PS1+='$ID_C%n'														# username
	if [ ! -z $_PS1[$_user] ] && [ ! -z $_PS1[$_machine] ]; then
		PS1+='${SEP_C}@'
	fi
	[ ! -z $_PS1[$_machine] ]		&& 	PS1+='$HN_C%m'												# @machine
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
	[ ! -z $_PS1[$_git_status] ] 	&& 	PS1+='$GET_GIT'														# git status (red + -> dirty, orange + -> changes added, green + -> changes commited, green = -> changed pushed)
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
    if [[ -n $UPDATE_TERM_TITLE ]]; then
        case $TERM in
            screen*) # do not print cwd in tmux/screen
                set_title ${1// */};; # and only the binary name, not the args
            *)
                set_title "${PWD/~/~} : $1";; # set 'pwd + cmd' set term title
        esac
    fi
}

function precmd()				# pre promt hook
{
    [[ -z $UPDATE_CLOCK ]] || clock
    if [[ -n $UPDATE_TERM_TITLE ]]; then
        case $TERM in
            screen*) # do not print cwd in tmux/screen
                set_title zsh;;
            *)
                set_title "${PWD/~/~}";; # set pwd as term title
        esac
    fi

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
	python -c "
import os;
print '{}: {}'.format($?, os.strerror($?))
";
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

function tmp()					#
{
	# env STARTUP_CMD="cd /tmp" zsh;
	cd "$(mktemp -d)"
	pwd
}

function -() 					# if 0 params, acts like 'cd -', else, act like the regular '-'
{
	[[ $# -eq 0 ]] && cd - || builtin - "$@"
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
	if [[ $# -eq 0 ]]; then
		echo "Usage: colorize <exp1> <color1> <exp2> <color2> ..." 1>&2
		return ;
	fi
	for c in "$@"; do
		if [[ "$((i % 2))" -eq 1 ]]; then
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
			if [[ $#background -ne 0 ]]; then
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
	if [[ "$c" = "$last" ]]; then
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

function ft()					# find $1 in all files or files containing $3 from $2 or .
{
	command find -O3 ${2:=.} -type f -name "*${3:=}*" -exec grep --color=always -EInH -e "$1" {} +; # grep: E extended regex, I (ignore binary) n (line number) H (print fn each line)
}

function installed()
{
    hash "$1" 2>/dev/null
}

function xtrace()				# debug cmd line with xtrace
{
	set -x;
	$@
}

function title()				# set the title of the term, or toggle the title updating if no args
{
	if [[ "$#" -ne "0" ]]; then
        set_title $@
		UPDATE_TERM_TITLE="" # forced title is persistent
	else
		if [[ -z "$UPDATE_TERM_TITLE" ]]; then
			UPDATE_TERM_TITLE="X"
		else
            set_title $@
			UPDATE_TERM_TITLE=""
		fi
	fi
}

function set_title() # sets the term title (handles tmux/screen)
{
    case $TERM in
        screen*)
            print -Pn "\ek$@\e\\";;
        *)
            print -Pn "\e]2;$@\a";;
    esac
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
			setprompt classic;
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
{
	echo $(( [#16]$1 ));
}

function h2d()					# hexa to decimal
{
	echo $(( 16#$1 ));
}

function d2b()					# decimal to binary
{
	echo $(( [#2]$1 ));
}

function h2b()					# binary to decimal
{
	echo $(( 2#$1 ));
}

function h2b()					# hexa to binary
{
	echo $(( [#2]16#$1 ));
}

function b2h()					# binary to hexa
{
	echo $(( [#16]2#$1 ));
}

function show-associative-array() # nicely list associative array with: show-associative-array ${(kv)array}
{
	local -A aarray;
	local -i pad;

	aarray=( $@ );
	for k in "${(@k)aarray}"; do
		[[ $#k -gt $pad ]] && pad=$#k;
	done
	(( pad+=2 ));
	for k in "${(@k)aarray}"; do
		printf "$C_YELLOW%-${pad}s$C_GREY->$DEF_C  \"$C_CYAN%s$DEF_C\"\n" "$k" "$aarray[$k]";
	done	
}

# TODO: add a flag to specify if the abbrev must be at the beginning of the line
function add-abbrev()			# add a dynamic abbreviation
{
	if [ $# -eq 2 ]; then
		abbrev+=("$1" "$2");
	else
		echo "Usage: add-abbrev 'word' 'abbrev'" >&2;
	fi
}

function abbrev-autopipe() # turn autopipe on for this abbrev
{
	if [ $# -eq 1 ]; then
		abbrev_autopipe+=("$1" 1);
	else
		echo "Usage: abbrev-autopipe 'abbrev'" >&2;
	fi
}

function abbrev-cur() # set a cursor offset for this abbrev
{
	if [ $# -eq 2 ]; then
		abbrev_curmov+=("$1" "$2");
	else
		echo "Usage: abbrev-cur 'abbrev' 'n'" >&2;
	fi
}

function abbrev-beginning() # turn beginning on for this abbrev
{
	if [ $# -eq 1 ]; then
		abbrev_beginning+=("$1" 1);
	else
		echo "Usage: abbrev-beginning 'abbrev'" >&2;
	fi
}

function show-abbrevs()			# list all the defined abbreviations
{ # abbrev -> autopipe? "result" cursormove?
	local -i pad;

	for k in "${(@k)abbrev}"; do
		[[ $#k -gt $pad ]] && pad=$#k;
	done
	(( pad+=1 ));
	for k in "${(@k)abbrev}"; do
		printf  "$C_YELLOW%-${pad}s$C_GREY->$DEF_C  $C_GREEN%s$DEF_C\"$C_CYAN%s$DEF_C\" $C_GREEN%s$DEF_C\n"\
                "$k"\
                "$([[ $abbrev_autopipe[$k] -eq 1 ]] && echo -n " " || echo -n "|")"\
                "$abbrev[$k]"\
                $abbrev_curmov[$k];
	done
}

function remove-abbrev()
{
	[[ $# -lt 1 ]] && return 1;
	local -a to_remove;
	typeset -Ag new_abbrev;

	to_remove=( $@ )
	for k in "${(@k)abbrev}"; do
		if [[ -z $to_remove[(r)$k] ]]; then # if current key is not in to_remove array
			new_abbrev[$k]="$abbrev[$k]";
		else
			unhash -f $k 2>/dev/null;		# unalias
		fi
	done
	abbrev=( ${(kv)new_abbrev} );
}

function show-aliases()			# list all aliases
{
	show-associative-array ${(kv)aliases};
}

function mkback()				# create a backup file of . or the specified dir/file
{
	local toback;
	local backfile;

	if [[ -e "$1" ]] && [[ "$1" != "." ]] ; then
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
    [[ $x == -1 ]] && x=$(( COLUMNS / 2 - $#msg / 2 ));
	[[ $y == -1 ]] && y=$(( LINES / 2 ));
	tput civis;
	tput sc;
	tput cup $y $x;
	print "$msg";
	read -sk1;
	tput rc;
	tput cnorm;
}

function get_cup()
{
	stty -echo;
	echo -n $'\e[6n';
	read -d R x;
	stty echo;
	echo "${x#??}";
}

function set_cup()
{
	tput cup ${1//;/ };
}

function format()
{
	clang-format -i -style="{
BasedOnStyle: llvm,
TabWidth: 4,
IndentWidth: 4,
AllowShortFunctionsOnASingleLine: None,
KeepEmptyLinesAtTheStartOfBlocks: false,
Language: Cpp,
BreakBeforeBraces: Allman,
UseTab: Never,
MaxEmptyLinesToKeep: 1,
}" "$@"
}

function go()
{
	emacs -q -nw --batch --eval "(browse-url-of-file \"https://duckduckgo.com/"$@"\")"
}

# example> addd ec ~/emacs-config/
function addd()					# add a directory hash to the config file
{
	# $1: dir name (default value $(basename $PWD))
	# $2: hash key (default value .)
	# $3: if set, append a '/' to the aliased dir (this will prevent the complete aliasing)
	
	hdir="${1:=${PWD:t}}"
	dir="${${2:=$PWD}:a}${3:+/}"
	echo "hash -d $hdir=$dir" >> ${~LOCAL_CONF_FILE:=~/.myzshrc}
	hash -d $hdir=$dir
	echo "$C_YELLOW$dir$DEF_C is now aliased as $C_CYAN$hdir$DEF_C (in ${LOCAL_CONF_FILE:=~/.myzshrc})"
}

function sizeof()
{
	echo "#include <stdint.h>\nint main(){return (sizeof($1));}" | gcc -x c -o/tmp/sizeof - 2>&- || return
	/tmp/sizeof
	echo $?
}

function sizeof32()
{
	echo "#include <stdint.h>\nint main(){return (sizeof($1));}" | gcc -m32 -x c -o/tmp/sizeof - 2>&- || return
	/tmp/sizeof
	echo $?
}

function sizeof64()
{
	echo "#include <stdint.h>\nint main(){return (sizeof($1));}" | gcc -m64 -x c -o/tmp/sizeof - 2>&- || return
	/tmp/sizeof
	echo $?
}

function rgb() # if truecolor is set, sets the foreground color
{
	[[ -z "$1$2$3" ]] &&
	printf $DEF_C ||
	printf "\033[38;2;%d;%d;%dm" $1 $2 $3
}

function rgbb() # if truecolor is set, sets the background color
{
	[[ -z "$1$2$3" ]] &&
	printf $DEF_C ||
	printf "\033[48;2;%d;%d;%dm" $1 $2 $3
}

function foreachd() # foreachd ~/.config/*-config -- ./install.sh
{
    dirs=()
    cmd=()
    found=""

    for i in $@; do
        if [[ "$i" == "-" || "$i" == "--" ]]; then
            found="1";
        elif [[ "$found" -eq 0 ]]; then
            dirs+=$i
        else
            cmd+=$i
        fi
    done
    for d in $dirs; do
        print "\e[4m${d:t}\e[0m:"
        pushd $d >/dev/null
        eval $cmd
        popd >/dev/null
    done
}

function fatfiles() # get the n biggest files (default 10)
{
    du -a . | sort -nr | head -n ${1:-10} | awk 'BEGIN{ split("K M G", v) } { n=$1; s=1; while( n > 1024 ){ n /= 1024; ++s; } size = (v[s] == "G") ? sprintf("%.1f%c", n, v[s]) : sprintf("%0.f%c", n, v[s]); printf("%-7s %s\n", size, $2) }'
}

function ci() # ci 'printf("Hello %s !\n", av[1]);' ntibi
{
    local fn
    local final

    [[ -d /tmp/ci ]] || mkdir -p /tmp/ci
    fn=$(mktemp /tmp/ci/XXXXXX.c)
    out=$(mktemp /tmp/ci/out.XXXXXX)
    cat > $fn << EOF
#include <unistd.h>
#include <stdio.h>
#include <strings.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <stddef.h>
int main(int ac, char **av, char *env)
{
EOF
# -R pour l'escaping
    print -R $1 >> $fn
    cat >> $fn << EOF
    return 0;
}
EOF
    gcc $fn -o $out
    shift
    $out $*
}

function n() # goto the #n next numbered directory (defaults at 1)
{
    local NEW;

    NEW=$(echo $PWD | sed "s/^\(.*\)\([0-9]\+\)\(.*\)$/echo \1\$((\2+${1:=1}))\3/ge");
    if [[ NEW != PWD ]]; then
        if [[ -d $NEW ]]; then
            cd $NEW;
        fi
    fi
}

function p() # goto the #n previous numbered directory (defaults at 1)
{
    local NEW;

    NEW=$(echo $PWD | sed "s/^\(.*\)\([0-9]\+\)\(.*\)$/echo \1\$((\2-${1:=1}))\3/ge");
    if [[ NEW != PWD ]]; then
        if [[ -d $NEW ]]; then
            cd $NEW;
        fi
    fi
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

function weather()				# prints weather info
{
	curl wttr.in/paris
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

zmodload zsh/regex


### SETTING UP ZSH COMPLETION STUFF ###

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case insensitive completion
zstyle ':completion:*:(rm|emacs|kill|remove-abbrev|unalias):*' ignore-line yes # remove suggestion if already in selection
zstyle ':completion:*' ignore-parents parent pwd		  # avoid stupid ./../currend_dir

zstyle ':completion:*:processes' command 'ps -au$USER'	  # list all user processes

zstyle ':completion:*:*:kill:*:processes' list-colors "=(#b) #([0-9]#)*=29=34" # nicer kill

zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin/sbin /bin

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

zstyle ':completion:history-words:*' menu yes select # for M-/ completion
zstyle ':completion:history-words:*' remove-all-dups yes

compdef '_files -g "out"' '-redirect-,2>,-default-' # suggest out file for redirections
compdef '_files -g "out"' '-redirect-,>,-default-'

compdef _gnu_generic gdb emacs emacsclient htop curl tr pv objdump # parse gnu getopts --help
compdef _setxkbmap setxkbmap	# activate setxkbmap autocompletion


### HOMEMADE FUNCTIONS COMPLETION ###

_remove-abbrev() { local expl; _wanted arguments expl 'abbreviation' compadd -k abbrev }
compdef _remove-abbrev remove-abbrev

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
    if [[ $#jobstates -ne 0 ]]; then
        if [[ $#BUFFER -ne 0 ]]; then
            zle push-input
        fi
        BUFFER=fg
        zle accept-line
    fi
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

function magic-abbrev-expand() # expand the last word in the complete corresponding abbreviation if any
{
    local MATCH;
    local REPL;
    local tmp;
    local CURMOV=0;                                                 # use $abbrev_curmov to move the cursor after abbrev expand
    local AUTOPIPE=0;                                               # use $abbrev_autopipe to automatically prepend the abbrev with a pipe
    tmp=${LBUFFER%%(#m)[._a-zA-Z0-9\[\]/\-]#};
    REPL=${abbrev[$MATCH]};
    if [ ! -z "$REPL" ]; then
        if [[ ! ${abbrev_beginning[$MATCH]} || $MATCH == ${LBUFFER[1, $#MATCH]} ]]; then # check if abbrev must start the line
            CURMOV="${abbrev_curmov[$MATCH]}"
            AUTOPIPE="${abbrev_autopipe[$MATCH]}"
            if [[ $AUTOPIPE -eq 0 ]]; then
                LBUFFER="$tmp${(e)REPL}";
            else
                if [[ $#tmp -eq 0 || $tmp -regex-match "\| *$" ]]; then # BUFFER is ">abbrev" or ">cmd | abbrev" >>> don't add a pipe
                    [[ $CURMOV -ne 0 ]] && CURMOV+=-1;                  # because of the appened space
                    LBUFFER="$tmp${(e)REPL} ";
                else                                                    # BUFFER is ">abbrev" >>> add a pipe
                    LBUFFER="$tmp| ${(e)REPL}";
                fi
            fi
        fi
        [[ $CURMOV -ne 0 ]] && CURSOR=$(( CURSOR + CURMOV ))
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
	zle -M -- "$kr";
}; zle -N show-kill-ring

function transpose-chars-inplace()
{
	BUFFER="${LBUFFER[1,-2]}${RBUFFER[1]}${LBUFFER[-1]}${RBUFFER:1}"
}; zle -N transpose-chars-inplace

function remove-pipe()			# delete chars backwards beyond the next pipe
{
	SPLIT=(${(@s:|:)LBUFFER})
	LBUFFER=${(j:|:)${SPLIT[1,-2]}}
}; zle -N remove-pipe

function operation-at-point()	# simplify the operation at point
{
	LB="${LBUFFER/*[^0-9\-\+\*\/\^\(\)]/}"
	NLB="$LBUFFER[0,$#LBUFFER-$#LB]"
	RB="${RBUFFER/[^0-9\-\+\*\/\^\(\)]*/}"
	NRB="$RBUFFER[$#RB+1,$#RBUFFER]"
	N="$LB$RB"
	if [[ -n $N ]]; then
		NN=$(echo "$N" | bc -q 2>/dev/null)
		N=${NN:-$N}
	fi
	BUFFER="$NLB$N$NRB"
}; zle -N operation-at-point

function sudo-line() # add sudo to the current command or the last command
{
    [[ -z $BUFFER ]] && zle up-history
    if [[ $BUFFER[1,5] != "sudo " ]]; then
        BUFFER="sudo $BUFFER"
        CURSOR=$(( CURSOR + 5 ))
    fi
}; zle -N sudo-line

function su-c-line() # same function as sudo-line but with su when sudo is not available
{
    [[ -z $BUFFER ]] && zle up-history
    if [[ $BUFFER[1,6] != "su -c " ]]; then
        zle quote-line
        BUFFER="su -c $BUFFER"
        CURSOR=$(( CURSOR + 7 ))
    fi
}; zle -N su-c-line

function desc-word-at-point()
{
    local DESC="$(where "${LBUFFER/* /}${RBUFFER/ */}")"
    zle -M ${DESC:-nope}
}; zle -N desc-word-at-point


### ZSH FUNCTIONS BINDS ###

bindkey -e				  # load emacs style key binding


typeset -Ag key			  # associative array with more explicit names

key[up]=$terminfo[kcuu1]
key[down]=$terminfo[kcud1]
key[left]=$terminfo[kcub1]
key[right]=$terminfo[kcuf1]

# key[C-up]=$(echotc ku)
# key[C-down]=$(echotc kd)
# key[C-left]=$(echotc kl)
# key[C-right]=$(echotc kr)

key[C-up]="^[[1;5A"				# cygwin
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

bindkey $key[M-right] vi-match-bracket
bindkey $key[M-left] vi-match-bracket

bindkey "^[e" edit-command-line # edit line with $EDITOR

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
bindkey "^T" transpose-chars-inplace

bindkey $key[C-up] up-line-or-search-prefix # ctrl + arrow = smart completion
bindkey $key[C-down] down-line-or-search-prefix

bindkey $key[up] up-line-or-history # up/down scroll through history
bindkey $key[down] down-line-or-history

#bindkey $key[S-right] select-right # emacs like shift selection
#bindkey $key[S-left] select-left

bindkey $key[C-enter] clear-and-accept

bindkey $key[F1] run-help
bindkey $key[F5] clear-screen

bindkey "^\\" remove-pipe
bindkey "^[o" operation-at-point

autoload copy-earlier-word  # copy earlier word (like M-. but to scroll through previous agruments)
zle -N copy-earlier-word
bindkey "^[," copy-earlier-word

bindkey "^[." insert-last-word

bindkey "^[?" _history-complete-older
bindkey "^[/" _history-complete-newer

bindkey $key[F1] desc-word-at-point

installed sudo && bindkey "^[s" sudo-line || bindkey "^[s" su-c-line

bindkey -M menuselect "^[?" _history-complete-older


### USEFUL ALIASES ###

add-abbrev "ll"		"less"                ; abbrev-autopipe "ll"
add-abbrev "tf"		"tail -f"             ; abbrev-autopipe "tf"
add-abbrev "tt"		"tail"                ; abbrev-autopipe "tt"
add-abbrev "hh"		"head"                ; abbrev-autopipe "hh"
add-abbrev "lc"		"wc -l"               ; abbrev-autopipe "lc"
add-abbrev "gg"		"grep \"\""           ; abbrev-autopipe "gg"   ; abbrev-cur "gg" -1
add-abbrev "ge"		"grep -E \"\""        ; abbrev-autopipe "ge"   ; abbrev-cur "ge" -1
add-abbrev "gv"		"grep -v \"\""        ; abbrev-autopipe "gv"   ; abbrev-cur "gv" -1
add-abbrev "gev"	"grep -Ev \"\""       ; abbrev-autopipe "gev"  ; abbrev-cur "gev" -1
add-abbrev "ce"		"cat -e"              ; abbrev-autopipe "ce"
add-abbrev "cutf"	"cut -d\  -f"         ; abbrev-autopipe "cutf"

add-abbrev "T"		"| tee "
add-abbrev "TS"		"| sudo tee "

add-abbrev "e"		'$EDITOR '
add-abbrev "v"		'$EDITOR '

add-abbrev "pp"		'$PAGER'              ; abbrev-autopipe "pp"

add-abbrev "gb"		"git branch -a"
add-abbrev "branch"	"git branch -a"
add-abbrev "gc"		'git commit -m""'     ; abbrev-cur "gc" -1
add-abbrev "commit"	'git commit -m""'     ; abbrev-cur "commit" -1
add-abbrev "gk"		"git checkout "
add-abbrev "pull"	"git pull "
add-abbrev "fetch"	"git fetch -a "
add-abbrev "gf"		"git fetch -a "
add-abbrev "push"	"git push "
add-abbrev "gp"		"git push "

add-abbrev "py"     "python "
add-abbrev "pyc"    "python -c''"         ; abbrev-cur "pyc" -1
add-abbrev "res"	"ressource"

add-abbrev "s2e"	"1>&2"
add-abbrev "e2s"	"2>&1"
add-abbrev "ns"		"1> /dev/null"
add-abbrev "ne"		"2> /dev/null"

add-abbrev "col"	'${COLUMNS}'
add-abbrev "COL"	'\${COLUMNS}'
add-abbrev "lin"	'${LINES}'
add-abbrev "LIN"	'\${LINES}'
add-abbrev "wd"		'$(pwd)'
add-abbrev "rr"		'$(echo *(om[1]))'

add-abbrev "bel"	'&& tput bel'

add-abbrev "awk"    "awk '{}'"            ; abbrev-autopipe "awk"  ; abbrev-cur "awk" -2
add-abbrev "awkf"   "awk -F: '{}'"        ; abbrev-autopipe "awkf" ; abbrev-cur "awkf" -2

add-abbrev "showf"  'echo \$functions['

add-abbrev "f."    'find . -name ""'      ; abbrev-cur "f." -1
add-abbrev "f/"    'find / -name ""'      ; abbrev-cur "f/" -1

add-abbrev "ssht"   'ssh -t  tmux attach' ; abbrev-cur "ssht" -12

add-abbrev "t" "tmux "                    ; abbrev-beginning "tmux"

add-abbrev "ci"    "ci ''"                ; abbrev-autopipe "ci"  ; abbrev-cur "ci" -1


case "$OS" in
	(*darwin*)					# Mac os
		add-abbrev "update" "brew update && brew upgrade";
		add-abbrev "install" "brew install ";
		add-abbrev "search" "brew search ";
		
		alias ls="ls -G";
		;;
	(*cygwin*)					# cygwin
		add-abbrev "update" "setup.exe";
		add-abbrev "install" "apt-cyg install ";
		add-abbrev "search" "apt-cyg searchall ";
		
		alias ls="ls --color=auto";
		;;
    (*bsd*)
		add-abbrev "update" "pkg upgrade";
		add-abbrev "install" "pkg install ";
		add-abbrev "search" "pkg search ";

        alias ls="ls -G";
        ;;
	(*linux*|*)					# Linux
		add-abbrev "update" "sudo apt-get update && sudo apt-get upgrade";
		add-abbrev "install" "apt-get install ";
		add-abbrev "search" "apt-cache search ";
		
		alias ls="ls --color=auto";
		;;
esac


alias l="ls -lFh"				# list + classify + human readable
alias la="ls -lAFh"				# l with hidden files
alias lt="ls -ltFh"				# l with modification date sort
alias lt="ls -ltFh"				# l with modification date sort
alias l1="ls -1"				# one result per line

alias mkdir="mkdir -pv"			# create all the needed parent directories + inform user about creations

alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias tree="tree -C"		  # -C colorzzz
installed colordiff && alias diff="colordiff" # diff with nicer colors
installed rsync && alias cpr="rsync -a --stats --progress" || alias cpr="cp -R" # faster
alias less="less -RS"			# -R Raw control chars, -S to truncate the long lines instead of folding them

alias ressource="source ~/.zshrc"

alias emacs="emacs -nw"			# default emacs is in console
alias xemacs="command emacs"	# x one is not
alias emax="command emacs"
alias e="emacs"
alias qmacs="emacs -q"
alias q="emacs -q"

installed nvim && alias vim="nvim" # prefer neovim
alias vi="vim"
alias v="vim"
alias vq="vim -u NONE"

alias size="du -sh"								# get the size of smthing
alias df="df -Tha --total"		# disk usage infos
alias fps="ps | head -n1  && ps aux | grep -v grep | grep -i -e 'USER.*PID.*%CPU.*%MEM.*VSZ.*RSS TTY.*STAT.*START.*TIME COMMAND.*' -e " # fps <processname> to get ps infos only for the matching processes
alias tt="tail --retry -fn0"	# real time tail a log
alias dzsh="zsh --norcs --xtrace" # debugzsh

alias trunc='sed "s/^\(.\{0,$COLUMNS\}\).*$/\1/g"' # truncate too long lines

alias dmake='CFLAGS+="-g3 -DDEBUG" make'

alias t="tmux" 
alias ta="tmux attach-session || tmux new-session"

alias TODO="grep --exclude-dir='.git' -InHo 'TODO.*' -r ."


### MANDATORY FUNCTIONS CALLS ###

check_git_repo
set_git_branch
update_pwd_datas
update_pwd_save
set_git_char
loadconf static
title
rehash							# hash commands in path

# call the clock update when the term size change
# trap clock WINCH


[ -e ~/.postzshrc ] && source ~/.postzshrc # load user file if any

# join_others_shells				# ask to join others shells

[ "$STARTUP_CMD" != "" ] && eval $STARTUP_CMD && unset STARTUP_CMD; # execute user defined commands after init

