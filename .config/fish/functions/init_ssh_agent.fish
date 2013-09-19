function init_ssh_agent -d (N_ "Initialize ssh-agent and set env vars")
    keychain id_rsa
    set -x SSH_AUTH_SOCK /dev/null
    set -x SSH_AGENT_PID 0
    . ~/.keychain/(hostname)-fish
end
