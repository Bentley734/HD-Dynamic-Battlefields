local workspace=assert(os.getenv('HDB_WORKSPACE')):gsub('\\','/')
local project=workspace..'/HD-Dynamic-Battlefields'
local engine=workspace..'/.work/hd-battlefields-latest/v0.3.89/engine'
local version=os.getenv('HDB_GAME_VERSION')or'crystal'
local output=project..'/docs/evidence/gen2'
if os.getenv('HDB_MENU_CUSTOMIZER')=='1'then output=output..'/menu-customizer'end
local function read(path)local f=io.open(path,'rb');if not f then return end;local b=f:read('*a');f:close();return b end
local function write(name,b)local f=assert(io.open(output..'/'..name,'wb'));f:write(b);f:close()end
function love.load()
 local ok,err=xpcall(function()
  package.path=engine..'/?.lua;'..package.path
  assert(require('src.core.Version').engine=='0.3.89')
  require('src.core.GameVersion').set(version)
  local cache=assert(os.getenv('APPDATA')):gsub('\\','/')..'/pokemon-love2d/'..version..'/'
  local fs,G=love.filesystem,love.graphics
  G.setDefaultFilter('nearest','nearest')
  love.math.setRandomSeed(12345)
  local function source(path)
   local id,relative=path:match('^mods/([^/]+)/(.+)$')
   if id=='hd-dynamic-battlefields'then return read(project..'/'..relative)end
   if id=='gen3transparency'then return read(workspace..'/.work/menu-gen3-font-fix/'..relative)end
   return read(cache..path)or read(engine..'/'..path)
  end
  local oldRead,oldInfo,oldLoad=fs.read,fs.getInfo,fs.load
  fs.read=function(p,...)return source(p)or oldRead(p,...)end
  fs.getInfo=function(p,...)local b=source(p);if b then return{type='file',size=#b}end;return oldInfo(p,...)end
  fs.load=function(p,...)local b=source(p);if b then return loadstring(b,'@'..p)end;return oldLoad(p,...)end
  local oldImage,oldPixels=G.newImage,love.image.newImageData
  G.newImage=function(p,...)
   if type(p)=='string'then local b=read(p)or source(p);if b then p=fs.newFileData(b,p)end end
   return oldImage(p,...)
  end
  love.image.newImageData=function(p,...)
   if type(p)=='string'then local b=source(p);if b then p=fs.newFileData(b,p)end end
   return oldPixels(p,...)
  end
  local Blob=require('src.import.CacheBlob')
  local function generated(path)
   local b=assert(source('data/generated/'..path..'.lua'),path)
   return assert(loadstring(Blob.decode(path,b)))()
  end
  package.loaded['src.import.CacheFs']={loadActive=function(p)
   local b=source(p);if b then return assert(loadstring(Blob.decode(p,b)))()end
  end,readActive=function(p)return source(p)end}
  local data={pokemon=generated('pokemon'),moves=generated('moves'),items=generated('items'),
   type_chart=generated('type_chart'),font=generated('font'),audio=generated('audio'),
   gen2Palettes=generated('palettes'),gen2BattleAnims=generated('battle_anims'),
   gen2Trainers=generated('trainers'),gen2Constants=generated('constants')}
  require('src.render.Font').load(data)
  local Mon=require('src.battle.gen2.Mon')
  local Logic=require('src.battle.gen2.Battle')
  local Save=require('src.core.gen2.Save')
  local save=Save.newGame({playerName='PROBE'})
  save.party={Mon.new(data,'TOTODILE',10)}
  local options=save.options or{};save.options=options;options.battleLayout='classic'
  local game={data=data,save=save,options=options}
  local Screen=require('src.ui.gen2.BattleState')
  local battle=Logic.new({data=data,party=save.party,wild={species='RATTATA',level=7},save=save})
  local screen=Screen.new(game,{battle=battle,save=save})
  game.stack={top=function()return screen end}
  local maps=assert(loadfile(project..'/metadata/maps/gen2.lua'))()
  local location=maps[version].ROUTE_29
  game.world={map={id='ROUTE_29',def={tileset=location.tileset,environment=location.environment_type}},
   playerState='walk',hour=function()return 12 end,timeOfDay=function()return'DAY'end}
  screen.phase='menu';screen.slideFrame=999;screen.showPlayerTrainer=false;screen.showEnemyTrainer=false
  screen.showPlayerHud=true;screen.showEnemyHud=true;screen.ballRows={}
  local values={enabled=false,environment='auto',selection='fixed',timeMode='auto',weatherMode='clear',animation='off',
   mounds=true,quality='HD',aspect='auto'}
  local mod={id='hd-dynamic-battlefields',path=project,game=game,exports={},
   assets={path=function(_,p)return project..'/'..p end},
   cache={read=function()end,write=function()return true end},events={on=function()end},
   storage={read=function()end,write=function()return true end},find=function()end,
   options={define=function()end,get=function(_,key)return values[key]end}}
  function mod:read(path)
   if path=='lib/settings.lua'then return'return function()end'end
   return read(project..'/'..path)
  end
  function mod:info(path)local b=read(project..'/'..path);if b then return{type='file',size=#b}end end
  local trace={}
  for _,name in ipairs({'drawHud','drawPics','drawBottom','drawEnemyHud','drawPlayerHud'})do
   local original=Screen[name]
   Screen[name]=function(self,...)
    local x,y=G.transformPoint(0,0);local sx,sy=G.transformPoint(1,1)
    trace[#trace+1]=name..':'..table.concat({x,y,sx,sy},',')
    return original(self,...)
   end
  end
  if os.getenv('HDB_MENU_CUSTOMIZER')=='1'then
   local SaveData=require('src.core.SaveData')
   local configured=SaveData.defaultOptions()
   configured.mods={['hd-dynamic-battlefields']=true,gen3transparency=true}
   configured.modOptions={['hd-dynamic-battlefields']=values}
   SaveData.loadOptions=function()return configured end
   local disk={}
   local virtual={read=function(p)return disk[p]or source(p)end,
    write=function(p,b)disk[p]=b;return true end,createDirectory=function()return true end,
    remove=function(p)disk[p]=nil;return true end,
    getDirectoryItems=function(p)if p=='mods'then return{'hd-dynamic-battlefields','gen3transparency'}end;return{}end}
   function virtual.getInfo(p)
    if p=='mods'or p=='mods/hd-dynamic-battlefields'or p=='mods/gen3transparency'then return{type='directory'}end
    local b=virtual.read(p);if b then return{type='file',size=#b}end
   end
   function virtual.load(p)return assert(loadstring(assert(virtual.read(p)),'@'..p))end
   local loader=require('src.mods.Loader').new({fs=virtual,generation=2,version=version,dev=false})
   loader.game=game;loader:load(data);game.mods=loader
   assert(loader.mods['hd-dynamic-battlefields'].state=='loaded',table.concat(loader.errors,'\n'))
   assert(loader.mods.gen3transparency.state=='loaded',table.concat(loader.errors,'\n'))
   -- Loader owns the sandbox facade; exports is the public inspection surface.
   mod={exports=loader.exports['hd-dynamic-battlefields']}
  else
   assert(loadfile(project..'/main.lua'))()(mod)
  end
  local function render(w,h,layout,name)
   assert(love.window.setMode(w,h,{resizable=true}))
   options.battleLayout=layout
   G.setCanvas();G.origin();G.clear(.04,.04,.04,1)
   trace={}
   screen:drawWidescreen(w,h)
   local captured=false
   G.captureScreenshot(function(pixels)
    write(name,pixels:encode('png'):getString());pixels:release();captured=true
   end)
   G.present();assert(captured)
   return table.concat(trace,'\n')
  end
  local nativeTrace=render(1920,1080,'classic',version..'-native-classic.png')
  values.enabled=true
  assert(render(1920,1080,'classic',version..'-hd-classic.png')==nativeTrace,
   'Scenery changed native HUD/picture/panel calls or transforms')
  assert(mod.exports.diagnostics().status=='active',mod.exports.diagnostics().reason)
  render(5120,1440,'wide',version..'-hd-wide-5120.png')
  render(900,1600,'classic',version..'-hd-portrait.png')
  if os.getenv('HDB_LOCATIONS')=='1'then
   for _,case in ipairs({
    {'RUINS_OF_ALPH_INNER_CHAMBER','day'}, {'DRAGONS_DEN_B1F','day'},
    {'WHIRL_ISLAND_LUGIA_CHAMBER','day'}, {'TIN_TOWER_ROOF','night'},
    {'VIOLET_GYM','day'}, {'MAHOGANY_GYM','day'},
    {'GOLDENROD_UNDERGROUND_WAREHOUSE','day'}, {'OLIVINE_PORT','night'}})do
    local id,period=case[1],case[2];local spec=assert(maps[version][id],id)
    game.world.map={id=id,def={tileset=spec.tileset,environment=spec.environment_type}}
    game.world.playerState=id=='OLIVINE_PORT'and'surf'or'walk'
    values.timeMode=period
    render(1280,720,'classic',version..'-location-'..id..'-'..period..'.png')
    assert(mod.exports.diagnostics().status=='active',id..': '..tostring(mod.exports.diagnostics().reason))
   end
  end
  if os.getenv('HDB_ANIMATIONS')=='1'then
   local AnimView=require('src.ui.gen2.BattleAnimView')
   local rows={}
   for _,move in ipairs({'TACKLE','SURF','PSYCHIC_M','EARTHQUAKE'})do
    assert(screen:animForMove(move,'player'), 'Missing native animation: '..move)
    local runner=screen.anim
    local canvasFrames=0
    for frame=1,40 do
     runner:step()
     if AnimView.needsCanvas(runner)then canvasFrames=canvasFrames+1 end
     if frame==8 or frame==24 then
      values.enabled=false
      local native=render(1280,720,'classic',version..'-anim-'..move..'-'..frame..'-native.png')
      values.enabled=true
      local hd=render(1280,720,'classic',version..'-anim-'..move..'-'..frame..'-hd.png')
      assert(native==hd,'Animation changed native drawing trace: '..move)
      assert(mod.exports.diagnostics().status=='active',move)
     end
    end
    rows[#rows+1]=move..': 40 steps, '..canvasFrames..' scanline-canvas frames, frames 8/24 rendered disabled/enabled with identical native call transforms.'
    screen.anim=nil
   end
   write(version..'-animations.txt',table.concat(rows,'\n')..'\n')
  end
  os.remove(output..'/'..version..'-error.txt')
  local consumer=os.getenv('HDB_MENU_CUSTOMIZER')=='1'and' with Menu Customizer 3.35.15 via native Loader/Sandbox'or' standalone'
  write(version..'-probe.txt','PASS v0.3.89 native Gen2 battle fixture'..consumer..', classic/wide/portrait rendering, identical classic native HUD/picture/panel call order and transforms disabled/enabled. No saves written. Fixture evidence only; gameplay traversal and custom-profile coverage remain pending.\n')
 end,debug.traceback)
 love.graphics.setCanvas()
 if not ok then write(version..'-error.txt',err)end
 love.event.quit(ok and 0 or 1)
end
