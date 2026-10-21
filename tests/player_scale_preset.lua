-- Player mound presets preserve offsets, opponent settings and scope.
local saved={global={player={mound_y=.03},opponent={mound_scale=1.5}}}
local mounted
local mod={id='hd',path='hd',exports={nativeSize=function()return 240,160 end,
 environmentChoices={},getAdjustments=function()return saved end,
 applyAdjustments=function(d)saved=d;return true end,diagnostics=function()return{}end},
 options={get=function()end},hooks={wrap=function(_,_,fn)mounted=fn(function()return{}end,{},{} )end}}
function mod:read(p)
 if p=='lib/species_settings.lua'then return 'return function()return {}end' end
 if p=='lib/asset_manager.lua'then return 'return function()return {}end' end
 return 'return {}'
end
local oldRequire=require
require=function(n)
 if n=='src.core.GameVersion'then return{generation=function()return 1 end}end
 if n=='src.ui.OptionsMenu'then return{new=function(_,o)return o end}end
 return oldRequire(n)
end
assert(loadfile(root..'/lib/settings.lua'))()(mod)
require=oldRequire
local page
local game={stack={push=function(_,p)page=p end,pop=function()end}}
local function pick(rows,id)for _,r in ipairs(rows)do if r.id==id then return r end end;error(id)end
mounted[1].activate(game)
pick(page.rows,'hd_group_mounds').activate(game)
local mounds=page.rows
pick(mounds,'hd_group_player').activate(game)
local row=pick(page.rows,'hd_player_scale_preset')
assert(row.value()=='1X');row.activate(game)
pick(page.rows,'hd_player_scale_2').activate(game)
assert(saved.global.player.mound_scale==2 and saved.global.player.mound_y==.03)
assert(saved.global.opponent.mound_scale==1.5 and row.value()=='2X')
row.step(game,-1);assert(saved.global.player.mound_scale==1)
pick(mounds,'hd_calibration_scope').activate(game)
pick(page.rows,'hd_scope_32:9').activate(game)
row.activate(game);pick(page.rows,'hd_player_scale_2').activate(game)
assert(saved.aspects['32:9'].player.mound_scale==2)
assert(saved.global.player.mound_scale==1 and saved.global.opponent.mound_scale==1.5)
print('PASS player 1X/2X presets, persistence callback, offsets and aspect isolation')
