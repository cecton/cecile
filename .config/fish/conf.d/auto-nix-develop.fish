if status --is-interactive && type -q nix
	function __find_flake_root
		set -l d (pwd)
		while test "$d" != "/"
			if test -f "$d/flake.nix"
				echo $d
				return 0
			end
			set d (dirname "$d")
		end
		return 1
	end

	function __auto_nix_develop --on-variable PWD
		set -q AUTO_NIX_DISABLE; and return
		set -l root (__find_flake_root); or return
		test -f "$root/.auto-nix"; or return
		status is-command-substitution; and return

		# Prevent entering the same flake twice consecutively (allow recursion otherwise)
		if set -q __AUTO_NIX_LAST_ROOT
			test "$__AUTO_NIX_LAST_ROOT" = "$root"; and return
		end

		echo "Entering nix develop environment..."
		history merge
		history save
		env __AUTO_NIX_LAST_ROOT="$root" nix develop "$root" -c fish
		echo "Exiting nix develop environment..."
	end

	# NOTE: in case the shell starts on it
	__auto_nix_develop
end
