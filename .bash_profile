# ============================================================================
# Created:	2015/09/10 Thomas Nguyen - thomas_ejob@hotmail.com
# Purpose:	Conversion back to DOS
# Source:	http://www.lemoda.net/windows/windows2unix/windows2unix.html
#			http://linux-sxs.org/housekeeping/lscolors.html
#			http://www.buluschek.com/?p=58
#			http://javarevisited.blogspot.com/2011/06/10-examples-of-grep-command-in-unix-and.html
#			http://unix.stackexchange.com/questions/168710/formatting-the-output-of-grep-when-matching-on-multiple-files
#			http://stackoverflow.com/questions/3731513/how-do-you-type-a-tab-in-a-bash-here-document
# For Windows/Cygwin:	copy this file to C:\cygwin64\home\<userName>\.bashrc.txt
# For Windows/Githubs:	create/copy this file to C:\Users\<userName>\.bash_profile
# For Mac OS/X:			create/copy this file to .bash_profile
#
# OTHER COMMANDS:
# touch <filename>			=> create a file
# cat <source> >> <target>	=> copy the text content from source to target
# cat <source> | wc			=> echo number of lines, words, and characters
# sort <filename> | uniq	=> echo the unique lines ordered alphabetically
# grep -i <text> <filename>	=> echo all "text" found inside the filename
# export USER="Jane Doe"	=> define a environment variables
# env						=> return list of the environment variables
# ============================================================================

export SHELLOPTS					#http://stackoverflow.com/questions/11616835/r-command-not-found-bashrc-bash-profile


function confirmPopup()
{
	printf "$1? [y/n]"
	read confirm
	if [ "$confirm" = "yes" ]; then
		return 0
	elif [ "$confirm" = "y" ]; then
		return 0
	elif [ "$confirm" = "1" ]; then
		return 0
	fi
	return 1
}
function pause() {
	if [ $# -eq 0 ]; then
		read -p "Press [Enter] key to continue"
	else
		read -p "$*"
	fi
}

function isWindows() {
	if [[ "$(uname -s)" == *"MINGW32_NT"* ]]; then
		# Do something under Windows NT platform
		return 0
	elif [[ "$(uname -s)" == *"CYGWIN"* ]]; then
		# Do something under Windows NT platform
		return 0
	else
		#Unknown OS
		return 1
	fi
}
function isOSX() {
	if [ "$(uname)" == "Darwin" ]; then
		# Do something under Mac OS X platform
		return 0
	else
		#Unknown OS
		return 1
	fi
}
function isLinux() {
	if [[ "$(uname -s)" == *"Linux"* ]]; then
		# Do something under GNU/Linux platform
		return 0
	else
		#Unknown OS
		return 1
	fi
}

# ============================================================================
# Directory & File
# ============================================================================

function copy()
{
	if [ $# -ne 2 ]; then
		printf "purpose: copy file or folder\n"
		printf "usage: copy [name1] [name2]\n"
	elif [ -f $2 ]; then
		printf "ERROR: File already exists: $2\n"
	elif [ -d $2 ]; then
		printf "ERROR: Directory already exists: $2\n"
	else
		if [ -f $1 ]; then
			cp -i $1 $2
		elif [ -d $1 ]; then
			printf "copy folders: "
			cp -ivR $1 $2
		else
			printf "ERROR: nothing done\n"
		fi
	fi
}
function move()
{
	if [ $# -ne 2 ]; then
		printf "purpose: move file or folder\n"
		printf "usage: move [name1] [name2]\n"
	elif [ -f $2 ]; then
		printf "ERROR: File already exists: $2\n"
	elif [ -d $2 ]; then
		printf "ERROR: Directory already exists: $2\n"
	else
		if [ -f $1 ]; then
			mv -i $1 $2
		elif [ -d $1 ]; then
			printf "move folder: "
			mv -iv $1 $2
		else
			printf "ERROR: nothing done\n"
		fi
	fi
}
function del()
{
	if [ $# -ne 1 ]; then
		printf "purpose: Delete a file or folder\n"
		printf "usage: del [name]\n"
	elif [ -f $1 ]; then
		rm -i $1
	elif [ -d $1 ]; then
		if confirmPopup "Delete folder $1"; then
			printf "deltree folder: "
			rm -vrf $1
		else
			printf "ERROR: nothing done\n"
		fi
	else
		printf "ERROR: nothing done\n"
	fi
}
function comp()
{
	#PS: MSDOS equivalent: "comp $1 $2"
	if [ $# -ne 2 ]; then
		printf "purpose: Compare 2 file size\n"
		printf "usage: comp [filename1] [filename2]\n"
	elif [ -f $1 ]; then
		if [ -f $2 ]; then
			printf "comp files: "
			FC /B $1 $2
		else
			printf "ERROR: file not found: $2\n"
		fi
	elif [ -d $1 ]; then
		if [ -d $2 ]; then
			printf "comp folders: "
			diff -arq $1 $2
			printf "\n"
		else
			printf "ERROR: folder not found: $2\n"
		fi
	else
		printf "ERROR: nothing done\n"
	fi
}

# ============================================================================
# Directory ONLY
# ============================================================================

alias chdir=pwd
alias "cd.."="cd ..;pwd"
#alias "cd/"="cd ~"			#not allowed to defined
#alias "cd\"="cd ~"			#not allowed to defined
alias findstr="grep"		#Windows example: dir | findstr console


function tree()
{
	find . -type d -print | sed -e 's;[^/]*/;|___;g;s;___|; |;g'
}
function md()
{
	if [ $# -ne 1 ]; then
		printf "purpose: Make a folder\n"
		printf "usage: md [folder]\n"
	elif [ -d $1 ]; then
		printf "ERROR: Folder already exists: $1\n"
	else
		mkdir $1
	fi
}
function mdcd()
{
	if [ $# -ne 1 ]; then
		printf "purpose: Create a folder and change directory\n"
		printf "usage: mdcd [folder]\n"
	elif [ -d $1 ]; then
		printf "ERROR: Folder already exists: $1\n"
	else
		mkdir $1
		cd $1
	fi
}

# ============================================================================
# File ONLY
# ============================================================================

alias where="which"		#Search for a software: where = which <software name>


#Look/search for filename(s).
function dir()
{
	if [ $# -eq 0 ]; then
		printf "Current directory: "
		pwd

		if isWindows; then
			ls -AlX --color --group-directories-first | grep --color "^d"
			ls -AlX --color --group-directories-first | grep --color "^-"
		elif [[ $EUID = 0 ]]; then
			ls -Al
		else
			ls -Al | grep --color "^d"
			ls -Al | grep --color "^-"
		fi
	else
		#PS: MSDOS equivalent: "dir *.cpp *.h *.java /b/s"
		variables=""
		#for ((i=1;i<=$#;i++));
		for arg in "$@"
		do
			if [ "$variables" != "" ]; then
				variables="$variables -o -name $arg"
			else
				variables="$arg"
			fi
		done
		find . -name $variables
	fi
}

# ============================================================================
# Inside a text file
# ============================================================================

alias type="cat"		#PS: "tail -f" is more useful than "cat"


function edit()
{
	#SOURCE: http://www.radford.edu/~mhtay/CPSC120/VIM_Editor_Commands.htm
	#For URL, use "curl" command to view the HTML
	printf "commands: Ctrl+b=PgUp, Ctrl+f=PgDn"
	printf "commands: ESC\t\t\t i=insert mode\n"
	printf "commands: v=start selecting,\t d=cut/y=copy,\t\t p=paste\n"
	printf "commands: x=delete,\t\t dw=delete word,\t dd=delete line\n"
	printf "commands: wq=save & exit\n"
	pause
	vim $1
}

# ============================================================================
# DEPRECATED = USELESS COMMANDS but added just because...
# ============================================================================

function xcopy()
{
	copy $@
}
function rd()
{
	del $@
}
function deltree()
{
	del $@
}

function ren()
{
	move $@
}

# ============================================================================
#Custom commands
#Help:
#	help:	bash built-in, providing help for bash commands only
#	info:	kind of like man but rarely used
#	man:	traditional form of help for almost every command on your system
#Source: https://pthree.org/2012/08/14/appropriate-use-of-kill-9-pid/
# ============================================================================

#List all custom commands/alias
function commands()
{
	printf "LIST OF ALL EXTRA COMMANDS: commands\n"
	printf "DIRECTORY:\tcopy, move, del, comp;\tchdir, tree, cd.., md, mdcd;\t xcopy, rd, deltree\n"
	printf "FILE:\t\tcopy, move, del, comp;\tdir, where;\t\t\t ren, dos2unix\n"
	printf "INSIDE TEXT:\ttype, edit;\t\tproperty, search, searchCount\n"
	printf "OTHERS:\t\tcls, findstr(=grep), f7(=history), killProcess, wmic, ver\n"
}


#On windows7, you press F7 to view the command prompt history
function f7()
{
	if [ $# -eq 0 ]; then
		history
	elif [ $1 = "cls" ] || [ $1 = "clear" ]; then
		if [ -n "$ZSH_VERSION" ]; then
			rm $HISTFILE
			printf "Restart shell to see history is gone\n"
		elif [ -n "$BASH_VERSION" ]; then
			history -cw
			printf "history is cleared\n"
		fi
	else
		history | grep --color $1
	fi
}

function killProcess()
{
    #PID: Process Id
    #PPID: Parent Process Id (the one which launched this PID)
    #TGID: Thread Group Id

	if isWindows; then
		ps -efW | sort -bgk 1			#display all processes (Windows ONLY)
	else
		ps -ef | sort -bgk 1			#display all processes
	fi
	printf "Enter the PPID to kill:"
	read processID
	if [ "$processID" != "" ] && [ $processID -gt 0 ]; then
		kill -9 $processID
	fi
	echo "DONE"
}


function property()
{
	if [ $# -ne 1 ]; then
		printf "purpose: Check a file properties\n"
		printf "usage: property [filename]\n"
	elif [ ! -f $1 ]; then
		printf "ERROR: File not found: $1"
	else
		printf "BYTES = "
		wc -c $1 | cut  -d' ' -f1
		printf "LINES = "
		wc -l $1 | cut  -d' ' -f1
		printf "WORDS = "
		wc -w $1 | cut  -d' ' -f1

		printf "\nFIRST 5 LINES:\n"
		head -n 5 $1				#default is to display 10 lines
		#sed -n 1,10p $1			#Another way to display line 1 to 10

		printf "\nLAST 5 LINES:\n"
		tail -n 5 $1				#default is to display 10 lines
	fi
}
function search()
{
	if [ $# -lt 2 ]; then
		printf "purpose: search text inside a file\n"
		printf "usage: search [regex] [filenameS]\n"
	else
		for file in $@
		do
			if [ -f $file ]; then
				#i=ignore Ucase/LCase, c=count, R=recursive in all files/directories
				total_counter=$(egrep -iRc $1 $file | grep -Eo '[0-9.]{1,3}$')

				if [ $total_counter -gt 0 ]; then
					printf "File: ${file}\t: ${total_counter} times\n"

					#i=ignore Ucase/LCase, n=line number, -T=format the output using TAB between ":", n=display the line number
					if isWindows; then
						egrep -iTRn --color "$1" $2					#nicer output format
					else
						egrep -iRn --color "$1" $2 | awk -F: '{printf ("Line:"$2" : "$3"\n")}'
					fi
					printf "\n"
				fi
			fi
		done
	fi
}
function searchCount()
{
	if [ $# -lt 2 ]; then
		printf "purpose: search text inside a file\n"
		printf "usage: searchCount [regex] [filenameS]\n"
	else
		for file in $@
		do
			if [ -f $file ]; then
				#i=ignore Ucase/LCase, c=count, R=recursive in all files/directories
				total_counter=$(egrep -iRc $1 $file | grep -Eo '[0-9.]{1,3}$')

				if [ $total_counter -gt 0 ]; then
					printf "File: ${file}\t: ${total_counter} times\n"

					printf "Counter [regex]:\n"

					#-T=format the output using TAB between ":"
					#sort=sort result, uniq -c=count the CONSEQUENTIAL identical nb of lines, sort -rn=sort in reverse order and give a number
					if isWindows; then
						egrep -iTR "$1" $file |sort|uniq -c|sort -rn
					else
						egrep -iR "$1" $file |sort|uniq -c|sort -rn | awk -F: '{printf ("Count:"$2" : "$3"\n")}'
					fi
					printf "\n"
				fi
			fi
		done
	fi
}

function dos2unix()
{
	if [ $# -lt 1 ]; then
		#http://stackoverflow.com/questions/11616835/r-command-not-found-bashrc-bash-profile
		printf "purpose: Remove trailing r character directly from the input file"
		printf "usage: dos2unix [filenameS]\n"
	else
		sed -i 's/\r$//' $1
	fi
}

if isWindows; then
	#Work only in Windows with Cygwin
	alias open='cygstart'
elif isOSX; then
	#Work only in MAC: Open Sublime from the command line
	alias subl="open -a Sublime\ Text.app" $@
fi

# ============================================================================
# Shell colors
# SOURCE: http://geoff.greer.fm/lscolors/
# ============================================================================

if isWindows; then
	LS_COLORS='no=00:di=33;01:tw=33;01:ow=33;01'
	export LS_COLORS
elif isOSX; then
	export CLICOLOR=1
	LS_COLORS='no=00:di=33;01:tw=33;01:ow=33;01'
	export LS_COLORS
elif isLinux; then
	LS_COLORS='no=00:di=33;01:tw=33;01:ow=33;01'
	export LS_COLORS
fi

# ============================================================================
# Others
# ============================================================================

alias cls="clear"
alias ver="uname -a"
alias wmic="df -h"					#"wmic logicaldisk get size,freespace,caption" = "df -h"
									#"doskey /history" = "history"

# ============================================================================
# Ubuntu only
# ============================================================================

alias update="sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade && sudo apt clean && sudo apt autoremove"

commands
