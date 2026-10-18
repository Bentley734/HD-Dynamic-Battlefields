function love.conf(t)
 t.identity='hd-rse-native-fixture'
 t.window.visible=false
 local w,h=(os.getenv('HDB_SIZE')or'1280x720'):match('^(%d+)x(%d+)$')
 t.window.width=tonumber(w);t.window.height=tonumber(h)
 t.modules.audio=false
end
