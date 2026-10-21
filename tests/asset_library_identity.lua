package.path=engine..'/?.lua;'..package.path
local Json=require('src.link.Json')
local build=assert(loadfile(root..'/lib/asset_library.lua'))()
local releases=0
local payload={metadata={base={composition_id='base'}},compositions={{id='water',metadata='base',
 background='art/water.png',mounds={player='art/mounds/islet.png',opponent='art/mounds/islet.png'}}}}
local pack={id='water-pack',version='1'}
local store={installed=function()return pack end,verify=function()return true end,
 read=function()return Json.encode(payload)end,imagePath=function(_,p,path)return'cache/'..p.version..'/'..path end}
local selection={active={}}
local catalog={compositions={},metadata={}}
local mod={assets={path=function(_,path)return'bundled/'..path end},info=function()return nil end}
local library=build(mod,store,Json,selection,catalog,{release=function()releases=releases+1 end})
assert(library:refresh({'water-pack'}))
local imported=catalog.compositions[1]
assert(imported.mounds.player=='pack:water-pack:1:art/mounds/islet.png')
assert(library:sourcePath(imported.mounds.player)=='art/mounds/islet.png')
assert(library:path(imported.mounds.player)=='cache/1/art/mounds/islet.png')
assert(library:sourcePath('art/mounds/islet.png')=='art/mounds/islet.png')
pack.version='2';assert(library:refresh({'water-pack'}))
assert(library:sourcePath(catalog.compositions[1].mounds.player)=='art/mounds/islet.png')
assert(library.originals[imported.mounds.player]==nil,'Old pack identity leaked across update')
assert(releases==2,'Pack changes must invalidate active textures')
print('PASS installed mound material identity survives namespacing/version updates; cache refresh invalidates textures')
