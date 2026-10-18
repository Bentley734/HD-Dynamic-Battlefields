local workspace=assert(os.getenv('HDB_WORKSPACE')):gsub('\\','/')
local project=workspace..'/HD-Dynamic-Battlefields'
local engine=workspace..'/.work/hd-battlefields-latest/v0.3.89/engine'
local version=os.getenv('HDB_GAME_VERSION')or'emerald'
local output=project..'/docs/evidence/rse'
local function read(path)local f=io.open(path,'rb');if not f then return end;local b=f:read('*a');f:close();return b end
local function write(name,bytes)local f=assert(io.open(output..'/'..name,'wb'));f:write(bytes);f:close()end
function love.load()
 local ok,err=xpcall(function()
  assert(version=='ruby'or version=='sapphire'or version=='emerald')
  package.path=engine..'/?.lua;'..engine..'/?/init.lua;'..package.path
  local cacheRoot=assert(os.getenv('APPDATA')):gsub('\\','/')..'/pokemon-love2d/'..version..'/'
  local function source(path)
   local relative=path:gsub('^'..version..'/','')
   return read(cacheRoot..relative)or read(engine..'/'..path)
  end
  local FS=love.filesystem
  local oldRead,oldInfo=FS.read,FS.getInfo
  FS.read=function(p,...)return source(p)or oldRead(p,...)end
  FS.getInfo=function(p,...)local b=source(p);if b then return{type='file',size=#b}end;return oldInfo(p,...)end
  local oldImage=love.graphics.newImage
  love.graphics.newImage=function(p,...)
   if type(p)=='string'then local b=source(p);if b then p=FS.newFileData(b,p)end end
   return oldImage(p,...)
  end
  require('src.core.GameVersion').set(version)
  assert(require('src.core.Version').engine=='0.3.89')
  local Blob=require('src.import.CacheBlob')
  local function cached(p)local b=source(p);return b and Blob.decode(p,b)end
  package.loaded['src.import.CacheFs']={readActive=cached,read=cached,readAt=cached,
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
  local session={version=version,playerName='PROBE',trainerId=1,map=prefix..'ROUTE101',party={}}
  local game={data={maps=maps,pokemon={},generation=3,constants={}},session=session,phase='field'}
  require('src.core.Game3')._exposeModData(game)
  require('src.mods.Gen3Compat').bind(function()return game end)
  local SaveData=require('src.core.SaveData');local options=SaveData.defaultOptions()
  game.options=options;SaveData.loadOptions=function()return options end
  local player={species=252,level=10,personality=1,ivs={31,31,31,31,31,31},evs={}}
  Pokemon.applyStats(player,session);player.hp=player.maxHp
  player.moves,player.pp,player.maxPp=Pokemon.movesAtLevel(252,10);session.party={player}
  local Battle=require('src.core.game3.battle')
  assert(Battle.start{playerParty=session.party,foe={species=261,level=7},wild=true,
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
  write(version..'-native-context.json',Json.encode({game=version,engine='0.3.89',map_signatures=count,
   context={map=context.map,mapType=context.mapType,terrain=context.terrainName,
    clock_period=context.clock_period,playerSpecies=context.playerSpecies,enemySpecies=context.enemySpecies},
   verified=true,saves_written=false,scope='Native dataset, battle construction and read-only context; no scenery rendering claim'}))
  Battle.reset()
  os.remove(output..'/'..version..'-native-error.txt')
 end,debug.traceback)
 if not ok then write(version..'-native-error.txt',err)end
 love.event.quit(ok and 0 or 1)
end
