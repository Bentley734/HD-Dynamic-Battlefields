function love.conf(t)
 local w,h=(os.getenv('HDB_SIZE')or'1280x720'):match('^(%d+)x(%d+)$')
 t.identity='hd-frlg-compat-probe';t.window.visible=false;t.window.width=tonumber(w);t.window.height=tonumber(h);t.audio=false;t.console=false
end
