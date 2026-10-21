local workspace=assert(os.getenv('HDB_WORKSPACE')):gsub('\\','/')
local project=workspace..'/HD-Dynamic-Battlefields'
local engine=(os.getenv('HDB_ENGINE_ROOT')or workspace..'/.work/hd-battlefields-latest/v0.3.95/engine'):gsub('\\','/')
local runtimeVersion=os.getenv('HDB_RUNTIME_VERSION')or'0.3.95'
local version=os.getenv('HDB_GAME_VERSION')or'emerald'
local output=project..'/docs/evidence/rse'
if os.getenv('HDB_LOADER')=='1'then output=output..'/loader/'..(os.getenv('HDB_MENU_CUSTOMIZER')=='1'and'menu-customizer'or'native')end
output=output..'/runtime-v'..runtimeVersion
if os.getenv('HDB_PACKAGED_BASE')=='1'then output=output..'/packaged-base'end
local content=os.getenv('HDB_CONTENT_MODE')or'none'
if content~='none'then output=output..'/'..content end
if os.getenv('HDB_WILDFOLLOWERS')=='1'then output=output..'/wildfollowers'end
if os.getenv('HDB_PACK_FIXTURE')then output=output..'/installed-pack'end
if os.getenv('HDB_DOUBLE')=='1'then output=output..'/doubles'end
if os.getenv('HDB_RESIZE')=='1'then output=output..(os.getenv('HDB_RESIZE_METHOD')=='desktop'and'/resize-desktop'or'/resize')end
if os.getenv('HDB_TRANSITIONS')=='1'then output=output..'/transitions'end
if os.getenv('HDB_MOVE_EFFECTS')=='1'then output=output..'/move-effects'end
if os.getenv('HDB_BATTLE_FLOW')=='1'then output=output..'/battle-flow'end
local function read(path)local f=io.open(path,'rb');if not f then return end;local b=f:read('*a');f:close();return b end
local function write(name,bytes)local f=assert(io.open(output..'/'..name,'wb'));f:write(bytes);f:close()end
function love.load()
 local ok,err=xpcall(function()
  local resizeWindow
  if os.getenv('HDB_RESIZE')=='1'and os.getenv('HDB_RESIZE_METHOD')=='desktop'then
   resizeWindow=assert(loadfile(project..'/tools/rse_native_probe/desktop_resize.lua'))()()
  end
  assert(version=='ruby'or version=='sapphire'or version=='emerald')
  package.path=engine..'/?.lua;'..engine..'/?/init.lua;'..package.path
  local cacheRoot=assert(os.getenv('APPDATA')):gsub('\\','/')..'/pokemon-love2d/'..version..'/'
  local roots=assert(loadfile(project..'/tools/rse_native_probe/sources.lua'))()(workspace,project)
  local function source(path)
   local packRelative=path:match('^mod_cache/hd%-dynamic%-battlefields/(.+)$')
   if packRelative and os.getenv('HDB_PACK_FIXTURE')then return read(os.getenv('HDB_PACK_FIXTURE')..'/mod_cache/hd-dynamic-battlefields/'..packRelative)end
   if path:match('^%a:[/\\]')then return read(path)end
   local id,relative=path:match('^mods/([^/]+)/(.+)$')
   if id and roots[id]then return read(roots[id]..'/'..relative)end
   local relative=path:gsub('^'..version..'/','')
   return read(cacheRoot..relative)or read(engine..'/'..path)
  end
  local FS=love.filesystem
  local oldRead,oldInfo,oldLoad=FS.read,FS.getInfo,FS.load
  FS.read=function(p,...)return source(p)or oldRead(p,...)end
  FS.getInfo=function(p,...)local b=source(p);if b then return{type='file',size=#b}end;return oldInfo(p,...)end
  FS.load=function(p,...)local b=source(p);if b then return assert(loadstring(b,'@'..p))end;return oldLoad(p,...)end
  local oldImage=love.graphics.newImage
  love.graphics.newImage=function(p,...)
   if type(p)=='string'then local b=source(p);if b then p=FS.newFileData(b,p)end end
   return oldImage(p,...)
  end
  local oldImageData=love.image.newImageData
  love.image.newImageData=function(p,...)
   if type(p)=='string'then local b=source(p);if b then p=FS.newFileData(b,p)end end
   return oldImageData(p,...)
  end
  require('src.core.GameVersion').set(version)
  assert(require('src.core.Version').engine==runtimeVersion,'Unexpected isolated engine release')
  local Blob=require('src.import.CacheBlob')
  local function cached(p)local b=source(p);return b and Blob.decode(p,b)end
  package.loaded['src.import.CacheFs']={readActive=cached,read=cached,readAt=cached,
   loadActive=function(p)
    local bytes=cached(p);if type(bytes)~='string'then return nil end
    local chunk,why=loadstring(bytes,'@'..p);if not chunk then return nil,why end
    local ok,value=pcall(chunk);if ok then return value end;return nil,value
   end,
   existsAt=function(p)return source(p)~=nil end,root=function()return cacheRoot:gsub(version..'/$','')end}
  local Dataset=require('src.core.game3.dataset')
  local cache={read=function(_,p)return cached(p)end,exists=function(_,p)return source(p)~=nil end}
  Dataset.cache=function()return cache end
  require('src.import.gba.versions').selectCache(version,cache)
  local Pokemon=require('src.core.game3.pokemon');Pokemon.install(cache)
  local maps=Dataset.buildMaps()
  local signatures=assert(loadfile(project..'/metadata/maps/rse.lua'))()[version]
  local count=0
  for id,signature in pairs(signatures)do
   assert(maps[id],'Missing native dataset map '..id)
   assert(maps[id].mapType==signature.mapType,'Map type differs: '..id)
   assert(maps[id].battleType==signature.battleType,'Battle scene differs: '..id)
   count=count+1
  end
  local prefix=({ruby='RU_',sapphire='SA_',emerald='EM_'})[version]
  local session={version=version,playerName='PROBE',trainerId=1,map=prefix..'ROUTE101',party={},
   meta={playthroughId='hd-rse-native-fixture'}}
  local game={data={maps=maps,pokemon={},generation=3,constants={}},session=session,phase='field'}
  game.save=require('src.core.game3.save_schema_firered').toSaveTable(session)
  require('src.core.Game3')._exposeModData(game)
  require('src.mods.Gen3Compat').bind(function()return game end)
  local SaveData=require('src.core.SaveData');local options=SaveData.defaultOptions()
  game.options=options;SaveData.loadOptions=function()return options end
  local playerSpecies=assert(Pokemon.speciesFromName('TREECKO'))
  local foeSpecies=assert(Pokemon.speciesFromName('POOCHYENA'))
  local player={species=playerSpecies,level=10,personality=1,ivs={31,31,31,31,31,31},evs={}}
  Pokemon.applyStats(player,session);player.hp=player.maxHp
  player.moves,player.pp,player.maxPp=Pokemon.movesAtLevel(playerSpecies,10);session.party={player}
  local Battle=require('src.core.game3.battle')
  assert(Battle.start{playerParty=session.party,foe={species=foeSpecies,level=7},wild=true,
   session=session,cache=cache,mapType=3,mapKind='outdoor',terrain=0,fade=false})
  local state=Battle.getState()
  local readContext=assert(loadfile(project..'/lib/adapters/rse_context.lua'))()({game=game},function(id)return tostring(id)end)
  local context=assert(readContext())
  assert(context.battle==state and context.game==version and context.map==session.map)
  assert(context.mapType==3 and context.terrainName=='GRASS'and not context.water)
  assert(context.playerSpecies and context.enemySpecies)
  local adapter=assert(loadfile(project..'/lib/environments_rse.lua'))()(assert(loadfile(project..'/metadata/maps/rse.lua'))())
  assert(adapter:detect(context).environment=='grassland')
  local Json=require('src.link.Json')
  if os.getenv('HDB_RENDER')=='1'then
   assert(loadfile(project..'/tools/rse_native_probe/render.lua'))()(project,game,Battle,cache,write,resizeWindow)
  end
  write(version..'-native-context.json',Json.encode({game=version,engine=runtimeVersion,map_signatures=count,
   context={map=context.map,mapType=context.mapType,terrain=context.terrainName,
    timeOfDay=context.timeOfDay,playerSpecies=context.playerSpecies,enemySpecies=context.enemySpecies},
   verified=true,saves_written=false,scope='Native dataset, battle construction and read-only context; no scenery rendering claim'}))
  Battle.reset()
  os.remove(output..'/'..version..'-native-error.txt')
 end,debug.traceback)
 if not ok then write(version..'-native-error.txt',err)end
 love.event.quit(ok and 0 or 1)
end
