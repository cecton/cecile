# Check for an interactive session
#[ -z "$PS1" ] && return
[ -z "${-##*i*}" -a -n "$PS1" ] || return

[ "$USER" == cecile ] || export PATH=/home/cecile/bin:$PATH
[ -d $HOME/bin ] && export PATH=$HOME/bin:$PATH

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

export EDITOR=/usr/bin/vim

export HISTCONTROL=ignoreboth:erasedups

export WINEARCH=win32
export WINETRICKS_CONTINUE_DOWNLOAD=1

export PYTHONDONTWRITEBYTECODE=1

export XBMC_HOST=openelec

alias mv='mv -iv'
alias rm='rm -iv'
alias cp='cp -iv'

manpod() {
	local f=`mktemp`;
	pod2man "$1" > $f && man $f && rm -f $f
}

#alias x="xinit -- :8 &> /dev/null"
function x {
    tty=`tty`
    tty=`printf "vt%02d" ${tty#*tty}`
    startx -- $tty
}
alias je="echo 'Hey! Dvorak keyboard here!'; cd"
alias underscan="xrandr --output HDMI-0 --set underscan"
alias vborder='xrandr --output HDMI-0 --set "underscan vborder"'
alias hborder='xrandr --output HDMI-0 --set "underscan hborder"'

parent_want_fish=(st login tmux su gnome-terminal)
parent_name=`ps ho comm -p $PPID`
[ "${parent_want_fish[*]#$parent_name}" != "${parent_want_fish[*]}" -a ! -e /tmp/$USER-nofish ] && exec fish
