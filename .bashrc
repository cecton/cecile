# Check for an interactive session
#[ -z "$PS1" ] && return
[ -z "${-##*i*}" -a -n "$PS1" ] || return

[ "$USER" == cecile ] || export PATH=/home/cecile/bin:$PATH
[ -d $HOME/bin ] && export PATH=$HOME/bin:$PATH

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

export EDITOR=/usr/bin/vim
[ "$USER" == cecile ] && export BROWSER=firefox || export BROWSER=chromium

export HISTCONTROL=ignoreboth:erasedups

export WINEARCH=win32
export WINETRICKS_CONTINUE_DOWNLOAD=1

export PYTHONDONTWRITEBYTECODE=1

export XBMC_HOST=openelec

alias mv='mv -iv'
alias rm='rm -iv'
alias cp='cp -iv'

#alias x="xinit -- :8 &> /dev/null"
function x {
	tty=`tty | grep -o '[0-9]\+'`
	vt=`printf "vt%02d" $tty`
	startx -- :$tty $vt &> /dev/null
}
alias je="echo 'Hey! Dvorak keyboard here!'; cd"
alias underscan="xrandr --output HDMI-0 --set underscan"
alias vborder='xrandr --output HDMI-0 --set "underscan vborder"'
alias hborder='xrandr --output HDMI-0 --set "underscan hborder"'

# disable speaker
setterm -blength 0

# get the parent process name
parent_name=`ps ho comm -p $PPID`

# automatically start graphical session
if [ "$parent_name" == login ]; then
	echo -n "Starting graphical session, press return to cancel... "
	read -s -t 1 answer
	if [ $? -eq 0 ] && [ "$answer" != x ]; then
		echo canceled
	else
		x
		echo done
	fi
fi

# exec fish depending who's the parent
parent_want_fish=(st login tmux su)
[ "${parent_want_fish[*]#$parent_name}" != "${parent_want_fish[*]}" -a ! -e /tmp/$USER-nofish ] && exec fish
