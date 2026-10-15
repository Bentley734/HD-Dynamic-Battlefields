local M=assert(loadfile(root..'/lib/adapters/gen1_context.lua'))()
local calls=0
local game,options={}, {hooked=true}
local marker={native=true}
local Battle={newWild=function(g,species,level,opts,tail)
 assert(g==game and species=='MAGIKARP'and level==5 and tail=='unchanged')
 calls=calls+1;return marker
end}
local fishing=M.install(Battle)
assert(Battle.newWild(game,'MAGIKARP',5,options,'unchanged')==marker)
assert(fishing(marker)and marker.native and marker.hooked==nil)
options.hooked=false;assert(fishing(marker),'Capture must survive later options mutation')
local previous=marker;marker={native=true}
assert(Battle.newWild(game,'MAGIKARP',5,nil,'unchanged')==marker)
assert(not fishing(marker)and fishing(previous)and calls==2)
marker=nil;assert(Battle.newWild(game,'MAGIKARP',5,nil,'unchanged')==nil)
assert(not fishing({}))
print('PASS fishing encounter capture preserves native battle identity/arguments and leaves native state untouched')
