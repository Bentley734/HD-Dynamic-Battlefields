local workspace=assert(os.getenv('HDB_WORKSPACE')):gsub('\\','/')
local project=workspace..'/HD-Dynamic-Battlefields'
local engine=workspace..'/.work/hd-battlefields-latest/v0.3.88/engine'
local output=project..'/docs/evidence'
local function write(name,bytes)local f=assert(io.open(output..'/'..name,'wb'));f:write(bytes);f:close()end
function love.load()
 local ok,err=xpcall(function()
 package.path=engine..'/?.lua;'..package.path
 assert(require('src.core.Version').engine=='0.3.88')
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

 local mapInfo={}
 for id,map in pairs(data.maps)do
  local entry={id=id,fields={}}
  for key,value in pairs(map)do
   local kind=type(value)
   if key~='source'and(kind=='string'and #value<160 or kind=='number'or kind=='boolean')then entry.fields[key]=value end
  end
  mapInfo[#mapInfo+1]=entry
 end
 table.sort(mapInfo,function(a,b)return a.id<b.id end)
 write('red-map-descriptors.json',Json.encode(mapInfo))
 local mapCatalog=assert(loadstring(assert(source('mods/hd-dynamic-battlefields/metadata/maps/gen1.lua'))))()
 local classifier=assert(loadstring(assert(source('mods/hd-dynamic-battlefields/lib/environments.lua'))))().new(mapCatalog)
 local inspected=0
 for id,map in pairs(data.maps)do
  assert(classifier:detect({game='red',map=id,tileset=map.tileset,kind='wild'}),'Unclassified native map '..id)
  inspected=inspected+1
 end
 assert(inspected==224)
 local provider=assert(loader.exports['hd-dynamic-battlefields'].battlefieldScenery)

 for _,hook in ipairs(loader.hooks.chains['render.compose']or{})do assert(hook.owner~='hd-dynamic-battlefields')end
 local trace={};local methods={}
 for _,name in ipairs({'drawHUDs','drawPicsLayer','drawTextArea','drawAnimLayer'})do
  methods[name]=Battle[name]
  Battle[name]=function(self,...)
   local x0,y0=G.transformPoint(0,0);local x1,y1=G.transformPoint(1,0);local x2,y2=G.transformPoint(0,1)
   local values={x0,y0,x1,y1,x2,y2};local args={...}
   trace[#trace+1]=Json.encode({name=name,args=args,transform=values})
   return methods[name](self,...)
  end
 end
 local function render(w,h,name)
  local canvas=G.newCanvas(w,h,{dpiscale=1})
  G.setCanvas(canvas);G.origin();G.clear(.04,.04,.04,1)
  local scale=math.min(math.floor(w/160),math.floor(h/144))
  G.translate(math.floor((w-160*scale)/2),math.floor((h-144*scale)/2));G.scale(scale)
  trace={};battle:drawClassic();local result=table.concat(trace,'\n')
  G.setCanvas();local pixels=canvas:newImageData();write(name,pixels:encode('png'):getString());pixels:release();canvas:release()
  return result
 end
 local baseline=render(1920,1080,'standalone-native-baseline.png')
 options.modOptions['hd-dynamic-battlefields'].enabled=true
 local scenic=render(1920,1080,'standalone-native-with-provider.png')
 assert(scenic==baseline,'Native sprite/UI method calls or transforms changed')
 -- Exercise the logical-canvas path and final full-window replay.
 local function renderLogical(w,h,name,expectScenery)
  G.setCanvas();assert(love.window.setMode(w,h,{resizable=true}))
  local logical=G.newCanvas(160,144,{dpiscale=1});G.setCanvas(logical);G.origin();G.clear(0,0,0,0)
  trace={};battle:drawClassic();local result=table.concat(trace,'\n')
  G.setCanvas();G.origin();G.clear(.04,.04,.04,1)
  local scale=math.min(math.floor(w/160),math.floor(h/144))
  G.setColor(1,1,1,1);G.draw(logical,math.floor((w-160*scale)/2),math.floor((h-144*scale)/2),0,scale,scale)
  local captured=false
  G.captureScreenshot(function(pixels)
   write(name,pixels:encode('png'):getString())
   local r,g,b=pixels:getPixel(0,0)
   local changed=math.abs(r-.04)>.01 or math.abs(g-.04)>.01 or math.abs(b-.04)>.01
   assert(changed==(expectScenery~=false),'Scenery/native fallback did not match the requested state')
   pixels:release();captured=true
  end)
  G.present();assert(captured,'Final backbuffer screenshot was not delivered')
  logical:release();return result
 end
 renderLogical(1920,1080,'standalone-native-logical-1920x1080.png')
 renderLogical(5120,1440,'standalone-native-logical-5120x1440.png')
 renderLogical(900,1600,'standalone-native-logical-900x1600.png')
 assert(provider.enabled());assert(loader.exports['hd-dynamic-battlefields'].diagnostics().status=='active')
 game.save.player.map='UNKNOWN_PROBE_MAP'
 renderLogical(1920,1080,'standalone-native-fallback-unknown.png',false)
 assert(loader.exports['hd-dynamic-battlefields'].diagnostics().status=='native fallback')
 game.save.player.map='ROUTE_1';options.modOptions['hd-dynamic-battlefields'].enabled=false
 renderLogical(1920,1080,'standalone-native-fallback-disabled.png',false)
 options.modOptions['hd-dynamic-battlefields'].enabled=true
 -- A native draw error must not leave our temporary paper override installed.
 local rectangle=G.rectangle;local previous=methods.drawHUDs
 local failing=function()error('injected native HUD error')end
 methods.drawHUDs=failing
 G.setCanvas();G.origin()
 assert(not pcall(battle.drawClassic,battle))
 methods.drawHUDs=previous
 assert(G.rectangle==rectangle and rawget(battle,'_hdSceneryPaper')==nil)

 for name,method in pairs(methods)do Battle[name]=method end
 write('standalone-runtime-probe.txt','PASS official v0.3.88 Loader/Sandbox, original native Red battle renderer; scenery-only provider without Menu Customizer or another scenery consumer; identical native HUD/picture/text/effect calls and transforms before/after; full-window logical-canvas replay at 1920x1080, 5120x1440 and 900x1600. All 224 inspected Red map signatures classified; unknown-map and disabled native fallbacks verified; native-error paper override restored. Fixture only; gameplay traversal remains untested.\n')
 end,debug.traceback)
 love.graphics.setCanvas()
 if not ok then write('standalone-runtime-error.txt',err)end
 love.event.quit(ok and 0 or 1)
end
