# This part of code is deprecated since I prefered to let bash
# deal with the environmement variable and the login shell
if begin test "$TERM" = "linux"; and status --is-login; end
    if not test "$USER" = "cecile"
        set -x PATH /home/cecile/bin $PATH
    end
    set -x PATH ~/bin ~/.local/bin $PATH /usr/local/sbin /usr/sbin /opt/android-sdk/platform-tools /usr/bin/vendor_perl /usr/bin/core_perl
    set -x PYTHONDONTWRITEBYTECODE 1
    set -x EDITOR /usr/bin/vim
    set -x XBMC_HOST openelec
    echo "Environment variables set"
end

if status --is-interactive

    init_ssh_agent

    if test "$TERM" = "linux"
        function x
            set tty (tty | grep -o '[0-9]\+')
            set vt (printf "vt%02d" $tty)
            xinit -- :$tty $vt >/dev/null ^/dev/null
        end
        set -x DISPLAY
        echo -n "Starting graphical session, press return to cancel... "
        if sh -c "read -s -t 1"
            echo canceled
        else
            x
            echo done
        end
    else
        function ff
            firefox $args >/dev/null ^/dev/null &
        end
        function gajim
            sh -c (which gajim) $args >/dev/null ^/dev/null &
        end
    end

    function fish_prompt -d "Write out the prompt"
        printf '[%s] %s%s%s> ' (date +'%H:%M:%S') (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
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

    # shell ones
    alias ls 'ls --color=auto'
    alias ls 'ls --color=auto -h'
    alias ll 'ls -l --color=auto'
    alias rm 'rm -iv'
    alias mv 'mv -iv'
    alias cp 'cp -ipv'
    # how to make my videos fits well my stupid tv
    set w 1280
    set h 720
    set bx 31
    set by 17
    alias mplayer "mplayer -geometry "(expr $w - 2 \* $bx)"x"(expr $h - 2 \* $by)"+$bx+$by"

    # programs
    alias lin "linphonec 2> /dev/null"

    alias g git

    alias b bzr
    alias b-find "bzr log --line | grep"

    echo "Aliases loaded"

    if fuser 5433/tcp >&-
        set -x PGHOST localhost
        set -x PGPORT 5433
        echo "PostgreSQL default connection set to $PGHOST:$PGPORT"
    else
        set -e PGHOST
        set -e PGPORT
    end
end
