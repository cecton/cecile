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

export LC_TIME="en_GB.utf8"

export PERL_MB_OPT="--install_base \"$HOME/perl5\""
export PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"
export PERL5LIB="$HOME/perl5/lib/perl5"

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
parent_name=`ps ho comm -p $PPID`

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
	if [ $? == 0 ] && [ -x "$fbterm" ]; then
		# starts fbterm
		exec fbtermwrap
	else
		# change console font to terminus
		setfont ter-116n
	fi
fi

if [ "$parent_name" == tmux ]; then
	if [ -z "$DISPLAY" ]; then
		export TERM=screen
	fi
fi

# exec fish depending who's the parent
parent_want_fish=(st login tmux su fbterm)
[ "${parent_want_fish[*]#$parent_name}" != "${parent_want_fish[*]}" -a ! -e /tmp/$USER-nofish ] && exec fish
