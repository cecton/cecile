# Check for an interactive session
#[ -z "$PS1" ] && return
[ -z "${-##*i*}" -a -n "$PS1" ] || return

# export environment variables if login shell
[ -z "${0##-*}" ] && [ -f ~/.exports ] && . ~/.exports

if [ ! -e /tmp/setup-$USER ]; then
	touch /tmp/setup-$USER
	[ -z "${0##-*}" -a -x ~/.setup-term ] && ~/.setup-term
	[ -z "${0##-*}" -a -x ~/.setup-Xorg -a -x "`which startx 2>/dev/null`" ] && ~/.setup-Xorg
	rm /tmp/setup-$USER
fi

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

if [ "$PLATFORM" == Linux ] && [ "$parent_name" == login ]; then
	# automatically start graphical session
	if [ -x "`which startx`" -a -x ~/bin/dwm -a -x ~/bin/st ]; then
		echo -n "Starting graphical session, press return to cancel... "
		read -s -t 2 answer
		if [ $? -eq 0 ]; then
			echo canceled
		else
			startx
			echo done
		fi
	fi

	# ...or fbterm if available
	fbterm=`which fbterm 2>/dev/null`
	groups | grep video >/dev/null
	if [ $? == 0 -a -x "$fbterm" -a ! -f /tmp/$USER-nofbterm ]; then
		# starts fbterm
		exec fbtermwrap
	else
		# change console font to terminus
		if [ -e /usr/share/consolefonts/Uni2-Terminus22x11.psf.gz ]; then
			setfont Uni2-TerminusBold22x11
		else
			setfont ter-122b
		fi
	fi
fi

# if using X.org or on OSX
if [ -n "$DISPLAY" ] || [ "$PLATFORM" == Darwin ]; then
	[ "$PLATFORM" == Linux ] && eval "`dircolors -b ~/.config/dircolors.ansi-dark`"
	# switch TERM to screen-256color if executed in tmux in X
	[ "$parent_name" == tmux ] && export TERM=screen-256color
fi

# exec fish depending who's the parent
if which fish >/dev/null && [ "$parent_name" != fish ]; then
	exec fish
fi
