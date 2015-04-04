# Check for an interactive session
#[ -z "$PS1" ] && return
[ -z "${-##*i*}" -a -n "$PS1" ] || return

[ -z "${0##-*}" -a -x ~/.setup-Xorg -a -x "`which startx`" ] && ~/.setup-Xorg

PS1='[\u@\h \W]\$ '

alias ls='ls --color=auto'
alias ll='ls -lh'
alias mv='mv -iv'
alias rm='rm -iv'
alias cp='cp -iv'
alias je="echo 'Hey! Dvorak keyboard here!'; cd"

# disable speaker
[ "$TERM" == linux ] && setterm -blength 0

# get the parent process name
parent_name=`ps o comm -p $PPID | awk 'NR>1'`

# export environment variables if login shell
[ -z "${0##-*}" ] && [ -f ~/.exports ] && . ~/.exports

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

# switch TERM to screen-256color if executed in tmux in X
[ "$parent_name" == tmux -a -n "$DISPLAY" ] && export TERM=screen-256color

# exec fish depending who's the parent
[ "$parent_name" != fish ] && exec fish
