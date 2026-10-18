return function(project,game,Battle,cache,write)
 local G=love.graphics
 G.setDefaultFilter('nearest','nearest')
 local Ui=require('src.core.game3.battle.ui')
 local Anim=require('src.core.game3.battle.anim')
 local Display=require('src.core.game3.display')
 local Chrome=require('src.ui.game3.battle_chrome')
 local Healthbox=require('src.core.game3.battle.healthbox')
 local Json=require('src.link.Json')
 local Pokemon=require('src.core.game3.pokemon')
 local foeSpecies=assert(Pokemon.speciesFromName('POOCHYENA'))
 local version=game.session.version
 local content=os.getenv('HDB_CONTENT_MODE')or'none'
 local prefix=({ruby='RU_',sapphire='SA_',emerald='EM_'})[version]
 local probeW,probeH=G.getDimensions()
 local function file(path)local f=io.open(path,'rb');if not f then return end;local b=f:read('*a');f:close();return b end
 local values={enabled=false,environment='auto',selection='fixed',timeMode='day',weatherMode='clear',animation='off',
  mounds=true,quality='HD',aspect='auto'}
 local mod={id='hd-dynamic-battlefields',path=project,game=game,exports={},
  assets={path=function(_,p)return project..'/'..p end},
  cache={read=function()end,write=function()return true end},events={on=function()end},
  storage={read=function()end,write=function()return true end},find=function()end,
  options={define=function()end,get=function(_,key)return values[key]end}}
 function mod:read(path)
  if path=='lib/settings.lua'then return'return function()end'end
  return file(project..'/'..path)
 end
 function mod:info(path)local b=file(project..'/'..path);if b then return{type='file',size=#b}end end
 local trace={}
 local panel,healthbox=Chrome.drawPanel,Healthbox.draw
 Chrome.drawPanel=function(kind,...)
  local x,y=G.transformPoint(0,0);trace[#trace+1]='panel:'..tostring(kind)..':'..x..':'..y
  return panel(kind,...)
 end
 Healthbox.draw=function(side,...)
  local x,y=G.transformPoint(0,0);trace[#trace+1]='healthbox:'..tostring(side)..':'..x..':'..y
  return healthbox(side,...)
 end
 local loader,loadedMods,speciesCount,modVersions
 local loaderMode=os.getenv('HDB_LOADER')=='1'
 if loaderMode then
  mod,loader,loadedMods,speciesCount,modVersions=assert(loadfile(project..'/tools/rse_native_probe/loader.lua'))()(project,game,values)
 else
  assert(loadfile(project..'/main.lua'))()(mod)
 end
 local checks={}
 local function start(map,species)
  species=species or foeSpecies
  Battle.reset();game.session.map=prefix..map
  assert(Battle.start{playerParty=game.session.party,foe={species=species,level=7},wild=true,
   session=game.session,cache=cache,mapType=3,mapKind='outdoor',terrain=0,fade=false})
  Anim.reset{headless=true};Anim._headless=false;Anim.syncDisplayFromState(Battle.getState())
  Ui.reset{};Ui.bindState(Battle.getState(),game.session);Ui.openMenu(0)
  assert(Ui.sidePic(true,true,Pokemon.speciesOf(game.session.party[1])), 'Missing native player picture')
  assert(Ui.sidePic(false,true,species), 'Missing opponent picture')
 end
 local function render(w,h,name)
  assert(G.getDimensions()==w,'Use a fresh fixture process per size')
  if content~='none'then for _=1,120 do Display.present(game,w,h);loader.hooks:call('core.update',function()end,game,1/60) end end
  G.setCanvas();G.origin();G.clear(.04,.04,.04,1);trace={}
  for _=1,2 do Display.present(game,w,h)end
  assert(not Display.planesBroken,'Native display planes failed')
  assert(not mod.exports.sceneryAdapterError,mod.exports.sceneryAdapterError)
  if name then
   local captured=false
   G.captureScreenshot(function(pixels)write(version..'-'..w..'x'..h..'-'..name..'.png',pixels:encode('png'):getString());pixels:release();captured=true end)
   G.present();assert(captured)
  end
  return table.concat(trace,'\n')
 end
 for _,case in ipairs({{'ROUTE101','grassland','day'},{'ROUTE113','ashfield','day'},{'ROUTE113','ashfield','night'},{'ROUTE119','rainforest','day'},{'ROUTE119','rainforest','night'}})do
  start(case[1]);values.timeMode=case[3]
  for _,size in ipairs({{probeW,probeH,'current'}})do
   local stem=case[2]..'-'..case[3]..'-'..size[3]
   values.enabled=false;local before=render(size[1],size[2],probeW==1280 and stem..'-native'or nil)
   values.enabled=true;local after=render(size[1],size[2],stem)
   assert(before==after,'Scenery changed native healthbox/menu call transforms')
   local d=mod.exports.diagnostics()
   assert(d.status=='active'and d.environment==case[2]and d.period==case[3],Json.encode(d))
   checks[#checks+1]={map=case[1],environment=d.environment,period=d.period,width=size[1],height=size[2],
    aspect=d.aspect,composition=d.composition,native_ui_calls_unchanged=true}
  end
 end
 if content~='none'then
  local added
  for _,row in ipairs(mod.exports.getSpeciesChoices())do if row.id=='PECHARUNT'then added=row end end
  assert(added and added.slot,'Missing added species slot')
  start('ROUTE101',added.slot);values.timeMode='day'
  -- Advance asynchronous sprite providers through their real update hook.
  for _=1,240 do loader.hooks:call('core.update',function()end,game,1/60);Pokemon.frontPic(added.slot) end
  local pic=assert(Ui.sidePic(false,false,added.slot),'Missing added sprite')
  local canvas=G.newCanvas(pic.image:getWidth(),pic.image:getHeight())
  G.push('all');G.setCanvas(canvas);G.clear(0,0,0,0);G.setShader();G.setColor(1,1,1,1);G.origin();G.draw(pic.image);G.pop()
  local pixels=canvas:newImageData();local visible=false
  for y=0,pixels:getHeight()-1 do for x=0,pixels:getWidth()-1 do local _,_,_,a=pixels:getPixel(x,y);if a>0 then visible=true;break end end;if visible then break end end
  pixels:release();canvas:release()
  assert(visible,'Added sprite is transparent; verify content asset-pack installation before claiming sprite compatibility')
  values.enabled=false;local before=render(probeW,probeH,nil)
  values.enabled=true;local after=render(probeW,probeH,'added-PECHARUNT')
  assert(before==after,'Added species scenery changed native healthbox/menu transforms')
  local d=mod.exports.diagnostics();assert(d.status=='active'and d.opponentSpecies=='PECHARUNT',Json.encode(d))
  checks[#checks+1]={map='ROUTE101',environment=d.environment,period=d.period,width=probeW,height=probeH,
   aspect=d.aspect,composition=d.composition,species='PECHARUNT',native_ui_calls_unchanged=true}
 end
 local nativeMenuVerified=false
 if loaderMode then
  local Menu=require('src.ui.game3.screens').get('option',game.session)
  Menu.show{game=game,session=game.session}
  for _=1,40 do Menu.update()end
  local function pages()return Menu._pages or Menu._st and Menu._st.pages end
  local function press(id,key)
   local p=assert(pages())[ #pages() ]
   local found
   for i,row in ipairs(p.rows)do if row.id==id then p.index=i;found=true;break end end
   assert(found,'Native options row missing: '..id)
   Menu.handleInput{wasPressed=function(_,button)return button==(key or'a')end}
  end
  press('hd_group_root');press('hd_group_mounds');press('hd_group_species');press('hd_group_species_player')
  press('hd_species_choose_player');press('hd_species_pick_playerTREECKO')
  press('hd_species_playerpokemon_x','right')
  local x,y=mod.exports.battlefieldScenery.spriteOffset('player',Pokemon.speciesOf(game.session.party[1]))
  local status
  for _,row in ipairs(pages()[#pages()].rows)do if row.id=='hd_species_status_player'then status=row.value{game=game}end end
  assert(x==1 and y==0,'Native menu species offset failed: '..Json.encode({x=x,y=y,status=status,adjustments=mod.exports.getAdjustments()}))
  press('hd_species_reset_player')
  x,y=mod.exports.battlefieldScenery.spriteOffset('player',Pokemon.speciesOf(game.session.party[1]));assert(x==0 and y==0)
  Menu.draw()
  Menu.close();nativeMenuVerified=true
 end
 local Rtc=require('src.core.game3.rtc')
 local savedHour=Rtc.localTime.hours
 Rtc.localTime.hours=23;values.timeMode='auto'
 render(probeW,probeH,nil)
 assert(mod.exports.diagnostics().period=='night'and mod.exports.diagnostics().timeSource=='game',
  'Hoenn native RTC was not used by the scenery provider')
 Rtc.localTime.hours=savedHour;values.timeMode='day'
 -- Unfinished Hoenn scenery keeps its original terrain rather than substituting grass.
 start('ROUTE111');Battle.getState().terrain=2;values.enabled=true
 render(probeW,probeH,nil)
 assert(mod.exports.diagnostics().status=='native fallback','Unfinished desert must retain native scenery')
 write(version..'-'..probeW..'x'..probeH..'-render.json',Json.encode({game=version,checks=checks,missing_family_native_fallback=true,native_clock_verified=true,
  real_loader=loaderMode,candidate_manifest_allowlist=loaderMode,native_options_verified=nativeMenuVerified,
  loaded_mods=loadedMods,mod_versions=modVersions,species_choices=speciesCount,content=content,
  saves_written=false,scope=loaderMode and'Real Loader/Sandbox with candidate game allowlist; native options; limited scenes/sizes. Doubles/animations/custom profiles remain untested.'or'Native engine with direct mod entry; real Loader, UI mods, doubles and animations not yet covered'}))
end
