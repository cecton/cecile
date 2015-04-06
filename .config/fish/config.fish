if status --is-interactive

	init_ssh_agent

	# starting on a linux console
	if test "$parent_name" = "login"
		# TODO temporary not working
		function x
			set tty (tty | grep -o '[0-9]\+')
			set vt (printf "vt%02d" $tty)
			sh -c "exec xinit -- :$tty $vt &>>/tmp/dwm-session-\${UID}.log"
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
	alias ls 'ls --color=auto -h'
	alias ll 'ls -l'
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
	alias t tig
	alias d docker

	# shortcuts
	function repo-log
		echo
		git log --oneline ^&-
		commandline -f repaint
	end

	function repo-diff-cached
		set old_pwd $PWD
		while test $PWD != "/"
			if test -d ".git"
				git diff --cached ^&-
				commandline -f repaint
				break
			end
			cd ..
		end
		cd $old_pwd
	end

	function repo-diff
		set old_pwd $PWD
		while test $PWD != "/"
			if test -d ".git"
				git diff ^&-
				commandline -f repaint
				break
			end
			cd ..
		end
		cd $old_pwd
	end

	function repo-status
		echo
		git status ^&-
		commandline -f repaint
	end

	function repo-commit
		echo
		git commit ^&-
		commandline -f repaint
	end

	function repo-suffix
		set old_pwd $PWD
		while test $PWD != "/"
			if test -d ".git"
				git rev-parse --abbrev-ref HEAD | sed 's/^/ /'
				break
			end
			cd ..
		end
		cd $old_pwd
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
		printf '[%s] [%s] %s%s%s%s%s > ' \
			$status \
			(date -u +'%H:%M:%S') \
			(set_color green) (prompt_pwd) \
			(set_color purple) \
			(repo-suffix) \
			(set_color normal)
	end

end
