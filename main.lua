-- Development integration. Native fallback remains authoritative on every
-- unsupported path; the complete production menu/adapter set is still pending.
return function(mod)
 local function module(path)
  local bytes,err=mod:read(path);assert(bytes,err)
  return assert(loadstring(bytes,'@'..mod.path..'/'..path))()
 end
 local Perspective=module('lib/perspective.lua')
 local Compositions=module('lib/compositions.lua')
 local Scene=module('lib/scene.lua')
 local Version=require('src.core.GameVersion')
 local gen2=Version.generation()==2
 local rse=Version.get()=='ruby'or Version.get()=='sapphire'or Version.get()=='emerald'
 local catalog=module(rse and'metadata/rse.lua'or gen2 and'metadata/gen2.lua'or'metadata/prototype.lua')
 local Grounding=module('lib/grounding.lua')
 local frlg=Version.get()=='firered'or Version.get()=='leafgreen'
 local game3=frlg or rse
 local moundMaterials=rse and module('metadata/mound_materials.lua')or nil
 local nativeProfile=rse and module('metadata/native_rse.lua')[Version.get()]or module(frlg and'metadata/native_frlg.lua'or gen2 and'metadata/native_gen2.lua'or'metadata/native_gen1.lua')
 local wideProfile=not game3 and module(gen2 and'metadata/native_gen2_wide.lua'or'metadata/native_gen1_wide.lua')or nil
 local environments=rse and module('lib/environments_rse.lua')(module('metadata/maps/rse.lua'))or gen2 and module('lib/environments_gen2.lua').new(module('metadata/maps/gen2.lua'))or frlg and module('lib/environments_frlg.lua')(module('metadata/maps/frlg.lua'))or module('lib/environments.lua').new(module('metadata/maps/gen1.lua'))
 local Json=require('src.link.Json')
 local Battle=not game3 and require(gen2 and'src.ui.gen2.BattleState'or'src.battle.BattleState')or nil
 local isFishing=not game3 and not gen2 and module('lib/adapters/gen1_context.lua').install(Battle)or function()return false end
 local speciesCatalog=module('lib/species_catalog.lua').new(mod)
 mod.exports.getSpeciesChoices=function()return speciesCatalog:refresh(mod.game)end
 mod.exports.speciesIdentity=function(ref)return speciesCatalog:identity(ref)end
 mod.events:on('mods.loaded',function()speciesCatalog:refresh(mod.game)end,-1000)
 mod.exports.nativeSize=function()return nativeProfile.width,nativeProfile.height end
 local game3Context=frlg and module('lib/adapters/frlg_context.lua')(mod,mod.exports.speciesIdentity)or rse and module('lib/adapters/rse_context.lua')(mod,mod.exports.speciesIdentity)
 local gen2Context=gen2 and module('lib/adapters/gen2_context.lua')(mod,Battle,mod.exports.speciesIdentity)
 local function saveIdentity(game)return game3 and game.session or game.save end
 local g=love.graphics
 local climate=module('lib/climate.lua').new(module('metadata/climate.lua'),os.time,function()return tonumber(os.date('%H'))end)
 local atmosphere=module('lib/atmosphere.lua').new(g,function()return love.timer.getTime()end)
 local drawOptions={atmosphere=atmosphere}
 local assetLibrary
 local scene=Scene.new(g,Perspective,function(path)
  local image=g.newImage(assetLibrary and assetLibrary:path(path)or mod.assets:path(path));image:setFilter('linear','linear');return image
 end,function(path)return assetLibrary and assetLibrary:sourcePath(path)or path end)
 local selection=Compositions.new(catalog.compositions,function(entry)
  return (assetLibrary and assetLibrary:available(entry)or mod:info(entry.background)~=nil)and entry.mounds~=nil
 end)
 local backend=module('lib/runtime_backend.lua')(mod,Perspective)
 local packSchema=module('lib/pack_store.lua')
 local packStore=packSchema.new(backend)
 local assetQueue=module('lib/asset_queue.lua')(packStore)
 local updates=module('lib/asset_updates.lua')(mod,backend,packSchema,module('metadata/asset_index.lua'))
 assetLibrary=module('lib/asset_library.lua')(mod,packStore,Json,selection,catalog,scene)
 local installedIds=mod.cache:read('installed-pack-ids.json')
 local decoded,ids=pcall(Json.decode,installedIds or'[]')
 ids=decoded and type(ids)=='table'and ids or{}
 assetLibrary:refresh(ids)
 mod.exports.assetPacks={store=packStore,library=assetLibrary,updates=updates,queue=assetQueue}
 local function updateAssets()
  updates:update()
  local before=packStore.status;packStore:update()
  if before=='downloading'and packStore.status=='installed'then
   local found=false;for _,id in ipairs(ids)do if id==packStore.pack.id then found=true end end
   if not found then ids[#ids+1]=packStore.pack.id end
   local ok,err=mod.cache:write('installed-pack-ids.json',Json.encode(ids))
   if not ok then assetLibrary.error=err end
   assetLibrary:refresh(ids)
  end
  assetQueue:update()
 end
 local attached=setmetatable({},{__mode='k'})
 local function attachAssets(game)
  if not game or attached[game]then return end;attached[game]=true
  local update=game.update;if not update then return end
  game.update=function(self,dt,...)
   updateAssets();return update(self,dt,...)
  end
 end
 mod.events:on('game.ready',function(event)attachAssets(event.game)end)
 attachAssets(mod.game)
 mod.exports.assetPacks.refresh=function()return assetLibrary:refresh(ids)end
 mod.exports.assetPacks.remove=function(id)
  local ok,err=packStore:remove(id);if not ok then return nil,err end
  local remaining={};for _,value in ipairs(ids)do if value~=id then remaining[#remaining+1]=value end end
  ids=remaining;mod.cache:write('installed-pack-ids.json',Json.encode(ids));return assetLibrary:refresh(ids)
 end
 local diagnostics={stage=rse and'Hoenn development'or'Kanto + Johto Beta',status='disabled',game='unknown'}
 local loadedSave,lastAssignments,loadedAdjustments,lastLayout
 local environmentChoices={{'Automatic','auto'}}
 local environmentLabels={gym_rock='Pewter Gym',gym_water='Cerulean Gym',gym_electric='Vermilion Gym',
  gym_grass='Celadon Gym',gym_poison='Fuchsia Gym',gym_psychic='Saffron Gym',gym_fire='Cinnabar Gym',gym_ground='Viridian Gym',
  elite_four_ice='Lorelei',elite_four_rock='Bruno',elite_four_ghost='Agatha',elite_four_dragon='Lance',
  corporate_interior='Silph Co.',haunted_tower='Pokemon Tower',abandoned_mansion='Pokemon Mansion',
  deep_cave='Cerulean Cave',seafoam_cave='Seafoam Islands',ship_interior='S.S. Anne lounge (unused)',ship_cabin='S.S. Anne cabins',ship_corridor='S.S. Anne corridor',
  ship_bow='S.S. Anne foredeck',ship_kitchen='S.S. Anne galley',ship_captain='S.S. Anne captain cabin',
  pokemon_center='Pokemon Center',shop='Supply shop',
  gatehouse='Route gate',underground_tunnel='Underground passage',
  hotel='Celadon hotel',restaurant='Celadon diner',
  arcade='Celadon Game Corner',prize_room='Game Corner prize counters',
  museum='Pewter fossil gallery',museum_space='Pewter space gallery',
  arena='Link Colosseum',link_room='Communication room',hall_of_fame='Hall of Fame',
  bills_cottage="Bill's cottage",bike_shop='Cerulean Bike Shop',
  mansion_roof='Celadon Mansion rooftop',
  department_roof='Celadon store rooftop',
  silph_lift='Silph Co. lift',
  rocket_lift='Rocket Hideout lift',
  department_training='Celadon training supplies',
  department_gifts='Celadon gifts and stones',
  department_supplies='Celadon trainer supplies',department_electronics='Celadon TV and games',
  department_lobby='Celadon store reception',elevator='Celadon store lift',
  forest_gate='Viridian forest gate',
  league_lobby='League reception',safari_lodge='Safari rest lodge',
  fan_club='Vermilion Fan Club',meeting_room='Fuchsia meeting room',
  league_exterior='Indigo Plateau',league_approach='Route 23 approach',island_town='Cinnabar Island',
  harbor_city='Vermilion City',harbor='Vermilion Dock',
  legendary_mewtwo='Mewtwo chamber',legendary_articuno='Articuno refuge',
  legendary_zapdos='Zapdos generator hall',legendary_moltres='Moltres shelter'}
 local seenEnvironment={}
 for _,entry in ipairs(catalog.compositions)do
  local key=entry.environment
  if not seenEnvironment[key]then
   seenEnvironment[key]=true
   local label=environmentLabels[key]or key:gsub('_',' '):gsub('(%a)([%w]*)',function(first,rest)return first:upper()..rest end)
   environmentChoices[#environmentChoices+1]={label,key}
  end
 end
 table.sort(environmentChoices,function(a,b)
  if a[2]=='auto'then return b[2]~='auto'end
  if b[2]=='auto'then return false end
  return a[1]<b[1]
 end)
 mod.exports.environmentChoices=environmentChoices
 -- Temporary development controls; final grouped OPTIONS screen is a
 -- separate required integration, not replaced by this native mod schema.
 mod.options:define({
  {key='enabled',label='Prototype enabled',type='toggle',default=false},
  {key='selection',label='Variation',type='choice',default='random',choices={{'Random','random'},{'Fixed','fixed'}}},
  {key='environment',label='Environment',type='choice',default='auto',choices=environmentChoices},
  {key='timeMode',label='Time of day',type='choice',default='auto',choices={{'Automatic','auto'},{'System time','system'},{'Day','day'},{'Night','night'}}},
  {key='weatherMode',label='Weather',type='choice',default='auto',choices={{'Automatic','auto'},{'Clear','clear'},{'Rain','rain'},{'Snow','snow'},{'Sandstorm','sandstorm'},{'Fog','fog'},{'Sunlight','sun'}}},
  {key='animation',label='Animation quality',type='choice',default='medium',choices={{'Off','off'},{'Low','low'},{'Medium','medium'},{'High','high'}}},
  {key='mounds',label='Battle mounds',type='toggle',default=true},
  {key='quality',label='Texture quality',type='choice',default='HD',choices={{'Original HD','HD'}}},
  {key='aspect',label='Artwork aspect',type='choice',default='auto',choices={{'Automatic','auto'},{'4:3','4:3'},{'16:9','16:9'},{'16:10','16:10'},{'3:2','3:2'},{'21:9','21:9'},{'32:9','32:9'},{'9:16','9:16'},{'9:19.5','9:19.5'},{'9:20','9:20'}}},
  {key='calibration',label='Calibration guides',type='toggle',default=false},
 })
 local function fallback(reason)
  diagnostics.status='native fallback';diagnostics.reason=reason
  diagnostics.composition,diagnostics.metadata,diagnostics.uiPhase,diagnostics.uiRegion=nil,nil,nil,nil
  return false
 end
 mod.exports.diagnostics=function()return Json.decode(Json.encode(diagnostics))end
 mod.exports.apiVersion=1
 mod.exports.getAdjustments=function()
  local game=mod.game
  if not game or not saveIdentity(game)then return {}end
  local value=saveIdentity(game)==loadedSave and loadedAdjustments or mod.storage:read(game,'anchor-adjustments')
  if not Perspective.validateAdjustments(value)then return {}end
  return Json.decode(Json.encode(value or{}))
 end
 mod.exports.resetAssignments=function()
  local game=mod.game;if not game or not saveIdentity(game)then return nil,'No active playthrough'end
  local ok,err=mod.storage:write(game,'fixed-assignments',{})
  if not ok then return nil,err end
  selection:resetAssignments();lastAssignments=Json.encode({});return true
 end
 mod.exports.applyAdjustments=function(adjustments)
  local valid,why=Perspective.validateAdjustments(adjustments);if not valid then return nil,why end
  local game=mod.game;if not game or not saveIdentity(game)then return nil,'No active playthrough'end
  local copied=Json.decode(Json.encode(adjustments or{}))
  local ok,err=mod.storage:write(game,'anchor-adjustments',copied)
  if not ok then return nil,err end
  loadedAdjustments=copied;return true
 end
 mod.exports.exportCalibration=function()
  if not lastLayout or not scene.metadata then return nil,'Render a supported battlefield before exporting'end
  local c=lastLayout.canvas
  local draft=Json.decode(Json.encode(scene.metadata))
  -- The export is an explicit scenery draft: native sprite contact slots
  -- remain authoritative and are not applied back onto the battle renderer.
  for _,side in ipairs({'player','opponent'})do
   local mound=lastLayout[side].mound
   draft[side].mound_anchor={(mound.x-c.x)/c.width,(mound.y-c.y)/c.height}
   draft[side].mound_bounds={mound.bounds[1]/c.width,mound.bounds[2]/c.height}
   draft[side].mound_scale=mound.scale
  end
  local valid,why=Perspective.validate(draft);if not valid then return nil,why end
  local envelope={schema_version=1,kind='scenery-calibration-draft',composition=diagnostics.composition,
   viewport=lastLayout.viewport,metadata=draft,adjustments=mod.exports.getAdjustments(),
   note='Scenery only. Native sprite and UI positions are preserved.'}
  local path='exports/calibration-'..tostring(os.time())..'.json'
  local ok,err=mod.cache:write(path,Json.encode(envelope));if not ok then return nil,err end
  diagnostics.lastExport='mod_cache/'..mod.id..'/'..path
  return true,diagnostics.lastExport
 end
 mod.exports.release=function()
  lastLayout=nil;scene:release()
 end
 mod.events:on('battle.ended',function()mod.exports.release();diagnostics.status='idle'end)
 -- Scenery provider only. The consuming UI mod owns composition, sprites,
 -- effects, fonts, HUDs and every panel. Never claim render.compose.
 local provider={apiVersion=1}
 mod.exports.battlefieldScenery=provider
 function provider.enabled()return mod.options:get('enabled')==true end
 function provider.prepare(x,y,width,height,nativeFrame,presentation)
  if not mod.options:get('enabled')then diagnostics.status='disabled';return false end
  if Version.generation()~=1 and not gen2 and not game3 then return fallback('Generation adapter not integrated')end
  local game=mod.game;local context,contextError
  if game3 then context,contextError=game3Context();if not context then return fallback(contextError)end end
  if gen2 then context,contextError=gen2Context();if not context or context.tutorial then return fallback(contextError or'Native tutorial presentation')end end
  local battle=context and context.battle or game and game.stack and game.stack:top()
  if not battle or(not game3 and not gen2 and getmetatable(battle)~=Battle)then return fallback('Native overlay or non-battle state')end
  if battle.kind=='link'or context and context.link then return fallback('Link presentation is not yet validated')end
  local v={x=x or 0,y=y or 0,width=width,height=height}
  if not width or not height or width<=0 or height<=0 then return fallback('Missing battle viewport')end
  local map=context and context.map or game.save and game.save.player and game.save.player.map
  local manual=mod.options:get('environment')
  local mover=game.overworld and game.overworld.player
  local mapData=game.data and game.data.maps and game.data.maps[map]
  local detected,classificationError=environments:detect({game=Version.get(),map=map,tileset=context and context.tileset or mapData and mapData.tileset,
   mapType=context and context.mapType,water=context and context.water,
   mapBattleType=context and context.mapBattleType,terrainName=context and context.terrainName,
   fishing=context and context.fishing or isFishing(battle),
   surfing=context and context.surfing or game.save and game.save.player and game.save.player.surfing==true or mover and mover.surfing==true,
   kind=context and context.kind or battle.kind,enemySpecies=context and context.enemySpecies or battle.enemy and battle.enemy.mon and battle.enemy.mon.species})
  local environment=manual~='auto'and manual or detected and detected.environment
  diagnostics.classificationError=manual=='auto'and classificationError or nil
  diagnostics.waterSource=isFishing(battle)and'fishing'or(detected and detected.water and'surfing'or nil)
  -- Safari shares the native battle metatable and scenery insertion path.
  -- Its trainer, ball counter and command panels remain the consumer's UI.
  if battle.demo then environment=nil end
  diagnostics.game,diagnostics.map,diagnostics.environment,diagnostics.viewport=Version.get(),map,environment,v
  diagnostics.playerSpecies=context and context.playerSpecies or battle.player and battle.player.mon and battle.player.mon.species
  diagnostics.opponentSpecies=context and context.enemySpecies or battle.enemy and battle.enemy.mon and battle.enemy.mon.species
  if saveIdentity(game)~=loadedSave then
   loadedSave=saveIdentity(game);local saved=mod.storage:read(game,'fixed-assignments')
   selection:importAssignments(type(saved)=='table'and saved or{})
   lastAssignments=Json.encode(selection:exportAssignments())
   loadedAdjustments=mod.storage:read(game,'anchor-adjustments')
   if not Perspective.validateAdjustments(loadedAdjustments)then
    loadedAdjustments=nil;diagnostics.persistenceError='Invalid saved adjustments; using recommended anchors'
   end
  end
  local state=climate:resolve(environment,mod.options:get('timeMode'),mod.options:get('weatherMode'),mod.options:get('animation'),
   {battleWeather=context and context.weather or battle.field and battle.field.weather,
    mapWeather=context and context.mapWeather,timeOfDay=context and context.timeOfDay})
  diagnostics.period,diagnostics.timeSource,diagnostics.weather,diagnostics.animation=state.period,state.timeSource,state.weather,state.level
  drawOptions.climate,drawOptions.tint=state,state.tint
  local entry,why=selection:choose(battle,{game=Version.get(),map=map,environment=environment},v,{mode=mod.options:get('selection'),aspect=mod.options:get('aspect'),quality=mod.options:get('quality')})
  if not entry then return fallback(why)end
  if not scene.entry or scene.entry.id~=entry.id or scene.period~=state.period then
   local ok,err=scene:prepare(entry,catalog.metadata,state.period);if not ok then return fallback(err)end
  end
  local layout,err=scene:layout(v,loadedAdjustments)
  if not layout then return fallback(err)end
  -- Apply user calibration relative to the unmodified authored layout,
  -- then place scenery at the consumer's existing native contact slots.
  local baseline=assert(scene:layout(v))
  local activeProfile=context and context.double and nativeProfile.double or nativeProfile
  local grounded,why=Grounding.apply(layout,baseline,presentation=='wide'and wideProfile or activeProfile,nativeFrame,moundMaterials,scene.moundSourcePaths)
  if not grounded then return fallback(why)end
  local assignments=Json.encode(selection:exportAssignments())
  if assignments~=lastAssignments then
   local saved,saveErr=mod.storage:write(game,'fixed-assignments',selection:exportAssignments())
   if saved then lastAssignments=assignments else diagnostics.persistenceError=saveErr end
  end
  diagnostics.status,diagnostics.reason='active',nil
  diagnostics.game,diagnostics.map,diagnostics.environment=Version.get(),map,environment
  diagnostics.composition,diagnostics.metadata=entry.id,scene.metadata.composition_id
  diagnostics.pack=entry.pack_id or'bundled prototype'
  diagnostics.quality,diagnostics.aspect=entry.quality,entry.aspect_ratio
  diagnostics.assetError=assetLibrary.error
  diagnostics.viewport=v
  diagnostics.double=context and context.double or false
  lastLayout=layout
  return layout
 end
 function provider.draw(x,y,width,height,nativeFrame,options)
  local layout=provider.prepare(x,y,width,height,nativeFrame,options and options.presentation)
  if not layout then return false end
  -- Do not pass sprite callbacks: scenery is always painted behind the
  -- consumer's untouched native/custom battle rendering.
  drawOptions.mounds=mod.options:get('mounds')and not(options and options.mounds==false)
  drawOptions.calibration=mod.options:get('calibration')
  local ok,drawErr=scene:draw(layout,nil,drawOptions)
  if not ok then return fallback(drawErr)end
  return true
 end
 local SpriteOffsets=module('lib/sprite_offsets.lua')
 function provider.nativeMound(side)
  if not mod.options:get('mounds')or not scene.entry then return end
  local profile=diagnostics.double and nativeProfile.double or nativeProfile
  local viewport={x=0,y=0,width=profile.width,height=profile.height}
  local layout=scene:layout(viewport,loadedAdjustments);local baseline=scene:layout(viewport)
  if not layout or not baseline then return end
  layout=Grounding.apply(layout,baseline,profile,{x=0,y=0,width=profile.width,height=profile.height},moundMaterials,scene.moundSourcePaths)
  local mound=layout[side].mound
  local image=scene.moundPaths and scene.textures[scene.moundPaths[side]]
  if not image then return end
  local scale=math.min(mound.bounds[1]/image:getWidth(),mound.bounds[2]/image:getHeight())*mound.scale
  return image,mound.x,mound.y,scale,mound.origin or{.5,.5}
 end
 function provider.spriteOffset(side,species)
  if not provider.enabled()or not lastLayout or diagnostics.status~='active'then return 0,0 end
  if type(species)=='table'then species=species.mon and species.mon.species end
  species=speciesCatalog:identity(species)
  return SpriteOffsets.resolve(loadedAdjustments,diagnostics.aspect,diagnostics.metadata,side,Version.get(),species,nativeProfile.width,nativeProfile.height)
 end
 if game3 then module('lib/adapters/frlg_scenery.lua').install(mod,g,provider)
 elseif gen2 then module('lib/adapters/gen2_scenery.lua').install(mod,Battle,g,provider)
 else
  SpriteOffsets.install(Battle,g,provider.spriteOffset)
  module('lib/adapters/gen1_scenery.lua').install(mod,Battle,g,provider)
 end
 module('lib/settings.lua')(mod)
end
