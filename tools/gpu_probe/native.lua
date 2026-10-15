-- Native renderer fixture using locally imported Red data, never a user's save.
return function(project, module, write)
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
 local P,Scene,Adapter=module('lib/perspective.lua'),module('lib/scene.lua'),module('lib/adapters/gen1_capture.lua')
 local catalog=module('metadata/prototype.lua')
 local adapter=Adapter.new(G,Battle,require('src.render.PixelCanvas').new,module('lib/projection.lua'),module('lib/pixel_grid.lua'))
 local scene=Scene.new(G,P,function(path)
  local f=assert(io.open(project..'/'..path,'rb'));local b=f:read('*a');f:close()
  return oldImage(fs.newFileData(b,path))
 end)
 assert(scene:prepare(catalog.compositions[1],catalog.metadata))
 local layout=assert(scene:layout({width=1920,height=1080}))
 local originalBack,originalFront,originalRect=Battle.backPlacement,Battle.frontPlacement,G.rectangle
 local function opaqueCount(canvas,x0,y0,w,h)
  local image=canvas:newImageData();local count=0
  for y=y0 or 0,(y0 or 0)+(h or image:getHeight())-1 do for x=x0 or 0,(x0 or 0)+(w or image:getWidth())-1 do local _,_,_,a=image:getPixel(x,y);if a>0 then count=count+1 end end end
  image:release();return count
 end
 local frame=assert(adapter:capture(battle,layout))
 local raw=frame.ui:newImageData();write('native-red-ui-layer.png',raw:encode('png'):getString());raw:release()
 local hud=frame.hud:newImageData();write('native-red-hud-layer.png',hud:encode('png'):getString());hud:release()
 assert(frame.hudTouched.player and frame.hudTouched.opponent)
 assert(Battle.backPlacement==originalBack and Battle.frontPlacement==originalFront and G.rectangle==originalRect)
 assert(rawget(battle,'drawPicsLayer')==nil and rawget(battle,'wideRegion')==nil)
 local canvas=G.newCanvas(1920,1080,{dpiscale=1});G.setCanvas(canvas);G.origin();G.clear(0,0,0,1)
 assert(scene:draw(layout,frame.sprites,{}))
 assert(adapter:drawEffects(frame,layout))
 assert(adapter:drawUI(frame,layout,scene.metadata,400,36,7))
 G.setCanvas()
 local pixels=canvas:newImageData();write('native-red-command-prototype.png',pixels:encode('png'):getString());pixels:release()
 -- Move and Mimic UI must keep their complete native upper information rows.
 local Font=require('src.render.Font');local nativeDraw=Font.draw;local strings={}
 Font.draw=function(text,...)strings[tostring(text)]=true;return nativeDraw(text,...)end
 assert(battle:chooseMenu('fight')and battle.phase=='moveSelect')
 local moves=assert(adapter:capture(battle,layout))
 Font.draw=nativeDraw
 assert(moves.uiBounds[2]==64 and moves.uiBounds[4]==80 and strings['TYPE/'],'Move TYPE row was not captured')
 local selected=battle.player.curMoves[battle.moveIndex];local definition=battle.data.moves[selected.id]
 assert(strings[string.format('%2d/%2d',selected.pp,Pokemon.maxPP(definition.pp,selected.ppUps))],'Move PP values were lost')
 assert(opaqueCount(moves.ui,0,64,88,32)>0 and opaqueCount(moves.hud,72,56,88,40)>0)
 G.setCanvas(canvas);G.origin();G.clear(0,0,0,1);assert(scene:draw(layout,moves.sprites,{}));assert(adapter:drawUI(moves,layout,scene.metadata,400,36,7));G.setCanvas()
 local mp=canvas:newImageData();write('native-red-move-select.png',mp:encode('png'):getString());mp:release()
 local originalInput=game.input;local originalIndex=battle.moveIndex
 game.input={wasPressed=function(_,key)return key=='down'end};battle:update(1/60)
 assert(battle.moveIndex==originalIndex%#battle.player.curMoves+1,'Native move DOWN stopped working')
 game.input={wasPressed=function(_,key)return key=='up'end};battle:update(1/60)
 assert(battle.moveIndex==originalIndex,'Native move UP stopped working');game.input=originalInput
 assert(battle:cancelMove()and battle.phase=='menu')
 battle.phase='mimicSelect';battle.mimicMoves=battle.player.curMoves;battle.mimicIndex=1
 local mimic=assert(adapter:capture(battle,layout));assert(mimic.uiBounds[2]==56 and mimic.uiBounds[4]==88)
 G.setCanvas(canvas);G.origin();G.clear(0,0,0,1);assert(scene:draw(layout,mimic.sprites,{}));assert(adapter:drawUI(mimic,layout,scene.metadata,400,36,7));G.setCanvas()
 local mm=canvas:newImageData();write('native-red-mimic-select.png',mm:encode('png'):getString());mm:release()
 battle.phase='menu'
 -- Native send-out stages must still increase the visible sprite footprint.
 local counts={}
 for _,f in ipairs({0,4,9})do
  battle.growIn={battler=battle.player,frame=f};assert(adapter:capture(battle,layout))
  counts[#counts+1]=opaqueCount(adapter.pictures.player)
 end
 battle.growIn=nil
 assert(counts[1]==0 and counts[2]>0 and counts[3]>counts[2],'Native send-out scaling was lost')
 -- Exercise a real native OAM animation step, not a synthetic effect marker.
 assert(battle.animPlayer,'Native animation data is missing')
 battle.animPlayer:start('WATER_GUN',true)
 local populated
 for index,step in ipairs(battle.animPlayer.steps)do if #step.sprites>0 then populated=index;break end end
 assert(populated,'No Water Gun sprite-animation step')
 battle.animPlayer.stepIndex=populated;battle.animPlaying=true;battle.phase='messages'
 battle.shown={Font.encode('SQUIRTLE used'),Font.encode('WATER GUN!')}
 local animated=assert(adapter:capture(battle,layout))
 assert(opaqueCount(animated.effects)>0,'Native OAM animation capture is empty')
 G.setCanvas(canvas);G.origin();G.clear(0,0,0,1)
 assert(scene:draw(layout,animated.sprites,{}));assert(adapter:drawEffects(animated,layout));assert(adapter:drawUI(animated,layout,scene.metadata,400,36,7));G.setCanvas()
 local effectImage=canvas:newImageData();write('native-red-watergun-prototype.png',effectImage:encode('png'):getString());effectImage:release()
 battle.animPlaying=false;battle.phase='menu';battle.shown=nil
 -- Native white flash is a single full-viewport effect, never baked into
 -- the text layer and then applied a second time to its moved panels.
 battle.fx={flash=3};battle.frame=0
 local flash=assert(adapter:capture(battle,layout));assert(flash.flash==.85)
 local flashText=flash.ui:newImageData();local _,_,_,a=flashText:getPixel(0,0);flashText:release();assert(a==0,'Flash was baked into text layer')
 G.setCanvas(canvas);G.origin();G.clear(0,0,0,1);assert(adapter:drawUI(flash,layout,scene.metadata,400,36,7));G.setCanvas()
 local veil=canvas:newImageData()
 for _,point in ipairs({{0,0},{1919,0},{0,1079},{1919,1079}})do local r,g,b=veil:getPixel(point[1],point[2]);assert(math.abs(r-.85)<.005 and math.abs(g-.85)<.005 and math.abs(b-.85)<.005,'Flash did not cover the full viewport')end
 veil:release();battle.fx=nil
 -- The fainted side's native layer must become fully transparent.
 battle.enemy.fainted=true
 local faint=assert(adapter:capture(battle,layout))
 assert(opaqueCount(adapter.pictures.opponent)==0,'Fainted enemy sprite remained on screen')
 G.setCanvas(canvas);G.origin();G.clear(0,0,0,1);assert(scene:draw(layout,faint.sprites,{}));assert(adapter:drawUI(faint,layout,scene.metadata,400,36,7));G.setCanvas()
 local pixels2=canvas:newImageData();write('native-red-enemy-fainted.png',pixels2:encode('png'):getString());pixels2:release()
 battle.player.fainted=true;local both=assert(adapter:capture(battle,layout))
 assert(opaqueCount(adapter.pictures.player)==0,'Fainted player sprite remained on screen')
 assert(opaqueCount(both.hud,72,56,88,40)==0,'Fainted player HUD/name remained on screen')
 assert(not both.hudTouched.player and not both.hudTouched.opponent,'Fainted HUD paper would remain visible')
 -- Scoped overrides must roll back even when a native draw throws.
 local depth=G.getStackDepth()
 local saved=battle.drawPicsLayer;battle.drawPicsLayer=function()G.push('all');G.translate(100,200);error('injected native picture error')end
 assert(not adapter:capture(battle,layout));battle.drawPicsLayer=saved
 assert(Battle.backPlacement==originalBack and Battle.frontPlacement==originalFront and G.rectangle==originalRect)
 assert(rawget(battle,'wideRegion')==nil)
 assert(G.getStackDepth()==depth,'Native draw error leaked the graphics stack')
 local integration=assert(loadfile(project..'/tools/gpu_probe/entry.lua'))()(project,game,battle,write,hostRead)
 write('native-red-entry.txt',integration)
 adapter:release();scene:release();canvas:release()
 if battle.bgCanvas then battle.bgCanvas:release()end;if battle.waveCanvas then battle.waveCanvas:release()end
 fs.read,fs.getInfo,fs.load=oldRead,oldInfo,oldLoad;G.newImage,love.image.newImageData=oldImage,oldPixels
 return 'PASS actual v0.3.88 Red BattleState picture/UI capture, original imported sprites, send-out stages, native Water Gun OAM step/projection, both fainted sprite layers/player HUD transparency, scoped override/graphics-stack rollback; fixture only, no gameplay traversal\n'..integration
end
