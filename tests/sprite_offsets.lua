local S=assert(loadfile(root..'/lib/sprite_offsets.lua'))()
local data={global={player={pokemon_x=2/160,pokemon_y=-3/144}},aspects={['16:9']={player={pokemon_x=4/160}}},compositions={special={player={pokemon_y=5/144}}}}
local x,y=S.resolve(data,'16:9','special','player');assert(x==4 and y==5)
x,y=S.resolve(data,'4:3','other','player');assert(x==2 and y==-3)
x,y=S.resolve(data,'16:9','special','opponent');assert(x==0 and y==0)
local depth,tx,ty,calls=0,0,0,0
local G={getStackDepth=function()return depth end,push=function()depth=depth+1 end,pop=function()depth=depth-1 end,translate=function(a,b)tx,ty=a,b end}
local fail=false
local B={drawBattlerPic=function(self,battler,arg)calls=calls+1;assert(arg==17);if fail then error('draw failed')end;return 'native'end}
assert(S.install(B,G,function(side)return side=='player'and 2 or 0,0 end))
assert(B:drawBattlerPic({isPlayer=true},17)=='native'and tx==2 and ty==0 and depth==0)
fail=true;assert(not pcall(B.drawBattlerPic,B,{isPlayer=true},17));assert(depth==0)
assert(data.global.player.pokemon_x==2/160)
print('PASS sprite offsets: scoped precedence, integer native pixels, untouched arguments/metadata and graphics restoration on failure')
