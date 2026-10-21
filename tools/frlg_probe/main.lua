local workspace=assert(os.getenv('HDB_WORKSPACE')):gsub('\\','/')
local project=(os.getenv('HDB_PROJECT')or(workspace..'/HD-Dynamic-Battlefields')):gsub('\\','/')
local version=os.getenv('HDB_GAME_VERSION')or'firered'
local mode=os.getenv('HDB_COMPAT_MODE')or'national'
local runtimeVersion=os.getenv('HDB_RUNTIME_VERSION')or'0.3.95'
local engine=workspace..'/.work/hd-battlefields-latest/v'..runtimeVersion..'/engine'
local research=(os.getenv('HDB_COMPAT_ROOT')or workspace..'/.work/hd-rse-compat-latest/national-suite-2026-10-21'):gsub('\\','/')
local baseOutput=project..'/docs/evidence/frlg/runtime-v'..runtimeVersion..'/'..version..'-'..mode
local size=os.getenv('HDB_SIZE')or'1280x720'
local probeW,probeH=size:match('^(%d+)x(%d+)$');probeW,probeH=tonumber(probeW),tonumber(probeH)
local output=baseOutput..'/'..size
local function read(path)local f=io.open(path,'rb');if not f then return end;local b=f:read('*a');f:close();return b end
local function write(name,bytes)
 local folder=(name=='maps.json'or name=='species.json')and baseOutput or output
 local f=assert(io.open(folder..'/'..name,'wb'));f:write(bytes);f:close()
end
function love.load()
 local ok,err=xpcall(function()
  package.path=engine..'/?.lua;'..engine..'/?/init.lua;'..package.path
  local Json=require('src.link.Json')
  local inventory=Json.decode(assert(read(research..'/directory-index.json')))
  local roots={national_dex_gen3=research..'/national_dex_gen3/extracted',
   ['g9-battle-sprites-gen3']=research..'/g9-battle-sprites-gen3/extracted',
   ['gen3-hd-sprites']=research..'/gen3-hd-sprites/extracted',
   ['1025dex']=(os.getenv('HDB_DEX_ROOT')or workspace..'/.work/1025dex-double-fix'):gsub('\\','/'),
   ['hd-dynamic-battlefields']=project}
  local enabled=mode=='national'and{'national_dex_gen3','g9-battle-sprites-gen3','gen3-hd-sprites'}or{'1025dex'}
  enabled[#enabled+1]='hd-dynamic-battlefields'
  local appdata=assert(os.getenv('APPDATA')):gsub('\\','/')..'/pokemon-love2d'
  local function source(path)
   local asset=path:match('^mod_cache/1025dex/dex_assets/files/(assets/.+)$')
   if asset then return read(workspace..'/.work/hd-rse-compat-latest/dex-artwork/'..asset)end
   local receipt=path:match('^mod_cache/1025dex/(dex_assets/[^/]+)$')
   if receipt then return read(workspace..'/.work/hd-rse-compat-latest/dex-manager-fixture/'..receipt)end
   local id,rel=path:match('^mods/([^/]+)/(.+)$')
   if id then return roots[id]and read(roots[id]..'/'..rel)end
   if path:match('^data/generated/')or path:match('^assets/generated/')then return read(appdata..'/'..version..'/'..path)end
   if path:match('^'..version..'/data/generated/')or path:match('^'..version..'/assets/generated/')then return read(appdata..'/'..path)end
   return read(engine..'/'..path)
  end
  local FS=love.filesystem;local oldRead,oldInfo,oldImage=FS.read,FS.getInfo,love.graphics.newImage
  FS.read=function(path,...)return source(path)or oldRead(path,...)end
  FS.getInfo=function(path,...)local b=source(path);if b then return{type='file',size=#b}end;return oldInfo(path,...)end
  love.graphics.newImage=function(path,...)if type(path)=='string'then local b=source(path);if b then path=FS.newFileData(b,path)end end;return oldImage(path,...)end
  local oldPixels=love.image.newImageData
  love.image.newImageData=function(path,...)if type(path)=='string'then local b=source(path);if b then path=FS.newFileData(b,path)end end;return oldPixels(path,...)end
  require('src.core.GameVersion').set(version)
  assert(require('src.core.Version').engine==runtimeVersion,'Wrong isolated engine')
  local Blob=require('src.import.CacheBlob')
  local function cached(path)local b=source(path);return b and Blob.decode(path,b)end
  package.loaded['src.import.CacheFs']={readActive=cached,read=cached,readAt=cached,
   loadActive=function(p)local b=cached(p);if type(b)~='string'then return end;local chunk=assert(loadstring(b,'@'..p));local ok,value=pcall(chunk);if ok then return value end;return nil,value end,
   existsAt=function(p)return source(p)~=nil end,root=function()return appdata end}
  local Dataset=require('src.core.game3.dataset')
  local cache={read=function(_,p)return cached(p)end,exists=function(_,p)return source(p)~=nil end}
  Dataset.cache=function()return cache end
  require('src.import.gba.versions').selectCache(version,cache)
  local Pokemon=require('src.core.game3.pokemon');Pokemon.install(cache);assert(Pokemon._names,'Native species pack unavailable')
  local game={data={maps=Dataset.buildMaps(),pokemon={},generation=3,constants={}},phase='field',
   session={version=version,playerName='PROBE',trainerId=1,map='FR_ROUTE1',party={}},
   save={version=version,player={name='PROBE',id=1,map='FR_ROUTE1'},party={},meta={playthroughId='hd-frlg-probe'}}}
  game.save=require('src.core.game3.save_schema_firered').toSaveTable(game.session)
  require('src.core.Game3')._exposeModData(game)
  require('src.mods.Gen3Compat').bind(function()return game end)
  local SaveData=require('src.core.SaveData');local options=SaveData.defaultOptions();options.mods={}
  for _,id in ipairs(enabled)do options.mods[id]=true end
  options.modOptions={['hd-dynamic-battlefields']={enabled=true,selection='fixed',timeMode='day',weatherMode='clear',animation='off'}}
  -- The lightweight base intentionally bundles only one 16:9 habitat.
  if os.getenv('HDB_BASE_ONLY')=='1'then options.modOptions['hd-dynamic-battlefields'].aspect='16:9'end
  game.options=options;SaveData.loadOptions=function()return options end
  local memory={};local fs={}
  function fs.read(path)return memory[path]or source(path)end
  function fs.write(path,bytes)memory[path]=bytes;return true end
  function fs.remove(path)memory[path]=nil;return true end
  function fs.createDirectory()return true end
  function fs.getInfo(path)
   if path=='mods'or path:match('^mods/[^/]+$')and roots[path:sub(6)]then return{type='directory'}end
   if inventory[path]then return{type='directory'}end
   local b=fs.read(path);if b then return{type='file',size=#b}end
  end
  function fs.getDirectoryItems(path)if path=='mods'then return enabled end;return inventory[path]or{}end
  function fs.load(path)return assert(loadstring(assert(fs.read(path)),'@'..path))end
  local Loader=require('src.mods.Loader');local loader=Loader.new{fs=fs,generation=3,version=version,dev=false};loader.game=game;game.mods=loader
  loader:load(game.data)
  for _,id in ipairs(enabled)do assert(loader.mods[id]and loader.mods[id].state=='loaded',id..': '..table.concat(loader.errors,'\n'))end
  local assetsReady
  if mode=='1025'then
   assetsReady=assert(loader.exports['1025dex'].assetManager):isComplete()
   assert(assetsReady,'1025Dex manager must recognize installed assets')
  end
  require('src.mods.Gen3Compat').applyMerged(game)
  -- Runtime entry reloads the ROM species pack after the initial mod merge.
  -- Its reload hooks restore extended species and reinstall picture providers.
  Pokemon.install(cache)
  loader.events:emit('game.ready',{game=game})
  assert(#loader.errors==0,table.concat(loader.errors,'\n'))
  local Catalog=assert(loadfile(project..'/lib/species_catalog.lua'))()
  local rows,slots=Catalog.collect(loader.content.pokemon,game.data.pokemon)
  local hdmod=assert(loader.exports['hd-dynamic-battlefields'])
  assert(#hdmod.getSpeciesChoices()==#rows,'Actual HD Battlefields chooser differs from effective registry')
  local listed={};for _,row in ipairs(rows)do listed[row.id]=true end
  local native=0;for _,row in ipairs(rows)do if row.dex and row.dex<=386 then native=native+1 end end
  local expected=0
  if mode=='national'then
   local api=assert(loader.exports.national_dex_gen3)
   for _,row in ipairs(api.listSpecies())do assert(listed[row.id],'Missing species: '..row.id);expected=expected+1 end
   for _,row in ipairs(api.listForms())do assert(listed[row.id],'Missing form: '..row.id);expected=expected+1 end
   assert(loader.exports['gen3-hd-sprites'].isActive(),'HD sprite library did not initialize')
  else
   assert(listed.PECHARUNT,'1025Dex last species missing')
   assert(listed.CHARIZARD_MEGA_X,'1025Dex form missing')
  end
  assert(#rows>=1025 and slots[7]=='SQUIRTLE','Native and mod species did not share one catalog')
  local maps={};for id,def in pairs(game.data.maps)do maps[#maps+1]={id=id,mapType=def.mapType,tileset=def.tileset,kind=def.kind,layoutId=def.layoutId}end
  table.sort(maps,function(a,b)return a.id<b.id end)
  for id,signature in pairs(assert(loadfile(project..'/metadata/maps/frlg.lua'))())do
   assert(game.data.maps[id]and game.data.maps[id].mapType==signature.mapType,'Unverified native map signature '..id)
  end
  write('maps.json',Json.encode(maps));write('species.json',Json.encode(rows))
  local Encounters=require('src.core.game3.encounters');Encounters.loadFromMod()
  local Space=require('src.core.game3.scripting.space');Space.ensureBundle()
  local inspect=assert(io.open(research..'/native-inspection-'..version..'.json','wb'))
  inspect:write(Json.encode({encounters=Encounters._tables,events=Space.bundle.events,scripts=Space.bundle.scripts}));inspect:close()
  if os.getenv('HDB_RENDER')=='1'then
   local Battle=require('src.core.game3.battle')
   local Ui=require('src.core.game3.battle.ui')
   local Display=require('src.core.game3.display')
   local player={species=7,level=10,personality=1,ivs={31,31,31,31,31,31},evs={}}
   Pokemon.applyStats(player,game.session);player.hp=player.maxHp;player.moves,player.pp,player.maxPp=Pokemon.movesAtLevel(7,10)
   game.session.party={player};game.session.map='FR_ROUTE_1'
   -- Stage the command screen after native construction; no turn simulation.
   local Anim=require('src.core.game3.battle.anim')
   local function start(species)
    Battle.reset()
    assert(Battle.start{playerParty=game.session.party,foe={species=species,level=7},wild=true,
     session=game.session,cache=cache,mapType='outdoor',fade=false})
    Anim.reset{headless=true};Anim._headless=false;Anim.syncDisplayFromState(Battle.getState())
    Ui.reset{};Ui.bindState(Battle.getState(),game.session);Ui.openMenu(0)
   end
   start(19)
   local G=love.graphics
   local function render(w,h,name,expect)
    G.setCanvas();local ww,wh=G.getDimensions();assert(ww==w and wh==h,'Use a fresh process for each size; resetting the display clears third-party GPU textures')
    for i=1,2 do Display.present(game,w,h)end
    assert(not Display.planesBroken,'Native presentation failed')
    assert(not hdmod.sceneryAdapterError,hdmod.sceneryAdapterError)
    if expect then
     local d=hdmod.diagnostics()
     if os.getenv('HDB_BASE_ONLY')=='1'and expect~='grassland'then assert(d.status=='native fallback',Json.encode(d))
     else assert(d.status=='active'and d.environment==expect,Json.encode(d))end
    end
    if name then
     local captured=false
     G.captureScreenshot(function(image)write(name..'.png',image:encode('png'):getString());captured=true end)
     G.present();assert(captured,'No completed frame')
    end
   end
   local Chrome=require('src.ui.game3.battle_chrome')
   local Healthbox=require('src.core.game3.battle.healthbox')
   local trace={};local panel=Chrome.drawPanel;local hb=Healthbox.draw
   Chrome.drawPanel=function(kind,...)trace[#trace+1]='panel:'..tostring(kind);return panel(kind,...)end
   Healthbox.draw=function(side,...)
    local x,y=G.transformPoint(0,0);trace[#trace+1]='hb:'..tostring(side)..':'..x..':'..y
    return hb(side,...)
   end
   options.modOptions['hd-dynamic-battlefields'].enabled=false;render(probeW,probeH,'native-baseline')
   local before=table.concat(trace,'\n');trace={}
   options.modOptions['hd-dynamic-battlefields'].enabled=true;render(probeW,probeH,'battle','grassland')
   if mode=='national'then write('hd-stats.json',Json.encode(loader.exports['gen3-hd-sprites'].stats()))end
   assert(before==table.concat(trace,'\n'),'Native healthbox/menu calls changed')
   assert(hdmod.applyAdjustments({species={[version..':SQUIRTLE']={player={pokemon_x=2/240,pokemon_y=-3/160}},[version..':RATTATA']={opponent={pokemon_x=-4/240,pokemon_y=1/160}}}}))
   trace={};render(probeW,probeH,'species-adjusted','grassland')
   assert(before==table.concat(trace,'\n'),'Species corrections changed native UI calls')
   local x,y=hdmod.battlefieldScenery.spriteOffset('player',7);assert(x==2 and y==-3)
   x,y=hdmod.battlefieldScenery.spriteOffset('opponent',19);assert(x==-4 and y==1)
   x,y=hdmod.battlefieldScenery.spriteOffset('player',19);assert(x==0 and y==0)
   assert(hdmod.applyAdjustments({}))
   -- Exercise the actual added species picture, not only a populated menu.
   local special
   for _,row in ipairs(rows)do if row.id=='PECHARUNT'then special=row end end
   assert(special and special.slot)
   start(special.slot)
   local pic=Ui.sidePic(false,false,special.slot,nil,false,0);assert(pic and pic.image,'Added species picture unavailable')
   assert(hdmod.applyAdjustments({species={[version..':PECHARUNT']={opponent={pokemon_x=3/240,pokemon_y=-2/160}}}}))
   render(probeW,probeH,'added-species','grassland')
   x,y=hdmod.battlefieldScenery.spriteOffset('opponent',special.slot);assert(x==3 and y==-2)
   start(19)
   assert(hdmod.applyAdjustments({}))
   local Menu=require('src.ui.game3.option_menu')
   Menu.show{game=game,session=game.session}
   local function select(id)
    local p=Menu._pages[#Menu._pages]
    for i,row in ipairs(p.rows)do if row.id==id then p.index=i;Menu.confirm();return end end
    error('Missing native menu row '..id)
   end
   select('hd_group_root');select('hd_group_mounds');select('hd_group_species');select('hd_group_species_player');select('hd_species_choose_player')
   assert(#Menu._pages[#Menu._pages].rows==#rows,'Native FR/LG chooser dropped species')
   select('hd_species_pick_playerPECHARUNT')
   local page=Menu._pages[#Menu._pages]
   for i,row in ipairs(page.rows)do if row.id=='hd_species_playerpokemon_x'then page.index=i;Menu.adjust(1)end end
   assert(math.abs(hdmod.getAdjustments().species[version..':PECHARUNT'].player.pokemon_x-1/240)<1e-12)
   select('hd_species_reset_player');assert(not next(hdmod.getAdjustments().species))
   Menu.close()
   local scenarios={
    {'FR_ROUTE_1','grassland'}, {'FR_VIRIDIAN_FOREST','forest'},
    {'FR_DIGLETTS_CAVE_B1F','cave'}, {'FR_SSANNE_2F_CORRIDOR','ship_corridor'},
    {'FR_CERULEAN_CITY_GYM','gym_water'}, {'FR_FOUR_ISLAND_ICEFALL_CAVE_BACK','seafoam_cave'},
    {'FR_FIVE_ISLAND_ROCKET_WAREHOUSE','rocket_hideout'}, {'FR_SIX_ISLAND_PATTERN_BUSH','forest'},
    {'FR_SEVEN_ISLAND_SEVAULT_CANYON','rocky_terrain'}}
   local checks={}
   for _,s in ipairs(scenarios)do
    game.session.map=s[1];assert(game.data.maps[s[1]],s[1])
    render(probeW,probeH,nil,s[2]);checks[#checks+1]={map=s[1],width=probeW,height=probeH,environment=s[2]}
   end
   local Background=require('src.core.game3.battle.bg')
   Battle.getState().terrain=Background.env().TERRAIN.WATER
   for _,s in ipairs({{'FR_ROUTE_21_NORTH','ocean'},{'FR_SEAFOAM_ISLANDS_B4F','cave_water'},{'FR_CERULEAN_CITY_GYM','gym_water'}})do
    game.session.map=s[1];render(probeW,probeH,nil,s[2])
    checks[#checks+1]={map=s[1],width=probeW,height=probeH,environment=s[2],water=true}
   end
   local flow
   if os.getenv('HDB_BATTLE_FLOW')=='1'then
    local function flowRender(w,h,name)
     trace={};render(w,h,name);return table.concat(trace,'\n')
    end
    flow=assert(loadfile(project..'/tools/rse_native_probe/battle_flow.lua'))()(project,game,Battle,cache,{exports=hdmod},
     options.modOptions['hd-dynamic-battlefields'],flowRender,probeW,probeH,false)
   end
   write('render.json',Json.encode({checks=checks,battle_flow=flow,native_ui_trace_unchanged=true,scoped_native_pixel_offsets=true,native_species_menu=true,
    scope='Native battle constructor and staged command screen; not gameplay traversal or turn simulation.'}))
  end
  write('result.json',Json.encode({runtime=runtimeVersion,game=version,mode=mode,loaded=enabled,species=#rows,mod_species_and_forms=expected,asset_manager_ready=assetsReady,
   dex_source=roots['1025dex'],scope='Actual local source through official Loader/Sandbox; effective registry chooser and native scene checks. Optional automatic trainer flow recorded separately; no live save writes or publication claim.'}))
 end,debug.traceback)
 if not ok then write('error.txt',err)end
 love.event.quit(ok and 0 or 1)
end
