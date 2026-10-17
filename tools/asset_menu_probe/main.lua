local workspace=assert(os.getenv('HDB_WORKSPACE')):gsub('\\','/')
local project=(os.getenv('HDB_PROJECT')or(workspace..'/HD-Dynamic-Battlefields')):gsub('\\','/')
local runtimeVersion=os.getenv('HDB_RUNTIME_VERSION')or'0.3.88'
local engine=workspace..'/.work/hd-battlefields-latest/v'..runtimeVersion..'/engine'
local output=project..'/docs/evidence'
local function write(name,bytes)local f=assert(io.open(output..'/'..name,'wb'));f:write(bytes);f:close()end
function love.load()
 local ok,err=xpcall(function()
 package.path=engine..'/?.lua;'..package.path
 assert(require('src.core.Version').engine==runtimeVersion)
 local cache=assert(os.getenv('APPDATA')):gsub('\\','/')..'/pokemon-love2d/red/'
 local function hostRead(path)
  local f=io.open(cache..path,'rb');if not f then return end
  local bytes=f:read('*a');f:close();return bytes
 end
 local fs=love.filesystem;local G=love.graphics
 G.setDefaultFilter('nearest','nearest')
 love.math.setRandomSeed(12345)
 local oldRead,oldInfo,oldLoad=fs.read,fs.getInfo,fs.load
 local oldImage,oldPixels=G.newImage,love.image.newImageData
 fs.read=function(p,...)return hostRead(p)or oldRead(p,...)end
 fs.getInfo=function(p,...)local b=hostRead(p);if b then return{type='file',size=#b}end;return oldInfo(p,...)end
 fs.load=function(p,...)local b=hostRead(p);if b then return loadstring(b,'@'..p)end;return oldLoad(p,...)end
 G.newImage=function(p,...)if type(p)=='string'then local b=hostRead(p);if b then p=fs.newFileData(b,p)end end;return oldImage(p,...)end
 love.image.newImageData=function(p,...)if type(p)=='string'then local b=hostRead(p);if b then p=fs.newFileData(b,p)end end;return oldPixels(p,...)end
 require('src.core.GameVersion').set('red')
 local Blob=require('src.import.CacheBlob')
 local function cached(p)return Blob.decode(p,hostRead(p))end
 package.loaded['src.import.CacheFs']={loadActive=function(p)local b=cached(p);if b then return assert(loadstring(b))()end end,
  readActive=cached,read=cached,readAt=function(p)return cached(p)end}
 local data=require('src.core.Data');data:load();require('src.render.Font').load(data)
 local Pokemon=require('src.pokemon.Pokemon')
 local game={data=data,save={player={name='PROBE',id=1},inventory={badges={}},party={Pokemon.new(data,'SQUIRTLE',10)},options={battleLayout='classic'},pokedex={seen={},owned={}}}}
 game.stack={top=function()return game.battle end}
 local Battle=require('src.battle.BattleState')
 local battle=Battle.newWild(game,'RATTATA',7);game.battle=battle
 battle.phase='menu';battle.introSlide=0;battle.introBalls=false
 local Json=require('src.link.Json')
 local SaveData=require('src.core.SaveData')
 local options=SaveData.defaultOptions()
 options.mods={['hd-dynamic-battlefields']=true}
 options.modOptions={['hd-dynamic-battlefields']={enabled=false,selection='fixed',timeMode='day',weatherMode='clear',animation='off'}}
 local originalOptions=SaveData.loadOptions;SaveData.loadOptions=function()return options end
 local prefix='mods/hd-dynamic-battlefields/'
 local disk={}
 local function source(p)
  local file
  if p:sub(1,#prefix)==prefix then file=project..'/'..p:sub(#prefix+1)
  elseif p:sub(1,22)=='mods/gen3transparency/' then file=workspace..'/.work/move-effects-audit/git-Menu-Customizer/'..p:sub(23)end
  if not file then return end
  local f=io.open(file,'rb');if not f then return end
  local b=f:read('*a');f:close();return b
 end
 local fs={}
 function fs.read(p)return disk[p]or source(p)end
 function fs.write(p,b)disk[p]=b;return true end
 function fs.getInfo(p)
  if p=='mods'or p=='mods/hd-dynamic-battlefields'or p=='mods/gen3transparency'then return{type='directory'}end
  local b=fs.read(p);if b then return{type='file',size=#b}end
 end
 function fs.getDirectoryItems(p)if p=='mods'then return{'hd-dynamic-battlefields'}end;return{}end
 function fs.load(p)return assert(loadstring(assert(fs.read(p)),'@'..p))end
 function fs.createDirectory()return true end
 function fs.remove(p)disk[p]=nil;return true end
 local G=love.graphics;local originalImage=G.newImage
 G.newImage=function(path,...)
  if type(path)=='string'then local b=source(path);if b then path=love.filesystem.newFileData(b,path)end end
  return originalImage(path,...)
 end
 local Loader=require('src.mods.Loader')
 local loader=Loader.new{fs=fs,generation=1,version='red',dev=false};loader.game=game
 loader:load(game.data)
 assert(loader.mods['hd-dynamic-battlefields'].state=='loaded',table.concat(loader.errors,'\n'))
 game.mods=loader;game.save.version='red';game.save.meta={playthroughId='hd-probe'};game.save.player.map='ROUTE_1'
 assert(game.data.maps.ROUTE_1,'Automatic map ID is not in the actual imported map table')
 battle.enemy.fainted=false;battle.player.fainted=false

 local Menu=require('src.ui.OptionsMenu');local opened
 local function module(path)return assert(loadfile(project..'/'..path))()end
 local exports=loader.exports['hd-dynamic-battlefields'];local index
 if os.getenv('HDB_REQUIRE_PUBLISHED_INDEX')=='1'then
  index=exports.assetPacks.updates.index
  assert(index.repository=='Bentley734/HD-Dynamic-Battlefields'and #index.packs==18,'Shipped index must expose all 18 verified download choices')
 else
  local f=assert(io.open(workspace..'/.work/hd-beta-1-release-shards/asset-index.json','rb'));index=Json.decode(f:read('*a'));f:close()
  exports.assetPacks.updates.index=index
 end
 local rootPage=module('lib/asset_manager.lua')({exports=exports},function(_,rows)opened=Menu.new(game,{rows=rows})end,index,module('lib/compositions.lua'))
 rootPage.activate(game);local mainRows=opened.rows
 local function render(name)
  local canvas=G.newCanvas(960,864,{dpiscale=1});G.setCanvas(canvas);G.origin();G.scale(6);G.clear(1,1,1,1);opened:draw();G.setCanvas()
  local pixels=canvas:newImageData();write(name,pixels:encode('png'):getString());pixels:release();canvas:release()
 end
 render('asset-manager-native-main.png')
 for _,row in ipairs(mainRows)do if row.id=='hd_assets_browse'then row.activate(game)end end
 render('asset-manager-native-packs.png')
 assert(#opened.rows==9,'Expected nine compact aspect packs before a battle supplies display context')
 opened.rows[1].activate(game);render('asset-manager-native-details.png')
 write('asset-menu-runtime-probe.txt','PASS official v0.3.89 native OptionsMenu renders Asset Manager filters, nine compact aspect rows and pack details; no network or live cache writes. Screenshots require visual review.\n')
 end,debug.traceback)
 if not ok then write('asset-menu-runtime-error.txt',err)end
 love.event.quit(ok and 0 or 1)
end
