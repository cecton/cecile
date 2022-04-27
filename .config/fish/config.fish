if status --is-interactive

	function sshterm
		infocmp $TERM | ssh $argv "mkdir -p ~/.terminfo && cat >/tmp/ti && tic /tmp/ti"
	end

	function sshx -a address display
		set -x DISPLAY "$address:$display";ip addr | grep -o 'inet6\? [^:][^ /]\+' | sed 's/^/+/;s/ /:/' | xargs ssh $address DISPLAY=":$display" xhost
	end

	function sshallow
		cat ~/.ssh/id_rsa.pub | ssh $argv "mkdir -p ~/.ssh; cat - >> ~/.ssh/authorized_keys"
	end

	# funny ones
	alias je "echo 'Hey! Dvorak keyboard here!'; cd"

	# shell builtins
	if test "$PLATFORM" = "Darwin"
		alias ls 'ls -G -h'
	else
		alias ls 'ls --color=auto -h'
	end
	if which exa &>/dev/null
		alias ls 'exa'
		alias tree 'exa -T'
	end
	if which bat &>/dev/null
		alias cat 'bat --tabs=0'
	end
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
	alias g git
	if which cargo-git &>/dev/null
		alias cg "cargo git"
	end
	alias p pijul
	alias ff 'git pull --ff-only'
	alias fff 'git fetch --all -p; and git pull --ff-only'
	alias am 'git commit --amend'
	alias amm 'env EDITOR=true git commit --amend'
	alias fixup 'git commit --fixup'
	alias t tig
	alias d docker
	alias dc 'docker compose'
	alias dip "docker inspect -f '{{ .NetworkSettings.IPAddress }}'"
	alias c cargo
	alias nw 'emacs -nw'

	# nvm
	set -U fish_user_paths

	function wip
		git commit -m WIP
	end

	function cleanup
		git commit -m CLEANUP
	end

	function mkcd
		mkdir -p $argv
		cd $argv
	end

	# shortcuts
	function repo-add
		set old_pwd $PWD
		while test $PWD != "/"
			if test -e ".git"
				echo
				if test -e Cargo.lock && which cargo-git &>/dev/null
					cargo git add -p
				else
					git add -p
				end
				commandline -f repaint
				break
			end
			cd ..
		end
		cd $old_pwd
	end

	function repo-log
		echo
		tig; or git log --oneline
		commandline -f repaint
	end

	function repo-diff-cached
		set old_pwd $PWD
		while test $PWD != "/"
			if test -e ".git"
				if test -e Cargo.lock && which cargo-git &>/dev/null
					cargo git diff --cached
				else
					git diff --cached
				end
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
			if test -e ".git"
				if test -e Cargo.lock && which cargo-git &>/dev/null
					cargo git diff
				else
					git diff
				end
				commandline -f repaint
				break
			end
			cd ..
		end
		cd $old_pwd
	end

	function repo-status
		echo
		git status
		commandline -f repaint
	end

	function repo-commit
		echo
		git commit
		commandline -f repaint
	end

	function repo-suffix
		set old_pwd $PWD
		while test $PWD != "/"
			if test -e ".git"
				set rev (git rev-parse --abbrev-ref HEAD 2>/dev/null)
				if test (basename $old_pwd) != $rev -a \( $PWD != $HOME -o $rev != main \)
					echo " $rev"
				end
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
	if which git &>/dev/null
		function fish_prompt -d "Write out the prompt"
			printf '[%s] [%s] %s%s%s%s%s > ' \
				$status \
				(date -u +'%H:%M:%S') \
				(set_color green) (prompt_pwd) \
				(set_color purple) \
				(repo-suffix) \
				(set_color normal)
		end
	else
		function fish_prompt -d "Write out the prompt"
			printf '[%s] [%s] %s%s%s%s%s > ' \
				$status \
				(date -u +'%H:%M:%S') \
				(set_color green) (prompt_pwd) \
				(set_color normal)
		end
	end

	# default is Neo ViM if available
	if which nvim &>/dev/null
		alias vi nvim
	else
		# default is ViM if available
		if which vim &>/dev/null
			alias vi vim
		end
	end

end
