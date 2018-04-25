set ws=wscript.createobject("wscript.shell")
ws.run "C:\Windows\System32\bash.exe -c 'cd; pgrep sshd || sudo -H /usr/sbin/sshd -o UsePrivilegeSeparation=no -D'",0
