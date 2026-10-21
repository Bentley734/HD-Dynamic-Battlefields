local workspace=assert(os.getenv('HDB_WORKSPACE')):gsub('\\','/')
local project=(os.getenv('HDB_PROJECT')or(workspace..'/HD-Dynamic-Battlefields')):gsub('\\','/')
local runtimeVersion=os.getenv('HDB_RUNTIME_VERSION')or'0.3.88'
local engine=workspace..'/.work/hd-battlefields-latest/v'..runtimeVersion..'/engine'
local output=project..'/docs/evidence'
local function write(name,bytes)local f=assert(io.open(output..'/'..name,'wb'));f:write(bytes);f:close()end
function love.load()
 local ok,err=xpcall(function()
 local runtimeArchive=assert(io.open(workspace..'/.work/hd-battlefields-latest/v'..runtimeVersion..'/gen1recomp-'..runtimeVersion..'.love','rb'));local archiveBytes=runtimeArchive:read('*a');runtimeArchive:close()
 assert(love.filesystem.mount(love.filesystem.newFileData(archiveBytes,'runtime.zip'),'',true))
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

 local store=loader.exports['hd-dynamic-battlefields'].assetPacks.store
 local manifest=os.getenv('HDB_NETWORK_PACK')or workspace..'/.work/hd-beta-1-release-shards/16-10/battlefields-16-10-hd-one-0.1.0-beta.1.pack.json'
 local f=assert(io.open(manifest,'rb'));local pack=Json.decode(f:read('*a'));f:close()
 assert(store:start(pack));local started=love.timer.getTime()
 love.update=function()
  local good,why=xpcall(function()
   assert(love.timer.getTime()-started<600,'Network fixture deadline')
   store:update()
   if store.status=='error'then error(store.error)end
   if store.status=='installed'then
    local installed=assert(store:installed(pack.id));assert(store:verify(installed))
    write('network-runtime-probe.json',Json.encode({runtime=runtimeVersion,pack=pack.id,files=#pack.files,installed_size=pack.installed_size,status='verified',seconds=love.timer.getTime()-started,scope='Actual official runtime HTTP facade and transactional store; isolated memory cache, no user game writes'}))
    love.event.quit(0)
   end
  end,debug.traceback)
  if not good then write('network-runtime-error.txt',why);love.event.quit(1)end
 end
 end,debug.traceback)
 if not ok then write('network-runtime-error.txt',err);love.event.quit(1)end
end
