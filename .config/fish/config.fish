if status --is-interactive

	function fish_prompt -d "Write out the prompt"
		printf '[%s] %s%s%s> ' (date +'%H:%M:%S') (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
	end

	init_ssh_agent

	# starting on a linux console
	if test "$TERM" = "linux"
		function x
			set tty (tty | grep -o '[0-9]\+')
			set vt (printf "vt%02d" $tty)
			xinit -- :$tty $vt ^&- >&-
		end
		set -x DISPLAY
	# starting on a graphical session
	else
		function ff
			firefox $args ^&- >&- &
		end
		function gajim
			sh -c (which gajim) $args ^&- >&- &
		end
		# how to make my videos fits well on my stupid tv
		set w 1280
		set h 720
		set bx 31
		set by 17
		alias mplayer "mplayer -geometry "(expr $w - 2 \* $bx)"x"(expr $h - 2 \* $by)"+$bx+$by"
	end

	function sshterm
		infocmp $TERM | ssh $argv "mkdir -p ~/.terminfo && cat >/tmp/ti && tic /tmp/ti"
	end

	function sshx -a address display
		set -x DISPLAY "$address:$display";ip addr | grep -o 'inet6\? [^:][^ /]\+' | sed 's/^/+/;s/ /:/' | xargs ssh $address DISPLAY=":$display" xhost
	end

	function sshallow
		cat ~/.ssh/id_rsa.pub | ssh $argv "mkdir ~/.ssh; cat - >> ~/.ssh/authorized_keys"
	end

	# funny ones
	alias je "echo 'Hey! Dvorak keyboard here!'; cd"

	# shell builtins
	alias ls 'ls --color=auto'
	alias ls 'ls --color=auto -h'
	alias ll 'ls -l --color=auto'
	alias rm 'rm -iv'
	alias mv 'mv -iv'
	alias cp 'cp -ipv'

	# tools
	function pod2man
		mktemp | set f
		and command pod2man $args > $f
		and man $f
		and rm -f $f
	end

	# programs
	alias lin "linphonec ^&-"
	alias g git
	alias b bzr
	alias b-find "bzr log --line -n0 | grep"

	# if port 5433 is opened, prefer PostgreSQL to use it
	if fuser 5433/tcp >&-
		set -x PGHOST localhost
		set -x PGPORT 5433
		echo "PostgreSQL default connection set to $PGHOST:$PGPORT"
	# otherwise, erase the variables
	else
		set -e PGHOST
		set -e PGPORT
	end

end
