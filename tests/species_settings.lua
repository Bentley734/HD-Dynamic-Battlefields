package.loaded['src.core.GameVersion']={get=function()return'red'end}
local P=assert(loadfile(root..'/lib/perspective.lua'))()
local opened,data
data={global={player={pokemon_x=3/160}}}
local mod={exports={getAdjustments=function()return data end,
 applyAdjustments=function(value)local ok,err=P.validateAdjustments(value);assert(ok,err);data=value;return true end,
 diagnostics=function()return{playerSpecies='SQUIRTLE',opponentSpecies='RATTATA'}end}}
local function open(_,rows)opened=rows end
local function group(id,label,rows)return{id=id,label=label,activate=function(game)open(game,rows)end}end
local game={data={pokemon={SQUIRTLE={name='Squirtle'},PIKACHU={name='Pikachu'},RATTATA={name='Rattata'}}},stack={pop=function()end}}
local Catalog=assert(loadfile(root..'/lib/species_catalog.lua'))()
mod.exports.getSpeciesChoices=function()return Catalog.collect(nil,game.data.pokemon)end
local page=assert(loadfile(root..'/lib/species_settings.lua'))()(mod,open,group)
page.activate(game);local sides=opened
sides[1].activate(game);local player=opened
assert(player[1].value()=='SQUIRTLE')
for _=1,80 do player[2].step(game,1)end
assert(data.species['red:SQUIRTLE'].player.pokemon_x==80/160)
for _=1,70 do player[2].step(game,-1)end
assert(player[2].value()=='10 PX')
for _=1,60 do player[3].step(game,-1)end
assert(data.species['red:SQUIRTLE'].player.pokemon_y==-60/144)
player[1].activate(game)
for _,row in ipairs(opened)do if row.label=='Pikachu'then row.activate(game)end end
player[2].step(game,1)
assert(data.species['red:PIKACHU'].player.pokemon_x==1/160)
assert(data.species['red:SQUIRTLE'].player.pokemon_x==10/160)
sides[2].activate(game);local opponent=opened
assert(opponent[1].value()=='RATTATA');opponent[2].step(game,-1)
assert(data.species['red:RATTATA'].opponent.pokemon_x==-1/160)
player[5].activate(game)
assert(data.species['red:PIKACHU']==nil and data.species['red:RATTATA'].opponent.pokemon_x==-1/160)
assert(data.global.player.pokemon_x==3/160)
print('PASS species menu: current species defaults, selectable list, exact repeated pixel edits, side isolation and targeted reset')
