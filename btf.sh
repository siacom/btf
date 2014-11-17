#!/bin/bash
# Author: Si
# Title: Bring To Front
# Usage: Run script with 2 arguments (2nd optional)
# first argument is the name of the process to be executed e.g. Firefox
# second is options for that process, e.g. --new-window

pid=`pgrep "$1"`
winID=`wmctrl -lp | grep "$pid" | tail -1 | cut -f 1 -d " "`
SCRIPT=$(readlink -f $0)

auth()
{
	pwd_auth=$(zenity --password --title=Authentication --timeout=5)
	case $? in
		1 )
			echo "cancelled or timeout reached"
			exit 1
			;;
		0 )
			check_pass $pwd_auth
			return 0
			;;
	esac
}

check_pass()
{
	if ( ! echo $1 | sudo -S cat /dev/null ) 2>/dev/null ; then
		( zenity --warning --text="You entered an incorrect password, please try again!" )
		auth
	fi
}

install_wmctrl()
{
	( sudo apt-get install -y wmctrl ) > /dev/null
}

install_btf()
{
	sudo rm -rf /usr/local/bin/btf
	sudo ln -s $SCRIPT /usr/local/bin/btf
	sudo chmod +x /usr/local/bin/btf
}

check_install()
{
	if auth = 1 ; then
		for install in $1; do
			install_$install
		done
	fi
}

check_dependencies()
{
	dep_array=( btf wmctrl )
	for i in "${dep_array[@]}"
	do
		if ( ! command -v $i ) > /dev/null ; then
			req_dep+=($i)
		fi
	done

	if [ -z "${req_dep[@]}" ] ; then
		echo ""
	else
		if ( ! zenity --question --title=Installation --text="One or more dependency is required." ) ; then
			exit 0
		else
			check_install ${req_dep[@]}
		fi
	fi
}

help_info()
{
	clear
	echo -e "  Help Information"
	echo -e "  ================\n"
	echo -e "  Usage: Run script with 2 arguments (2nd optional)"
	echo -e "  first argument is the name of the process to be executed e.g. Firefox"
	echo -e "  second is options for that process, e.g. --new-window\n"
	echo -e "  A working example should look like this: btf firefox --new-window\n"
}

get_input()
{
	case $1 in 
		"" )
			( zenity --warning --title=Program Launch --text="You didn't specify the application to be loaded. e.g. btf firefox" )
			help_info
			exit 0			
			;;
		"--help" )
			help_info
			exit 0
			;;
	esac

	if ( ! $1 $2 ) ; then
		echo "command failure"
		exit 0
	fi
}

get_winid()
{
	active_winid=`wmctrl -lp | grep "$pid" | tail -1 | cut -f 1 -d " "`
}

loop()
{
	while [[ $winID = $active_winid ]] ; do
		get_winid
	done
	wmctrl -ia $active_winid
	exit 0
}

check_dependencies
get_input $1 $2
get_winid
loop