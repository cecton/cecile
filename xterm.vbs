set ws=wscript.createobject("wscript.shell")
ws.run "C:\Windows\System32\bash.exe -c 'su -l cecile -c ""cd; (DISPLAY=:0 xrdb -load .Xresources && DISPLAY=:0 exec xterm -e tmux) &> /tmp/xterm.log""'",0
