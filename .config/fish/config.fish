if status --is-interactive

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
			firefox $args ^/dev/null >/dev/null &
		end
		function gajim
			sh -c (which gajim) $args ^/dev/null >/dev/null &
		end
		# how to make my videos fits well on my stupid tv
		set w 1280
		set h 720
		set bx 31
		set by 17
		# Use dsize to expand at most to the display resolution given while
		# keeping aspect. Then use expand=:::::16/9 to stretch the drawable
		# canvas to a 16/9 resolution.
		alias mplayer "mplayer -vf dsize="(expr $w - 2 \* $bx)":"(expr $h - 2 \* $by)":0,expand=:::::16/9 -geometry "(expr $w - 2 \* $bx)"x"(expr $h - 2 \* $by)"+$bx+$by"
		# NOTE: Using geometry argument stretch the picture without keeping
		#       aspect on some systems.
		# NOTE: expand permit the subtitles to be drawn on it but the
		#       width/height values are calculated from the picture source and
		#       doesn't give the expected result: expand=1280 doesn't display a
		#       window of 1280px but probably much more
		# NOTE: -subpos argument is needed when using expand but *not* if you
		#       specify only the aspect
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

	# shortcuts
	function repo-log
		echo
		git log --oneline ^&-
		or bzr log --line ^&- | less -sFX
		commandline -f repaint
	end

	function repo-diff-cached
		git diff --cached ^&-
		or bzr cdiff ^&- | less -sFXR
		or bzr diff ^&- | less -sFX
		commandline -f repaint
	end

	function repo-diff
		git diff ^&-
		commandline -f repaint
	end

	function repo-status
		echo
		git status ^&-
		or bzr status ^&- | less -sFX
		commandline -f repaint
	end

	function repo-commit
		echo
		git commit ^&-
		or bzr commit ^&-
		commandline -f repaint
	end

	function repo-suffix
		perl -we 'use Cwd;while(getcwd ne "/"){do{open IN,".bzr/branch/location" and do {print " $1" if <IN>=~m{([^/]+)/*$}}; last} if -e ".bzr/branch/location";chdir ".."}'
	end

	# binds
	function fish_user_key_bindings
		# F8
		bind [19~ repo-log
		# F9
		bind [20~ repo-status
		# F10
		bind [21~ repo-diff
		# F11
		bind [23~ repo-diff-cached
		# F12
		bind [24~ repo-commit
	end

	# prompt
	function fish_prompt -d "Write out the prompt"
		printf '[%s] %s%s%s%s%s > ' \
			(date +'%H:%M:%S') \
			(set_color green) (prompt_pwd) \
			(set_color purple) \
			(repo-suffix) \
			(set_color normal)
	end

end
