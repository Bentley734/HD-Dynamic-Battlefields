local workspace=assert(os.getenv('HDB_WORKSPACE')):gsub('\\','/')
local project=workspace..'/HD-Dynamic-Battlefields'
local engine=workspace..'/.work/hd-battlefields-latest/v0.3.88/engine'
local output=project..'/docs/evidence'
local importedCache=os.getenv('HDB_TEST_PACK_CACHE')
if importedCache then importedCache=importedCache:gsub('\\','/')end
local cachePrefix='mod_cache/hd-dynamic-battlefields/'
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
 options.mods={['hd-dynamic-battlefields']=true,gen3transparency=true}
 options.modOptions={['hd-dynamic-battlefields']={enabled=false,selection='fixed',timeMode='day',weatherMode='clear',animation='off'}}
 local originalOptions=SaveData.loadOptions;SaveData.loadOptions=function()return options end
 local prefix='mods/hd-dynamic-battlefields/'
 local disk={}
 local function source(p)
  local file
  if importedCache and p==prefix..'metadata/prototype.lua'then return 'return {metadata={},compositions={}}'end
  if p:sub(1,#prefix)==prefix then file=project..'/'..p:sub(#prefix+1)
  elseif importedCache and p:sub(1,#cachePrefix)==cachePrefix then file=importedCache..'/'..p:sub(#cachePrefix+1)
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
 function fs.getDirectoryItems(p)if p=='mods'then return{'hd-dynamic-battlefields','gen3transparency'}end;return{}end
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

 local mapCatalog=assert(loadstring(assert(source('mods/hd-dynamic-battlefields/metadata/maps/gen1.lua'))))()
 local classifier=assert(loadstring(assert(source('mods/hd-dynamic-battlefields/lib/environments.lua'))))().new(mapCatalog)
 local inspected=0
 for id,map in pairs(data.maps)do
  assert(classifier:detect({game='red',map=id,tileset=map.tileset,kind='wild'}),'Unclassified native map '..id)
  inspected=inspected+1
 end
 assert(inspected==224)
 local provider=assert(loader.exports['hd-dynamic-battlefields'].battlefieldScenery)
 assert(loader.mods.gen3transparency.state=='loaded',table.concat(loader.errors,'\n'))
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
 local baseline=render(1920,1080,'compatibility-native-baseline.png')
 options.modOptions['hd-dynamic-battlefields'].enabled=true
 local scenic=render(1920,1080,'compatibility-native-with-provider.png')
 assert(scenic==baseline,'Native sprite/UI method calls or transforms changed')
 -- Exercise the logical-canvas path and final full-window replay.
 local function renderLogical(w,h,name)
  G.setCanvas();assert(love.window.setMode(w,h,{resizable=true}))
  local logical=G.newCanvas(160,144,{dpiscale=1});G.setCanvas(logical);G.origin();G.clear(0,0,0,0)
  trace={};battle:drawClassic();local result=table.concat(trace,'\n')
  G.setCanvas();G.origin();G.clear(.04,.04,.04,1)
  local scale=math.min(math.floor(w/160),math.floor(h/144))
  G.setColor(1,1,1,1);G.draw(logical,math.floor((w-160*scale)/2),math.floor((h-144*scale)/2),0,scale,scale)
  local captured=false
  G.captureScreenshot(function(pixels)
   write(name,pixels:encode('png'):getString())
   local r,g,b=pixels:getPixel(0,0);assert(math.abs(r-.04)>.01 or math.abs(g-.04)>.01 or math.abs(b-.04)>.01,'Background did not cover window margins')
   pixels:release();captured=true
  end)
  G.present();assert(captured,'Final backbuffer screenshot was not delivered')
  logical:release();return result
 end
 local batch={}
 options.modOptions['hd-dynamic-battlefields'].environment=os.getenv('HDB_ALIGNMENT_ENVIRONMENT')or'auto'
 local alignmentSizes={{640,480},{1024,768},{1280,800},{1536,1024},{1279,799},{1281,801},{1920,1080},{2520,1080},{2560,1080},{5120,1440},{900,1600},{900,1950},{900,2000},{451,1001}}
 if os.getenv('HDB_ALIGNMENT_CORE')=='1'then alignmentSizes={{1920,1080},{5120,1440},{900,1600}}end
 if os.getenv('HDB_ALIGNMENT_STANDARD')=='1'then alignmentSizes={{1280,720},{1920,1080},{2560,1440},{1281,721}}end
 if os.getenv('HDB_ALIGNMENT_WIDE')=='1'then alignmentSizes={{2520,1080},{2560,1080},{5120,1440}}end
 if os.getenv('HDB_ALIGNMENT_CLASSIC')=='1'then
  table.insert(alignmentSizes,1,{1024,768});table.insert(alignmentSizes,1,{640,480})
 end
 for _,period in ipairs({'day','night'})do
  options.modOptions['hd-dynamic-battlefields'].timeMode=period
  for _,size in ipairs(alignmentSizes)do
   local w,h=size[1],size[2]
   renderLogical(w,h,'alignment-'..period..'-'..w..'x'..h..'.png')
   local diagnostic=loader.exports['hd-dynamic-battlefields'].diagnostics()
   assert(diagnostic.status=='active',Json.encode(diagnostic))
   if importedCache then assert(diagnostic.composition:sub(1,5)=='pack:'and diagnostic.pack~='bundled prototype','Imported pack was bypassed')end
   assert(diagnostic.period==period,'Period artwork was not selected')
   batch[#batch+1]={period=period,width=w,height=h,composition=diagnostic.composition}
  end
 end
 write('alignment-batch.json',Json.encode(batch))
 -- Batch new variants through the actual native renderer and scenery consumer.
 local variants={}
 if os.getenv('HDB_ALIGNMENT_ONLY')~='1'then
 options.modOptions['hd-dynamic-battlefields'].selection='random'
 for _,environment in ipairs(os.getenv('HDB_VARIATION_ENVIRONMENT')and{os.getenv('HDB_VARIATION_ENVIRONMENT')}or{'grassland','forest','cave'})do
  options.modOptions['hd-dynamic-battlefields'].environment=environment
  for _,period in ipairs(environment=='cave'and{'day'}or{'day','night'})do
   options.modOptions['hd-dynamic-battlefields'].timeMode=period
   local variationSizes=os.getenv('HDB_VARIATION_STANDARD')=='1'and{{1920,1080}}or{{1920,1080},{5120,1440},{900,1600}}
   for _,size in ipairs(variationSizes)do
   for attempt=1,6 do
    assert(loader.exports['hd-dynamic-battlefields'].resetAssignments())
    local name='variation-'..environment..'-'..period..'-'..size[1]..'x'..size[2]..'-'..attempt..'.png'
    renderLogical(size[1],size[2],name)
    local d=loader.exports['hd-dynamic-battlefields'].diagnostics()
    assert(d.status=='active',Json.encode(d))
    variants[#variants+1]={composition=d.composition,period=d.period,width=size[1],height=size[2],image=name}
   end
   end
  end
 end
 write('variation-batch.json',Json.encode(variants))
 end
 options.modOptions['hd-dynamic-battlefields'].environment='auto'
 options.modOptions['hd-dynamic-battlefields'].timeMode='day'
 renderLogical(1920,1080,'compatibility-native-logical-1920x1080.png')
 renderLogical(5120,1440,'compatibility-native-logical-5120x1440.png')
 renderLogical(900,1600,'compatibility-native-logical-900x1600.png')
 assert(provider.enabled());assert(loader.exports['hd-dynamic-battlefields'].diagnostics().status=='active')
 if os.getenv('HDB_WATER_CONTEXT')then
  local target=os.getenv('HDB_WATER_CONTEXT')=='ocean'and'ocean'or'river'
  local route=target=='ocean'and'19'or'10'
  game.save.player.map='ROUTE_'..route;game.save.player.surfing=true
  renderLogical(1920,1080,target..'-automatic-surf-route-'..route..'.png')
  local d=loader.exports['hd-dynamic-battlefields'].diagnostics()
  assert(d.status=='active'and d.environment==target,Json.encode(d))
  write(target..'-automatic-context.json',Json.encode(d))
  game.save.player.surfing=false
  local originalBattle=battle
  for _,sample in ipairs({{'river','ROUTE_10'},{'ocean','ROUTE_19'}})do
   game.save.player.map=sample[2]
   local hooked=Battle.newWild(game,'MAGIKARP',5,{hooked=true})
   hooked.phase='menu';hooked.introSlide=0;hooked.introBalls=false
   battle=hooked;game.battle=hooked
   renderLogical(1920,1080,'fishing-'..sample[1]..'-context.png')
   local context=loader.exports['hd-dynamic-battlefields'].diagnostics()
   assert(context.status=='active'and context.environment==sample[1]and context.waterSource=='fishing',Json.encode(context))
   write('fishing-'..sample[1]..'-context.json',Json.encode(context))
  end
  battle=originalBattle;game.battle=originalBattle
  game.save.player.map='ROUTE_1';game.save.player.surfing=false
 end
 for name,method in pairs(methods)do Battle[name]=method end
 if importedCache then
  write('installed-pack-runtime-probe.txt','PASS official v0.3.88 Red renderer with Menu Customizer 3.35.4; bundled catalog removed for fixture; actual offline-imported cache selected for all '..#batch..' alignment renders and '..#variants..' variation renders; native sprite/UI calls and transforms unchanged. No network or live game-cache writes.\n')
 end
 write('compatibility-runtime-probe.txt','PASS official v0.3.88 Loader/Sandbox, original native Red battle renderer; scenery-only provider and complete Menu Customizer v3.35.4; identical native HUD/picture/text/effect calls and transforms before/after; full-window logical-canvas replay at 1920x1080, 5120x1440 and 900x1600. All 224 inspected Red map signatures classified. Fixture only; gameplay traversal remains untested.\n')
 end,debug.traceback)
 love.graphics.setCanvas()
 if not ok then write('compatibility-runtime-error.txt',err)end
 love.event.quit(ok and 0 or 1)
end
