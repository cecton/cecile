# Check for an interactive session
#[ -z "$PS1" ] && return
[ -z "${-##*i*}" -a -n "$PS1" ] || return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

alias mv='mv -iv'
alias rm='rm -iv'
alias cp='cp -iv'

alias je="echo 'Hey! Dvorak keyboard here!'; cd"
alias underscan="xrandr --output HDMI-0 --set underscan"
alias vborder='xrandr --output HDMI-0 --set "underscan vborder"'
alias hborder='xrandr --output HDMI-0 --set "underscan hborder"'

# disable speaker
if [ "$TERM" == linux ]; then
	setterm -blength 0
fi

# get the parent process name
parent_name=`ps o comm -p $PPID | awk 'NR>1'`

[ -z "${0##-*}" ] && [ -f ~/.exports ] && echo "Exports loaded" && . ~/.exports

# automatically start graphical session
if [ "$parent_name" == login ]; then
	echo -n "Starting graphical session, press return to cancel... "
	read -s -t 2 answer
	if [ $? -eq 0 ]; then
		echo canceled
	else
		startx
		echo done
	fi

	fbterm=`which fbterm 2>/dev/null`
	groups | grep video >/dev/null
	if [ $? == 0 -a -x "$fbterm" -a ! -f /tmp/$USER-nofbterm ]; then
		# starts fbterm
		exec fbtermwrap
	else
		# change console font to terminus
		setfont ter-116n
	fi
fi

[ "$parent_name" == tmux -a -n "$DISPLAY" ] && export TERM=screen-256color

# exec fish depending who's the parent
[ "$parent_name" != fish ] && exec fish
