-- Isolated native Gen1/2 + actual1025Dex Loader/asset-manager GPU regression.
local workspace=assert(os.getenv('HDB_WORKSPACE')):gsub('\\','/')
local project=assert(os.getenv('HDB_MOD_ROOT')):gsub('\\','/')
local output=assert(os.getenv('HDB_GB_OUTPUT')):gsub('\\','/')
local version=os.getenv('HDB_GAME_VERSION')or'red'
local generation=version=='red'and 1 or 2
local engine=assert(os.getenv('HDB_ENGINE_ROOT')):gsub('\\','/')
local saveRoot=assert(os.getenv('APPDATA')):gsub('\\','/')..'/pokemon-love2d'
local dexRoot=assert(os.getenv('HDB_DEX_ROOT')):gsub('\\','/')
local function read(path)local f=io.open(path,'rb');if not f then return end;local b=f:read('*a');f:close();return b end
local function write(name,b)local f=assert(io.open(output..'/'..name,'wb'));f:write(b);f:close()end
function love.load()
 local ok,err=xpcall(function()
  package.path=engine..'/?.lua;'..package.path
  assert(require('src.core.Version').engine=='0.3.95')
  require('src.core.GameVersion').set(version)
  local Json=require('src.link.Json')
  local inventory=Json.decode(assert(read(os.getenv('HDB_INVENTORY_PATH'))))
  local disk={}
  local function source(path)
   if disk[path]then return disk[path]end
   local id,rel=path:match('^mods/([^/]+)/(.+)$')
   if id then return read((id=='1025dex'and dexRoot or id=='hd-dynamic-battlefields'and project or'__missing')..'/'..rel)end
   local cache=path:match('^mod_cache/1025dex/(.+)$')
   if cache then return read(saveRoot..'/mod_cache/1025dex/'..cache)end
   return read(saveRoot..'/'..version..'/'..path)or read(engine..'/'..path)
  end
  local fs,G=love.filesystem,love.graphics
  local oldRead,oldInfo,oldLoad=fs.read,fs.getInfo,fs.load
  fs.read=function(p,...)return source(p)or oldRead(p,...)end
  fs.getInfo=function(p,...)if inventory[p]then return{type='directory'}end;local b=source(p);if b then return{type='file',size=#b}end;return oldInfo(p,...)end
  fs.load=function(p,...)local b=source(p);if b then return assert(loadstring(b,'@'..p))end;return oldLoad(p,...)end
  local oldImage,oldPixels=G.newImage,love.image.newImageData
  G.newImage=function(p,...)if type(p)=='string'then local b=read(p)or source(p);if b then p=fs.newFileData(b,p)end end;return oldImage(p,...)end
  love.image.newImageData=function(p,...)if type(p)=='string'then local b=read(p)or source(p);if b then p=fs.newFileData(b,p)end end;return oldPixels(p,...)end
  G.setDefaultFilter('nearest','nearest');love.math.setRandomSeed(12345)
  local Blob=require('src.import.CacheBlob')
  package.loaded['src.import.CacheFs']={loadActive=function(p)local b=source(p);if b then return assert(loadstring(Blob.decode(p,b)))()end end,
   readActive=function(p)local b=source(p);return b and Blob.decode(p,b)end,read=function(p)local b=source(p);return b and Blob.decode(p,b)end,
   readAt=function(p)local b=source(p);return b and Blob.decode(p,b)end}
  local game,screen,Battle,data,options
  if generation==1 then
   data=require('src.core.Data');data:load();require('src.render.Font').load(data)
   local Pokemon=require('src.pokemon.Pokemon')
   game={data=data,save={player={name='PROBE',id=1,map='ROUTE_1'},inventory={badges={}},party={Pokemon.new(data,'SQUIRTLE',10)},
    options={battleLayout='classic'},pokedex={seen={},owned={}},version=version,meta={playthroughId='dex-gb-probe'}}}
   Battle=require('src.battle.BattleState');screen=Battle.newWild(game,'RATTATA',7);game.battle=screen
   screen.phase='menu';screen.introSlide=0;screen.introBalls=false;screen.showPlayerBack=false
  else
   local function generated(path)local b=assert(source('data/generated/'..path..'.lua'),path);return assert(loadstring(Blob.decode(path,b)))()end
   data={pokemon=generated('pokemon'),moves=generated('moves'),items=generated('items'),type_chart=generated('type_chart'),font=generated('font'),audio=generated('audio'),
    gen2Palettes=generated('palettes'),gen2BattleAnims=generated('battle_anims'),gen2Trainers=generated('trainers'),gen2Constants=generated('constants')}
   require('src.render.Font').load(data)
   local Mon=require('src.battle.gen2.Mon');local Logic=require('src.battle.gen2.Battle')
   local save=require('src.core.gen2.Save').newGame({playerName='PROBE'});save.party={Mon.new(data,'SQUIRTLE',10)}
   options=save.options or{};save.options=options
   game={data=data,save=save,options=options}
   Battle=require('src.ui.gen2.BattleState')
   local battle=Logic.new({data=data,party=save.party,wild={species='RATTATA',level=7},save=save})
   screen=Battle.new(game,{battle=battle,save=save})
   game.world={map={id='ROUTE_29',def={tileset='JOHTO',environment=1}},playerState='walk',hour=function()return 12 end,timeOfDay=function()return'DAY'end}
   screen.phase='menu';screen.slideFrame=999;screen.showPlayerTrainer=false;screen.showEnemyTrainer=false
   screen.showPlayerHud=true;screen.showEnemyHud=true;screen.ballRows={}
  end
  game.stack={top=function()return screen end}
  local values={enabled=false,environment='grassland',selection='fixed',timeMode='day',weatherMode='clear',animation='off',mounds=true,quality='HD',aspect='auto'}
  local dexOptions={player_sprite_style=4,enemy_sprite_style=4,sprite_size=1,sprite_anchor=0,sprite_float=false,
   sprite_female=true,sprite_shiny=true,battle_shadows=false,player_sprite_view=0,sprite_fps=12}
  local SaveData=require('src.core.SaveData');local configured=SaveData.defaultOptions()
  configured.mods={['hd-dynamic-battlefields']=true,['1025dex']=true}
  configured.modOptions={['hd-dynamic-battlefields']=values,['1025dex']=dexOptions}
  SaveData.loadOptions=function()return configured end
  local virtual={read=source,write=function(p,b)disk[p]=b;return true end,remove=function(p)disk[p]=nil;return true end,
   createDirectory=function()return true end,getDirectoryItems=function(p)if p=='mods'then return{'hd-dynamic-battlefields','1025dex'}end;return inventory[p]or{}end}
  function virtual.getInfo(p)if p=='mods'or inventory[p]then return{type='directory'}end;local b=source(p);if b then return{type='file',size=#b}end end
  function virtual.load(p)return assert(loadstring(assert(source(p)),'@'..p))end
  local loader=require('src.mods.Loader').new({fs=virtual,generation=generation,version=version,dev=false})
  loader.game=game;game.mods=loader;loader:load(data)
  for _,id in ipairs({'1025dex','hd-dynamic-battlefields'})do assert(loader.mods[id]and loader.mods[id].state=='loaded',id..':'..table.concat(loader.errors,'\n'))end
  assert(loader.mods['1025dex'].manifest.version=='1.5.2')
  local manager=assert(loader.exports['1025dex'].assetManager)
  assert(manager:isComplete(),'Actual1025Dexassetmanager is not READY')
  local exports=assert(loader.exports['hd-dynamic-battlefields'])
  local opts=assert(loader.modOptions['1025dex'])
  local currentSide,trace,enabledTrace
  local drawnImages={}
  if generation==1 then
   local old=Battle.drawBattlerPic
   Battle.drawBattlerPic=function(self,b,...)local previous=currentSide;currentSide=b==self.player and'player'or'opponent';local result={old(self,b,...)};currentSide=previous;return unpack(result)end
  else
   local old=Battle.drawPic
   Battle.drawPic=function(self,mon,back,...)local previous=currentSide;currentSide=back and'player'or'opponent';local result={old(self,mon,back,...)};currentSide=previous;return unpack(result)end
  end
  local draw=G.draw
  G.draw=function(image,...)
   if currentSide and trace then
    local args={...};local x,y=args[1],args[2]
    if type(x)=='number'and type(y)=='number'then
     local tx,ty=G.transformPoint(x,y);local ex,ey=G.transformPoint(x+1,y);local fx,fy=G.transformPoint(x,y+1)
     drawnImages[tostring(image)]=image
     trace[#trace+1]={side=currentSide,image=tostring(image),w=image:getWidth(),h=image:getHeight(),args=args,
      x=tx,y=ty,sx=ex-tx,sy=fy-ty,skewX=fx-tx,skewY=ey-ty}
    end
   end
   return draw(image,...)
  end
  local nativeTime=love.timer.getTime;local frozen
  love.timer.getTime=function()return frozen or nativeTime()end
  local function render(layout)
   local w=layout=='wide'and 304 or 160
   game.save.options.battleLayout=layout;game.options=game.options or{};game.options.battleLayout=layout
   local canvas=G.newCanvas(w,144,{dpiscale=1});G.setCanvas(canvas);G.origin();G.setScissor();G.clear(0,0,0,0)
   trace={}
   if generation==1 then screen:draw()else screen:drawWidescreen(w,144)end
   local result=trace;trace=nil;G.setCanvas();return result,canvas
  end
  local rows={};local index=0
  for _,style in ipairs({0,1,3,4})do for size=1,3 do for anchor=0,2 do for view=0,2 do
   frozen=nil;opts.player_sprite_style=style;opts.enemy_sprite_style=style;opts.sprite_size=size;opts.sprite_anchor=anchor
   opts.player_sprite_view=view
   values.enabled=false
   for i=1,180 do loader.hooks:call('core.update',function()end,game,1/60);local _,canvas=render('classic');canvas:release()end
   frozen=0
   for _,layout in ipairs({'classic','wide'})do
    index=index+1;values.enabled=false;local before,c1=render(layout);c1:release()
    values.enabled=true;local after,canvas=render(layout)
    assert(Json.encode(before)==Json.encode(after),'HDchangednativeGPUdrawarguments '..index)
    assert(#after==2,'Expectedactualplayer+opponentspritedraws '..index..':'..Json.encode(after))
    local d=exports.diagnostics();assert(d.status=='active',Json.encode(d))
    assert(d.spriteContacts and d.spriteContacts.slots,'MissingGBcalibrationdiagnostics:'..Json.encode(d))
    for side,reason in pairs(d.spriteContacts.errors or{})do error(side..':'..tostring(reason))end
    local checked={}
    for _,call in ipairs(after)do
     local contact=assert(d.spriteContacts.slots[call.side],call.side)
     local box=call.side=='player'and(generation==1 and 64 or 48)or 56
     assert(call.w==box and call.h==box,'Nativefallbackspritewasdrawn:'..Json.encode(call))
     local image=assert(drawnImages[call.image]);local imageCanvas=G.newCanvas(call.w,call.h)
     G.push('all');G.setCanvas(imageCanvas);G.origin();G.setShader();G.setScissor();G.clear(0,0,0,0);G.setColor(1,1,1,1)
     draw(image,0,0);G.pop()
     local pixels=imageCanvas:newImageData();local bodyBottom=-1
     for y=call.h-1,0,-1 do
      for x=0,call.w-1 do local _,_,_,a=pixels:getPixel(x,y);if a>0 then bodyBottom=y+1;break end end
      if bodyBottom>=0 then break end
     end
     pixels:release();imageCanvas:release();assert(bodyBottom>=0,'Invisiblemanagedbody')
     local gap=contact.nativeGap or contact.gap or 0
     local expectedX=call.x+call.w/2*(call.args[4]or 1)*call.sx
     local expectedY=call.y+(call.h-gap)*(call.args[5]or 1)*call.sy
     -- Compare stablecanvasground forFEET/BOX; PACKsourcegap is independently
     -- recorded by the actual silhouette audit and carried in diagnostics.
     local canvasGround=call.y+call.h*(call.args[5]or 1)*call.sy
     local bodyGround=call.y+bodyBottom*(call.args[5]or 1)*call.sy
     checked[#checked+1]={side=call.side,draw=call,contact=contact,canvasGround=canvasGround,bodyBottom=bodyBottom,
      bodyGround=bodyGround,bodyContactGap=contact.y-bodyGround,
      packGap=canvasGround-contact.y,centerGap=expectedX-contact.x}
     assert(math.abs(expectedX-contact.x)<.001,'WrongGBcontactx:'..Json.encode(checked[#checked]))
     if anchor~=1 then assert(math.abs(canvasGround-contact.y)<.001,'WrongGBgroundy:'..Json.encode(checked[#checked]))end
     if style==1 or style==4 then assert(math.abs(bodyGround-contact.y)<.001,'StaticbodymissesGBmoundcontact:'..Json.encode(checked[#checked]))end
    end
    local row={index=index,style=style,size=size,anchor=anchor,view=view,layout=layout,nativeDrawArgumentsUnchanged=true,contacts=checked}
    if size==1 and(anchor==0 or anchor==1)then
     local name=string.format('%s-%03d-style%d-size%d-anchor%d-view%d-%s.png',version,index,style,size,anchor,view,layout)
     local pixels=canvas:newImageData();write(name,pixels:encode('png'):getString());pixels:release();row.screenshot=name
    end
    canvas:release();rows[#rows+1]=row;write('progress.json',Json.encode({game=version,complete=index,total=216}))
   end
   print(version..' GB styles '..style..' size '..size..' anchor '..anchor..' view '..view..' PASS');io.stdout:flush()
  end end end end
  write('report.json',Json.encode({game=version,engine='0.3.95',generation=generation,cases=rows,caseCount=#rows,
   assetManager={complete=manager:isComplete(),label=manager:statusLabel()},
   scope='ActualnativeGBdraws with1025Dex1.5.2.Loaderwrites are in-memory; actualsaves unchanged; KIM/BW coveredseparateGen3fixture.'}))
  love.timer.getTime=nativeTime;G.draw=draw
 end,debug.traceback)
 love.graphics.setCanvas();if not ok then write('error.txt',err)end
 love.event.quit(ok and 0 or 1)
end
