set ws=wscript.createobject("wscript.shell")
ws.run "C:\Windows\System32\bash.exe -c 'cd; (DISPLAY=:0 xrdb -load .Xresources && DISPLAY=:0 exec xterm) &> /tmp/xterm.log'",0
