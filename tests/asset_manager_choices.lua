local build=assert(loadfile(root..'/lib/asset_manager.lua'))()
local shown
local packs={
 {id='wide-one',label='16:9 One',aspects={'16:9'},quality='HD',variation_profile='one'},
 {id='wide-all',label='16:9 All',aspects={'16:9'},quality='HD',variation_profile='all'},
 {id='phone-one',aspects={'9:16'},quality='HD',variation_profile='one'}}
local mod={exports={assetPacks={store={installed=function()end},library={health={},packs={}},updates={index={packs=packs}}},diagnostics=function()return{viewport={width=1920,height=1080}}end}}
local game={stack={pop=function()end}}
local queued
mod.exports.assetPacks.queue={start=function(_,items)queued=items;return true end}
local menu=build(mod,function(_,rows)shown=rows end,{}, {ratios={{'16:9'},{'9:16'}},aspect=function()return'16:9'end})
menu.activate(game);local rootRows=shown
local function find(rows,id)for _,row in ipairs(rows)do if row.id==id then return row end end;error(id)end
find(rootRows,'hd_assets_browse').activate(game)
assert(#shown==1 and shown[1].id=='hd_assets_pack_wide-one','Compact auto filter must match display only')
find(rootRows,'hd_assets_variations').activate(game)
find(shown,'hd_assets_variations_all').activate(game)
find(rootRows,'hd_assets_browse').activate(game)
assert(#shown==1 and shown[1].id=='hd_assets_pack_wide-all','Full variation profile selection failed')
find(rootRows,'hd_assets_download_all').activate(game)
assert(#queued==1 and queued[1].id=='wide-all','Download all must honor variation profile')
find(rootRows,'hd_assets_variations').activate(game)
find(shown,'hd_assets_variations_one').activate(game)
find(rootRows,'hd_assets_download_all').activate(game)
assert(#queued==2 and queued[1].id=='wide-one'and queued[2].id=='phone-one',
 'Download all must include other aspect families despite current-display filtering')
mod.exports.assetPacks.queue.error='Batch failed'
assert(find(rootRows,'hd_assets_error').value()=='Batch failed')
print('PASS Asset Manager separate aspect and compact/full variation filtering')
