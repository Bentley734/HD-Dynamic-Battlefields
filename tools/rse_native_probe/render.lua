return function(project,game,Battle,cache,write,resizeWindow)
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
 local doubleFixture=os.getenv('HDB_DOUBLE')=='1'
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
 if os.getenv('HDB_PACK_FIXTURE')then
  local api=mod.exports.assetPacks
  local files={}
  for _,pack in ipairs(api.library.packs)do for _,f in ipairs(pack.files)do
   local bytes=api.store:read(pack,f.path)
   files[#files+1]={path=f.path,expected_size=f.size,size=bytes and #bytes or -1,expected_hash=f.sha256,hash=bytes and love.data.encode('string','hex',love.data.hash('sha256',bytes))}
  end end
  write(version..'-installed-pack-status.json',Json.encode({health=api.library.health,error=api.library.error,revision=api.library.revision,files=files}))
 end
 local function start(map,species)
  species=species or foeSpecies
  if map=='UNDERWATER_ROUTE124'and version~='emerald'then map='UNDERWATER1'end
  Battle.reset();game.session.map=prefix..map
  if doubleFixture and not game.session.party[2]then
   local partner={species=assert(Pokemon.speciesFromName('TORCHIC')),level=10,personality=2,ivs={31,31,31,31,31,31},evs={}}
   Pokemon.applyStats(partner,game.session);partner.hp=partner.maxHp
   partner.moves,partner.pp,partner.maxPp=Pokemon.movesAtLevel(partner.species,10)
   game.session.party[2]=partner
  end
  local foe=doubleFixture and{party={{species=species,level=7},{species=assert(Pokemon.speciesFromName('ZIGZAGOON')),level=7}}}or{species=species,level=7}
  assert(Battle.start{playerParty=game.session.party,foe=foe,wild=not doubleFixture,double=doubleFixture,
   trainerClass=doubleFixture and 1 or nil,trainerClassName=doubleFixture and'TRAINER'or nil,trainerName=doubleFixture and'PROBE'or nil,
   session=game.session,cache=cache,mapType=game.data.maps[game.session.map].mapType,mapKind='outdoor',terrain=0,fade=false})
  if doubleFixture then
   local st=Battle.getState();assert(st.double and st.battlers)
   for id=0,3 do assert(st.battlers[id]and st.battlers[id].mon,'Missing doubles fixture battler '..id)end
  end
  Anim.reset{headless=true,double=doubleFixture};Anim._headless=false;Anim.syncDisplayFromState(Battle.getState())
  Ui.reset{};Ui.bindState(Battle.getState(),game.session);Ui.openMenu(0)
  assert(Ui.sidePic(true,true,Pokemon.speciesOf(game.session.party[1])), 'Missing native player picture')
  assert(Ui.sidePic(false,true,species), 'Missing opponent picture')
 end
 local function render(w,h,name)
  assert(G.getDimensions()==w,'Native window dimensions differ from requested render size')
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
 local cases={{'ROUTE101','grassland','day'},{'ROUTE113','ashfield','day'},{'ROUTE113','ashfield','night'},{'ROUTE119','rainforest','day'},{'ROUTE119','rainforest','night'},{'ROUTE111','desert','day',2},{'ROUTE111','desert','night',2},{'UNDERWATER_ROUTE124','underwater_ocean','day','UNDERWATER','day','rain'},{'UNDERWATER_ROUTE124','underwater_ocean','night','UNDERWATER','day','snow'},{'METEOR_FALLS_1F_1R','meteor_falls','day','CAVE'}}
 if os.getenv('HDB_ALL_AREAS')=='1'then
  local catalog=assert(loadfile(project..'/metadata/rse.lua'))()
  local signatures=assert(loadfile(project..'/metadata/maps/rse.lua'))()[version]
  local available,chosen={},{}
  for _,entry in ipairs(catalog.compositions)do
   available[entry.environment]=available[entry.environment]or entry
  end
  local ids={};for id in pairs(signatures)do ids[#ids+1]=id end;table.sort(ids)
  local function add(id,environment,terrain)
   if chosen[environment]or not available[environment]then return end
   chosen[environment]=true
   local entry=available[environment]
   cases[#cases+1]={id:sub(#prefix+1),environment,'day',terrain}
   if entry.backgrounds and entry.backgrounds.night then
    cases[#cases+1]={id:sub(#prefix+1),environment,'night',terrain}
   end
  end
  cases={}
  for _,id in ipairs(ids)do
   local signature=signatures[id]
   add(id,signature.environment,'BUILDING')
   if signature.water then add(id,signature.water,signature.water=='underwater_ocean'and'UNDERWATER'or'WATER')end
   for terrain,environment in pairs(signature.terrain_overrides or{})do add(id,environment,terrain)end
  end
  -- Scripted legendary terrain must resolve independently from ordinary
  -- encounter tables and the representative BUILDING fixture above.
  for _,special in ipairs({{'MARINE_CAVE_END','POND','KYOGRE'},{'MARINE_CAVE_END','KYOGRE','KYOGRE'},
    {'TERRA_CAVE_END','GROUDON','GROUDON'},{'SKY_PILLAR_TOP','RAYQUAZA','RAYQUAZA'}})do
   local signature=signatures[prefix..special[1]]
   if signature and available[signature.environment]then
    cases[#cases+1]={special[1],signature.environment,'day',special[2],nil,nil,special[2]:lower(),special[3]}
   end
  end
 end
 -- Map lifecycle starts Emerald's Maxie/Tabitha encounter on the upper floor.
 if version=='emerald'then cases[#cases+1]={'MOSSDEEP_CITY_SPACE_CENTER_2F','space_center','day','BUILDING'}end
 local requested=os.getenv('HDB_REVIEW_FAMILIES')or''
 if requested~=''then
  local allowed,found,filtered={},{},{}
  for family in requested:gmatch('[^,]+')do allowed[family]=true end
  for _,case in ipairs(cases)do
   if allowed[case[2]]then filtered[#filtered+1]=case;found[case[2]]=true end
  end
  for family in pairs(allowed)do assert(found[family],'No mapped review cases for '..family)end
  cases=filtered
 end
 for _,case in ipairs(cases)do
  start(case[1],case[8]and assert(Pokemon.speciesFromName(case[8]))or nil);if case[4]then Battle.getState().terrain=type(case[4])=='string'and require('src.core.game3.battle.bg').env().TERRAIN[case[4]]or case[4]end;values.timeMode=case[3];values.weatherMode=case[6]or'clear'
  for _,size in ipairs({{probeW,probeH,'current'}})do
   local stem=case[2]..'-'..case[3]..'-'..size[3]..(case[7]and'-'..case[7]or'')
   values.enabled=false;local before=render(size[1],size[2],probeW==1280 and stem..'-native'or nil)
   values.enabled=true;local after=render(size[1],size[2],stem)
   assert(before==after,'Scenery changed native healthbox/menu call transforms')
   local d=mod.exports.diagnostics()
   assert(d.status=='active'and d.environment==case[2]and d.period==(case[5]or case[3]),Json.encode(d))
   local installedProof
   if os.getenv('HDB_PACK_FIXTURE')and case[2]=='ocean'then
    local fixture=Json.decode(assert(file(os.getenv('HDB_PACK_FIXTURE')..'/fixture.json')))
    assert(d.pack==fixture.pack_id,'Fixture did not select installed scenery')
    assert(mod.exports.assetPacks.library.health[fixture.pack_id].valid,'Installed pack failed real runtime verification')
    local image,x,y,scale,origin=mod.exports.battlefieldScenery.nativeMound('opponent')
    local profile=assert(loadfile(project..'/metadata/native_rse.lua'))()[version]
    profile=doubleFixture and profile.double or profile
    local materialPath=(d.period=='night'and fixture.night_mounds or fixture.mounds).opponent
    local rule=assert(assert(loadfile(project..'/metadata/mound_materials.lua'))()[materialPath])
    assert(y==profile.opponent.y+rule.offset_y and origin[2]==rule.origin[2],'Installed material placement correction missing')
    local wanted=math.min(profile.opponent.width*rule.scale/image:getWidth(),profile.opponent.height*rule.scale/image:getHeight())
    assert(math.abs(scale-wanted)<1e-8,'Installed material coverage correction missing')
    installedProof={pack=d.pack,verified=true,native_y=y,scale=scale,origin_y=origin[2]}
   end
   if case[6]then assert(d.weather=='clear','Outdoor weather leaked underwater')end
   local hd=loader and loader.exports['gen3-hd-sprites']
   local stats=hd and hd.stats()
   checks[#checks+1]={map=case[1],native_map=game.session.map,environment=d.environment,period=d.period,width=size[1],height=size[2],
    aspect=d.aspect,composition=d.composition,metadata=d.metadata,native_ui_calls_unchanged=true,installed_pack=installedProof,
    hd_fit=stats and{dropPlayer=stats.dropPlayer,raisePlayer=stats.raisePlayer,zoom=stats.zoom}or nil}
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
 local resize
 if os.getenv('HDB_RESIZE')=='1'then
  resize=assert(loadfile(project..'/tools/rse_native_probe/resize.lua'))()(game,Battle,mod,values,start,render,probeW,probeH,resizeWindow,content=='1025'and function()for _=1,240 do loader.hooks:call('core.update',function()end,game,1/60)end end or nil)
 end
 local presentationTransitions
 if os.getenv('HDB_TRANSITIONS')=='1'then
  presentationTransitions=assert(loadfile(project..'/tools/rse_native_probe/transitions.lua'))()(project,game,Battle,mod,values,start,render,probeW,probeH)
 end
 local moveEffects
 if os.getenv('HDB_MOVE_EFFECTS')=='1'then
  moveEffects=assert(loadfile(project..'/tools/rse_native_probe/move_effects.lua'))()(project,game,Battle,mod,values,start,render,probeW,probeH)
 end
 local battleFlow
 if os.getenv('HDB_BATTLE_FLOW')=='1'then
  battleFlow=assert(loadfile(project..'/tools/rse_native_probe/battle_flow.lua'))()(project,game,Battle,cache,mod,values,render,probeW,probeH,doubleFixture)
 end
 local nativeMenuVerified=false
 local assetNavigationVerified=false
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
  while #pages()>2 do Menu.back()end
  press('hd_group_assets')
  local assetsPage=pages()[#pages()]
  press('hd_assets_aspect');press('hd_assets_pick_aspect16:9')
  assert(pages()[#pages()]==assetsPage,'Size choice left asset downloader')
  press('hd_assets_variations');press('hd_assets_variations_one')
  assert(pages()[#pages()]==assetsPage,'Variation choice left asset downloader')
  press('hd_assets_progress')
  local statusPage=pages()[#pages()]
  press('hd_assets_error');assert(pages()[#pages()]==statusPage,'Error row navigated back')
  press('hd_assets_progress_detail');assert(pages()[#pages()]==statusPage,'Progress row navigated back')
  Menu.back();assert(pages()[#pages()]==assetsPage)
  Menu.draw()
  Menu.close();nativeMenuVerified=true;assetNavigationVerified=true
 end
 start('ROUTE101');values.weatherMode='clear'
 local Rtc=require('src.core.game3.rtc')
 local savedHour=Rtc.localTime.hours
 Rtc.localTime.hours=23;values.timeMode='auto'
 render(probeW,probeH,nil)
 assert(mod.exports.diagnostics().period=='night'and mod.exports.diagnostics().timeSource=='game',
  'Hoenn native RTC was not used by the scenery provider')
 Rtc.localTime.hours=savedHour;values.timeMode='day'
 -- Field fog is atmosphere even when it does not alter battle mechanics.
 start('MT_PYRE_SUMMIT');values.enabled=true;values.weatherMode='auto'
 local savedWeather=game.session.savedWeather
 game.session.savedWeather=6;Battle.getState().weather=nil
 render(probeW,probeH,nil)
 assert(mod.exports.diagnostics().weather=='fog','Native summit field fog was not forwarded')
 Battle.getState().weather='rain';render(probeW,probeH,nil)
 assert(mod.exports.diagnostics().weather=='rain','Battle weather must override field fog')
 game.session.savedWeather=savedWeather;values.weatherMode='clear'
 -- An intentionally absent fixture family must keep native terrain.
 start('ROUTE111');Battle.getState().terrain=2;values.enabled=true;values.environment='__missing_hoenn_fixture__'
 render(probeW,probeH,nil)
 assert(mod.exports.diagnostics().status=='native fallback','Missing fixture family must retain native scenery')
 write(version..'-'..probeW..'x'..probeH..'-render.json',Json.encode({game=version,checks=checks,expected_scene_checks=#cases+(content~='none'and 1 or 0),all_areas=os.getenv('HDB_ALL_AREAS')=='1',missing_family_native_fallback=true,native_clock_verified=true,
  real_loader=loaderMode,candidate_manifest_allowlist=loaderMode,native_options_verified=nativeMenuVerified,asset_downloader_navigation_verified=assetNavigationVerified,native_field_weather_verified=true,
  loaded_mods=loadedMods,mod_versions=modVersions,species_choices=speciesCount,content=content,double_fixture=doubleFixture,presentation_transitions=presentationTransitions,move_effects=moveEffects,battle_flow=battleFlow,
  resize=resize,saves_written=false,scope=(loaderMode and'Real Loader/Sandbox with candidate game allowlist; native options; limited scenes/sizes. 'or'Native engine with direct mod entry; no real Loader coverage. ')..
   (doubleFixture and'Four-battler trainer fixture; no full turn/animation sequence coverage. 'or'Doubles not covered. ')..'No exhaustive custom UI or sprite-profile coverage.'}))
end
