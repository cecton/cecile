# Check for an interactive session
#[ -z "$PS1" ] && return
[ -z "${-##*i*}" -a -n "$PS1" ] || return

[ -z "$PLATFORM" -a -f ~/.exports ] && . ~/.exports

[ -z "${0##-*}" -a -x ~/.setup ] && ~/.setup

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

tty=`tty`

# starting SSH agent
if [ -x "`which ssh-agent 2> /dev/null`" ]; then
	if ! [ -e /tmp/ssh-agent.$USER ]; then
		ssh-agent | grep -v '^echo' > /tmp/ssh-agent.$USER
	fi
	. /tmp/ssh-agent.$USER
fi

if [ "$PLATFORM" == Linux ] && [ "$parent_name" == login ] && [ "$tty" == /dev/tty4 ]; then
	# automatically start graphical session (X.org) with container
	if [ "$USER" == deck ]; then
		echo -n "Starting X.org graphical session with container, press return to cancel... "
		read -s -t 2 answer
		if [ $? -eq 0 ]; then
			echo canceled
		else
			echo done
			start-deck
		fi
	fi
fi

if [ "$PLATFORM" == Linux ] && [ "$parent_name" == login ] && [ "$tty" == /dev/tty1 ]; then
	# automatically start graphical session
	lsmod | grep -q nvidia
	if [ $? -ne 0 ] && [ -x "`which sway 2> /dev/null`" ]; then
		echo -n "Starting sway, press return to cancel... "
		read -s -t 2 answer
		if [ $? -eq 0 ]; then
			echo canceled
		else
			sway
			echo done
		fi
	fi

	# automatically start graphical session (X.org)
	if [ -x "`which startx 2> /dev/null`" ]; then
		echo -n "Starting X.org graphical session, press return to cancel... "
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
			setfont ter-224b
		fi
	fi
fi

## workaround for handling TERM variable in multiple tmux sessions properly from http://sourceforge.net/p/tmux/mailman/message/32751663/ by Nicholas Marriott
if [ -n "$TMUX" ];then
	case $(tmux showenv TERM 2>/dev/null) in
		TERM=*256color|TERM=fbterm)
		TERM=screen-256color ;;
		*)
		TERM=screen
	esac
	export TERM
fi

# exec fish depending who's the parent
if which fish >/dev/null && [ "$parent_name" != fish ] && [ "$parent_name" != mc ]; then
	# NOTE: fix annoying fish bug with history file
	# 	https://github.com/fish-shell/fish-shell/issues/10300
	history_file=~/.local/share/fish/fish_history
	/bin/cp --reflink=always -f "$history_file" "${history_file}.backup-daily-"$(( $(date +%s) / 86400 % 30 ))
	/bin/cp --reflink=always -f "$history_file" "${history_file}.backup-2h-"$(( $(date +%s) / 7200 % 30 ))

	if output=$(tr -d '\000' < $history_file); then
	  printf '%s' "$output" > "$history_file.new" && /bin/mv "$history_file" "$history_file.old" && /bin/mv "$history_file.new" "$history_file"
	else
	  echo "Error: Failed to clean fish history" >&2
	fi
	exec fish
fi
