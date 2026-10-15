return function(project,game,battle,write,hostRead)
 local Json=require('src.link.Json')
 local SaveData=require('src.core.SaveData')
 local options=SaveData.defaultOptions()
 options.mods={['hd-dynamic-battlefields']=true}
 options.modOptions={['hd-dynamic-battlefields']={enabled=true,selection='fixed'}}
 local originalOptions=SaveData.loadOptions;SaveData.loadOptions=function()return options end
 local prefix='mods/hd-dynamic-battlefields/'
 local disk={}
 local function source(p)
  if p:sub(1,#prefix)~=prefix then return end
  local f=io.open(project..'/'..p:sub(#prefix+1),'rb');if not f then return end
  local b=f:read('*a');f:close();return b
 end
 local fs={}
 function fs.read(p)return disk[p]or source(p)end
 function fs.write(p,b)disk[p]=b;return true end
 function fs.getInfo(p)
  if p=='mods'or p=='mods/hd-dynamic-battlefields'then return{type='directory'}end
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
 local context={ww=1920,wh=1080,viewX=0,viewY=0,viewWidth=1920,viewHeight=1080,ox=400,oy=36,scale=7}
 local target=G.newCanvas(1920,1080,{dpiscale=1});G.setCanvas(target);G.origin();G.clear(0,0,0,1)
 assert(loader.hooks:call('render.compose',function()return false end,{},context)==true)
 G.setCanvas();local pixels=target:newImageData();write('native-red-entry-integration.png',pixels:encode('png'):getString());pixels:release()
 local exports=loader.exports['hd-dynamic-battlefields']
 assert(exports.diagnostics().status=='active'and exports.diagnostics().composition=='grassland-01-16x9')
 assert(exports.applyAdjustments({global={player={mound_x=.01,pokemon_x=.01}}}))
 assert(not exports.applyAdjustments({global={player={mound_scale=-1}}}))
 assert(exports.applyAdjustments({}))
 for map,environment in pairs({VIRIDIAN_FOREST='forest',MT_MOON_1F='cave'})do
  assert(game.data.maps[map],'Map ID is not in the actual imported map table: '..map)
  game.save.player.map=map
  G.setCanvas(target);G.origin();G.clear(0,0,0,1)
  assert(loader.hooks:call('render.compose',function()return false end,{},context)==true)
  G.setCanvas();local p=target:newImageData();write('native-red-'..environment..'-entry.png',p:encode('png'):getString());p:release()
  assert(exports.diagnostics().environment==environment and exports.diagnostics().composition==environment..'-01-16x9')
 end
 game.save.player.map='ROUTE_1'
 context.ww,context.wh,context.viewWidth,context.viewHeight=5120,1440,5120,1440
 context.ox,context.oy,context.scale=1760,0,10
 local wide=G.newCanvas(5120,1440,{dpiscale=1});G.setCanvas(wide);G.origin();G.clear(0,0,0,1)
 assert(loader.hooks:call('render.compose',function()return false end,{},context)==true)
 assert(exports.diagnostics().composition=='grassland-01-32x9')
 G.setCanvas();local wp=wide:newImageData();write('native-red-grassland-5120x1440.png',wp:encode('png'):getString());wp:release();wide:release()
 for map,environment in pairs({VIRIDIAN_FOREST='forest',MT_MOON_1F='cave'})do
  game.save.player.map=map
  local panorama=G.newCanvas(5120,1440,{dpiscale=1});G.setCanvas(panorama);G.origin();G.clear(0,0,0,1)
  assert(loader.hooks:call('render.compose',function()return false end,{},context)==true,Json.encode(exports.diagnostics()))
  assert(exports.diagnostics().composition==environment..'-01-32x9')
  G.setCanvas();local p=panorama:newImageData();write('native-red-'..environment..'-5120x1440.png',p:encode('png'):getString());p:release();panorama:release()
 end
 game.save.player.map='ROUTE_1'
 context.ww,context.wh,context.viewWidth,context.viewHeight=1920,1080,1920,1080
 context.ox,context.oy,context.scale=400,36,7
 context.ww,context.wh,context.viewWidth,context.viewHeight=900,1600,900,1600
 context.ox,context.oy,context.scale=50,440,5
 local portrait=G.newCanvas(900,1600,{dpiscale=1});G.setCanvas(portrait);G.origin();G.clear(0,0,0,1)
 assert(loader.hooks:call('render.compose',function()return false end,{},context)==true)
 assert(exports.diagnostics().composition=='grassland-01-9x16')
 G.setCanvas();local pp=portrait:newImageData();write('native-red-grassland-portrait.png',pp:encode('png'):getString());pp:release();portrait:release()
 for map,environment in pairs({VIRIDIAN_FOREST='forest',MT_MOON_1F='cave'})do
  game.save.player.map=map
  local phone=G.newCanvas(900,1600,{dpiscale=1});G.setCanvas(phone);G.origin();G.clear(0,0,0,1)
  assert(loader.hooks:call('render.compose',function()return false end,{},context)==true,Json.encode(exports.diagnostics()))
  assert(exports.diagnostics().composition==environment..'-01-9x16')
  G.setCanvas();local p=phone:newImageData();write('native-red-'..environment..'-portrait.png',p:encode('png'):getString());p:release();phone:release()
 end
 game.save.player.map='ROUTE_1'
 context.ww,context.wh,context.viewWidth,context.viewHeight=390,693,390,693
 context.ox,context.oy,context.scale,context.dpiX,context.dpiY=0,0,2/2.75,2.75,2.75
 local densityTarget=G.newCanvas(390,693,{dpiscale=2.75});G.setCanvas(densityTarget);G.origin();G.clear(0,0,0,1)
 local previousDraw=G.draw;local gridChecks=0
 G.draw=function(image,quad,x,y,rotation,sx,sy,...)
  if image:getWidth()==160 and image:getHeight()==144 and type(quad)=='userdata'and quad:typeOf('Quad')then
   local actual=G.getCanvas():getDPIScale()
   assert(math.abs(actual-densityTarget:getDPIScale())<1e-9,'Staging and output densities differ')
   assert(math.abs(sx*actual-math.floor(sx*actual+.5))<1e-8 and math.abs(sy*actual-math.floor(sy*actual+.5))<1e-8,'Non-integer physical HUD scale')
   assert(math.abs(x*actual-math.floor(x*actual+.5))<1e-8 and math.abs(y*actual-math.floor(y*actual+.5))<1e-8,'HUD missed physical pixel grid')
   gridChecks=gridChecks+1
  end
  return previousDraw(image,quad,x,y,rotation,sx,sy,...)
 end
 assert(loader.hooks:call('render.compose',function()return false end,{},context)==true,Json.encode(exports.diagnostics()))
 G.draw=previousDraw;assert(gridChecks==3,'Did not observe all native HUD/panel draws')
 G.setCanvas();local hp=densityTarget:newImageData();write('native-red-portrait-density-2_75.png',hp:encode('png'):getString());hp:release();densityTarget:release()
 context.dpiX,context.dpiY=1,1
 context.ww,context.wh,context.viewWidth,context.viewHeight=1920,1080,1920,1080
 context.ox,context.oy,context.scale=400,36,7
 local function fallback(reason)
  assert(loader.hooks:call('render.compose',function()return false end,{},context)==false)
  local result=exports.diagnostics();assert(result.status=='native fallback'and result.reason:find(reason,1,true),Json.encode(result))
 end
 for _,size in ipairs({{1920,1080},{5120,1440},{900,1600}})do
  local w,h=size[1],size[2];context.ww,context.wh,context.viewWidth,context.viewHeight=w,h,w,h
  local page=G.newCanvas(w,h,{dpiscale=1})
  for _,phase in ipairs({'moveSelect','mimicSelect'})do
   battle.phase=phase;battle.mimicMoves=battle.player.curMoves;battle.mimicIndex=1
   G.setCanvas(page);G.origin();G.clear(0,0,0,1)
   assert(loader.hooks:call('render.compose',function()return false end,{},context)==true,Json.encode(exports.diagnostics()))
   local d=exports.diagnostics();assert(d.uiPhase==phase and d.uiRegion.y==(phase=='moveSelect'and 64 or 56))
   G.setCanvas();local p=page:newImageData();write('native-red-'..phase..'-'..w..'x'..h..'.png',p:encode('png'):getString());p:release()
  end
  page:release()
 end
 battle.phase='menu'
 context.ww,context.wh,context.viewWidth,context.viewHeight=1920,1080,1920,1080
 local beforeDepth=G.getStackDepth();local failDraw=G.draw
 G.setCanvas(target);G.origin();G.clear(.17,.23,.31,1)
 G.draw=function(image,quad,...)
  if image:getWidth()==160 and image:getHeight()==144 and type(quad)=='userdata'and quad:typeOf('Quad')then error('injected HUD draw failure')end
  return failDraw(image,quad,...)
 end
 fallback('injected HUD draw failure');G.draw=failDraw
 assert(G.getCanvas()==target and G.getStackDepth()==beforeDepth,'Compositor failure did not restore destination/stack')
 G.setCanvas();local untouched=target:newImageData();local r,gg,b=untouched:getPixel(10,10);untouched:release()
 assert(math.abs(r-.17)<.005 and math.abs(gg-.23)<.005 and math.abs(b-.31)<.005,'Failed staged composition touched the live output')
 game.save.player.map='UNCLASSIFIED';fallback('unknown environment')
 game.save.player.map='ROUTE_1';game.save.options.battleLayout='wide';fallback('wide adapter');game.save.options.battleLayout='classic'
 local fakeOverlay={};game.stack.top=function()return fakeOverlay end;fallback('Native overlay')
 game.stack.top=function()return battle end
 local called=0
 assert(loader.hooks:call('render.compose',function()called=called+1;return true end,{},context)==true and called==1)
 loader.modOptions['hd-dynamic-battlefields'].enabled=false
 assert(loader.hooks:call('render.compose',function()return false end,{},context)==false and exports.diagnostics().status=='disabled')
 exports.release();target:release()
 G.newImage=originalImage;SaveData.loadOptions=originalOptions
 return 'PASS v0.3.88 Loader/Sandbox entry; exact imported map IDs; all three prototype environments/aspects; complete moveSelect/Mimic panel regions at 1920x1080, 5120x1440 and 900x1600; physical pixel-grid checks at nominal density 2.75; atomic draw-error rollback; fallback/downstream ownership/disable. No physical device or full gameplay traversal claim.'
end
