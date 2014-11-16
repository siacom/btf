#!/bin/bash
# Author: Si
# Title: Bring To Front
# Usage: Run script with 2 arguments (2nd optional)
# first argument is the name of the process to be executed e.g. Firefox
# second is options for that process, e.g. --new-window
count=0

auth()
{
	pwd_auth=$(zenity --password --title=Authentication)
	if ( ! echo $pwd_auth | sudo -S cat /dev/null ) 2>/dev/null ; then
		# ( zenity --warning --text="false" )
		return 1
	else
		# ( zenity --warning --text="true" )
		return 0
	fi
}

check_install()
{
	if ( ! $(auth) ) ; then
		if [[ $pwd_auth = "" ]] ; then
			exit 0
		else
			( zenity --warning --text="You entered an incorrect password, please try again!" )
			check_install
		fi				
	else
		( sudo apt-get install -y wmctrl ) > /dev/null
		sudo -K
		return 0
	fi
}

check_dependencies()
{
	if ( ! command -v wmctrl ) > /dev/null ; then
		if ( ! zenity --question --title=Installation --text="A dependency is required before this script can run." ) ; then
			exit 0
		else
			check_install
		fi
	fi
}

check_dependencies

case $1 in
	"install" ) echo "not implemented yet.";; # get path script is running from and cp it to /usr/local/bin
	"" )
		( zenity --warning --title=Program Launch --text="You didn't specify the application to be loaded. e.g. btf firefox" )
		exit 0;;
esac

pid=`pgrep "$1"`
winID=`wmctrl -lp | grep $pid | tail -1 | cut -f 1 -d " "`

if ( ! $1 $2 ) ; then
	exit 0
fi

get_winid()
{
	active_winid=$(wmctrl -lp | grep "$pid" | tail -1 | cut -f 1 -d " ")
}

loop()
{
	while [[ $winID = $active_winid ]] ; do
		get_winid
	done
}

get_winid
loop
wmctrl -ia $active_winid