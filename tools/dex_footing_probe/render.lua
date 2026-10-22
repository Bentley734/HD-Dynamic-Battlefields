return function(project,game,Battle,cache,write)
 local G=love.graphics;G.setDefaultFilter('nearest','nearest')
 local Pokemon=require('src.core.game3.pokemon')
 local Ui=require('src.core.game3.battle.ui')
 local Anim=require('src.core.game3.battle.anim')
 local Display=require('src.core.game3.display')
 local Json=require('src.link.Json')
 local values={enabled=false,environment='auto',selection='fixed',timeMode='day',weatherMode='clear',
  animation='off',mounds=true,quality='HD',aspect='auto'}
 local mod,loader,loaded,count,versions=assert(loadfile(project..'/tools/dex_footing_probe/loader.lua'))()(project,game,values)
 local opts=assert(loader.modOptions['1025dex'])
 local nativeTime=love.timer.getTime
 local frozen
 love.timer.getTime=function()return frozen or nativeTime()end
 local images=setmetatable({},{__mode='k'})
 local drawnImages={}
 local spriteCanvases=setmetatable({},{__mode='k'})
 local frames={}
 local moundImages=setmetatable({},{__mode='k'})
 local moundTrace={}
 local testedRoot=(os.getenv('HDB_MOD_ROOT')or project):gsub('\\','/')
 local catalog=assert(loadfile(testedRoot..'/metadata/rse.lua'))()
 local materials=assert(loadfile(testedRoot..'/metadata/mound_materials.lua'))()
 local compositions={};for _,entry in ipairs(catalog.compositions)do compositions[entry.id]=entry end
 local sidePic=Ui.sidePic
 Ui.sidePic=function(...)
  local pic=sidePic(...)
  if pic and pic.image then
   local args={...};images[pic.image]={back=args[1],species=args[3],shiny=not not args[5],ready=pic.__completeDexBattleLift~=nil}
  end
  return pic
 end
 local drawing,trace=false,{}
 local draw=G.draw
 G.draw=function(image,...)
  if drawing and images[image]then
   local args={...};local record={image=tostring(image),w=image:getWidth(),h=image:getHeight(),args={}}
   local info=images[image];record.back=info.back;record.species=info.species;record.shiny=info.shiny;record.replacement_ready=info.ready
   local canvas=G.getCanvas();assert(canvas,'Native sprite was not drawn into a canvas')
   record.canvas=tostring(canvas);spriteCanvases[canvas]=true
   drawnImages[record.image]=image
   for i=1,#args do record.args[i]=type(args[i])=='number'and args[i]or tostring(args[i])end
   record.tx,record.ty=G.transformPoint(0,0)
   record.xx,record.xy=G.transformPoint(1,0);record.yx,record.yy=G.transformPoint(0,1)
   trace[#trace+1]=record
  end
  if drawing and values.enabled and moundImages[image]then
   local args={...};local origin=moundImages[image]
   assert(type(args[1])=='number'and type(args[2])=='number','Unexpected mound quad')
   local x,y=G.transformPoint(args[1]+image:getWidth()*(args[4]or 1)*origin[1],
    args[2]+image:getHeight()*(args[5]or args[4]or 1)*origin[2])
   moundTrace[#moundTrace+1]={x=x,y=y,image=tostring(image),origin=origin,args=args}
  end
  return draw(image,...)
 end
 local Renderer=require('src.render.Renderer')
 local blit=Renderer.blitCanvas
 Renderer.blitCanvas=function(self,canvas,...)
  if drawing and spriteCanvases[canvas]then
   local args={...};frames[tostring(canvas)]={sx=args[1],sy=args[2],x=args[6],y=args[7]}
  end
  return blit(self,canvas,...)
 end
 local function mon(name,level,shiny,female)
  local id=assert(Pokemon.speciesFromName(name),'Unknown native fixture species '..name)
  local p={species=id,level=level,personality=female and 0 or 0x12345678,ivs={31,31,31,31,31,31},evs={},isFemale=female}
  Pokemon.applyStats(p,game.session);p.hp=p.maxHp
  p.moves,p.pp,p.maxPp=Pokemon.movesAtLevel(id,level)
  if shiny then p.personality=1;game.session.trainerId=1 else p.personality=female and 0 or 0x12345678;game.session.trainerId=0x4142 end
  return p
 end
 local function start(case)
  Battle.reset();game.session.map='EM_'..(case.map or'ROUTE101')
  game.session.party={mon(case.player,50,case.shiny,case.female)}
  local foe={species=assert(Pokemon.speciesFromName(case.enemy)),level=50,personality=case.shiny and 1 or 0x12345678}
  if case.double then
   game.session.party[2]=mon(case.partner or'SWAMPERT',50,case.shiny,false)
   foe={party={foe,{species=assert(Pokemon.speciesFromName(case.enemyPartner or'ZIGZAGOON')),level=50}}}
  end
  assert(Battle.start{playerParty=game.session.party,foe=foe,wild=not case.double,double=case.double,
   trainerClass=case.double and 1 or nil,trainerClassName=case.double and'TRAINER'or nil,
   trainerName=case.double and'FOOTING'or nil,session=game.session,cache=cache,mapType=3,mapKind='outdoor',terrain=0,fade=false})
  local state=Battle.getState()
  if case.water then state.terrain=assert(require('src.core.game3.battle.bg').env().TERRAIN.WATER)end
  -- Set exact native shiny identity for every shown mon through supported data.
  local function shinyIdentity(b)
   if b and b.mon then b.mon.personality=case.shiny and 1 or 0x12345678;b.mon.otId=case.shiny and 1 or 0x4142;b.mon.trainerId=case.shiny and 1 or 0x4142 end
  end
  shinyIdentity(state.player);shinyIdentity(state.enemy)
  if state.battlers then for id=0,3 do shinyIdentity(state.battlers[id])end end
  Anim.reset{headless=true,double=case.double};Anim._headless=false;Anim.syncDisplayFromState(state)
  Ui.reset{};Ui.bindState(state,game.session);Ui.openMenu(0)
  return state
 end
 local function render()
  for _,side in ipairs({'player','opponent'})do
   for _,pad in ipairs(mod.exports.battlefieldScenery.nativeMounds(side)or{})do moundImages[pad.image]=pad.origin end
  end
  G.setCanvas();G.origin();G.clear(.04,.04,.04,1);trace={};moundTrace={};frames={};drawing=true
  Display.present(game,G.getWidth(),G.getHeight())
  drawing=false
  assert(not Display.planesBroken,'Native display planes failed')
  assert(not mod.exports.sceneryAdapterError,mod.exports.sceneryAdapterError)
  return Json.encode(trace)
 end
 local function capture(name)
  local ready=false
  G.captureScreenshot(function(data)write(name..'.png',data:encode('png'):getString());data:release();ready=true end)
  G.present();assert(ready)
 end
 local function bodyContacts(draws,contacts,case,diagnostics)
  local results={}
  local entry=assert(compositions[diagnostics.composition],'Unknown rendered composition')
  for _,call in ipairs(draws)do
   assert(call.replacement_ready,'Native fallback/pending picture was drawn')
   local frame=assert(frames[call.canvas],'Missing actual native canvas blit')
   local sx,sy,ox,oy=frame.sx,frame.sy,frame.x,frame.y
   local image=assert(drawnImages[call.image])
   local canvas=G.newCanvas(image:getWidth(),image:getHeight())
   G.push('all');G.setCanvas(canvas);G.origin();G.setScissor();G.setShader();G.clear(0,0,0,0);G.setColor(1,1,1,1);draw(image,0,0);G.pop()
   local data=canvas:newImageData();local bottom=-1;local left,right
   for y=data:getHeight()-1,0,-1 do
    for x=0,data:getWidth()-1 do local _,_,_,a=data:getPixel(x,y);if a>0 then bottom=y+1;left=left or x;right=x+1 end end
    if bottom>=0 then break end
   end
   data:release();canvas:release();assert(bottom>=0,'Invisible sprite picture')
   local y=call.args[2]+(bottom-(call.args[7]or 0))*(call.args[5]or 1)
   local nearest,slot,dist
   for id,target in pairs(contacts.slots or{})do
    if (tonumber(id)%2==0)==call.back then
     local distance=math.abs(target.x-call.args[1])
     if not dist or distance<dist then nearest,slot,dist=target,id,distance end
    end
   end
   assert(nearest,'No native slot matches rendered picture')
   local gap=nearest.y-y
   -- EE STATIC scans only its first pose, so grounded alpha and stable contact
   -- must agree exactly after native integer placement (one edge-pixel margin).
   local grounded=case.anchor~=0 or not case.float
   if(case.style==1 or case.style==4)and grounded then assert(math.abs(gap)<=1,'Grounded static body misses mound contact: '..gap)end
   if case.style==0 and case.anchor==1 then assert(gap>=-1,'Animated PACK body extends below mound contact: '..gap)end
   local side=call.back and'player'or'opponent'
   local path=(diagnostics.period=='night'and entry.night_mounds or entry.mounds)[side]
   local material=materials[path]or{}
   local materialOffset=material.offset_y or 0
   local expectedX,expectedY=ox+nearest.x*sx,oy+(nearest.y+materialOffset)*sy
   local actualMound,distance
   for _,mound in ipairs(moundTrace)do
    local value=(mound.x-expectedX)^2+(mound.y-expectedY)^2
    if not distance or value<distance then actualMound,distance=mound,value end
   end
   assert(actualMound,'No actual painted mound draw matches sprite')
   local surfaceY=actualMound.y-materialOffset*sy
   local targetSurfaceY=oy+nearest.y*sy
   if math.abs(actualMound.x-expectedX)>=.01 or math.abs(surfaceY-targetSurfaceY)>=.01 then
    write('surface-failure.json',Json.encode({width=G.getWidth(),height=G.getHeight(),case=case,slot=slot,
     actual=actualMound,expected={x=expectedX,y=targetSurfaceY},native=nearest,fit={sx=sx,sy=sy,ox=ox,oy=oy},moundDraws=moundTrace}))
   end
   assert(math.abs(actualMound.x-expectedX)<.01 and math.abs(surfaceY-targetSurfaceY)<.01,
    'Painted mound surface differs from calibrated native contact')
   local bodyScreenY=oy+y*sy
   local paintedGap=(surfaceY-bodyScreenY)/sy
   if(case.style==1 or case.style==4)and grounded then assert(math.abs(paintedGap)<=1,'Actual painted mound misses static feet: '..paintedGap)end
   results[#results+1]={slot=slot,species=call.species,back=call.back,shiny=call.shiny,
    alpha_bottom=bottom,native_body_bottom=y,contact_y=nearest.y,gap=gap,bottom_span={left,right},
    painted_surface={x=actualMound.x,y=surfaceY,material_offset=materialOffset},
    body_screen_y=bodyScreenY,painted_gap_native=paintedGap}
  end
  return results
 end
 local pairings={{'SCEPTILE','METAGROSS'},{'BLAZIKEN','SALAMENCE'},{'SWAMPERT','MILOTIC'},
  {'PIKACHU','WAILORD'},{'GROUDON','KYOGRE'},{'GENGAR','FLYGON'}, {'BLASTOISE_GMAX','PECHARUNT'}}
 local cases={}
 for style=0,5 do for size=1,3 do for anchor=0,2 do
  local names=pairings[(#cases%#pairings)+1]
  cases[#cases+1]={style=style,size=size,anchor=anchor,view=(size+anchor)%3,
   shiny=(size+anchor)%2==0,female=(#cases%4)==0,float=(#cases%2)==0,
   player=names[1],enemy=names[2]}
 end end end
 for style=0,5 do
  cases[#cases+1]={style=style,size=1+(style%3),anchor=style%3,view=style%3,
   shiny=style%2==0,float=style%2==1,double=true,player='SCEPTILE',enemy='METAGROSS',partner='SWAMPERT',enemyPartner='ZIGZAGOON'}
 end
 cases[#cases+1]={style=1,size=1,anchor=1,view=0,shiny=false,float=false,player='HIPPOWDON',enemy='MEOWSTIC_FEMALE',female=true}
 cases[#cases+1]={style=5,size=1,anchor=1,view=2,shiny=true,float=true,player='CHARIZARD',enemy='DEOXYS_SPEED'}
 -- Exercise every GEN9 static size/anchor/view combination with grounded art.
 for size=1,3 do for anchor=0,2 do for view=0,2 do
  cases[#cases+1]={style=1,size=size,anchor=anchor,view=view,shiny=view%2==1,float=false,
   player='PIKACHU',enemy='MILOTIC',capture=size==1 and anchor==1}
 end end end
 -- Logical back-slot PACK metrics must apply even when sourcing front art.
 for size=1,3 do for view=1,2 do
  cases[#cases+1]={style=0,size=size,anchor=1,view=view,shiny=view==2,float=false,
   player='PIKACHU',enemy='MILOTIC',capture=size==1}
 end end
 for view=0,2 do
  cases[#cases+1]={style=1,size=1,anchor=1,view=view,shiny=view==2,float=false,double=true,
   player='PIKACHU',partner='SWAMPERT',enemy='MILOTIC',enemyPartner='ZIGZAGOON',aspectReview=true}
 end
 cases[#cases+1]={style=1,size=1,anchor=1,view=1,shiny=false,float=false,double=true,
  player='SWAMPERT',partner='PIKACHU',enemy='METAGROSS',enemyPartner='MILOTIC',map='ROUTE119',water=true,capture=true}
 cases[#cases+1]={style=1,size=1,anchor=1,view=2,shiny=true,float=false,double=true,
  player='SWAMPERT',partner='PIKACHU',enemy='METAGROSS',enemyPartner='MILOTIC',map='ROUTE119',water=true,capture=true}
 local report={engine=os.getenv('HDB_RUNTIME_VERSION'),game='emerald',loaded=loaded,versions=versions,
  tested_mod_root=testedRoot,
  species_choices=count,kim_scope='Actual public sprite provider only; full KIM scene disabled and not claimed.',cases={}}
 local first=tonumber(os.getenv('HDB_FOOTING_START'))or 1
 local total=math.min(#cases,tonumber(os.getenv('HDB_FOOTING_LIMIT'))or#cases)
 if first>1 then
  local f=assert(io.open(assert(os.getenv('HDB_FOOTING_OUTPUT'))..'/partial-report.json','rb'))
  local previous=Json.decode(f:read('*a'));f:close()
  assert(#previous.cases==first-1,'Resume index differs from preserved evidence')
  assert(previous.versions['1025dex']==versions['1025dex'],'Sprite provider changed during resume')
  report.cases=previous.cases;report.fixture_processes=(previous.fixture_processes or 1)+1
 end
 for index,case in ipairs(cases)do
 if index>=first and index<=total then
  frozen=nil
  opts.player_sprite_style=case.style;opts.enemy_sprite_style=case.style
  opts.sprite_size=case.size;opts.sprite_anchor=case.anchor;opts.player_sprite_view=case.view
  opts.sprite_float=case.float;opts.sprite_female=true;opts.sprite_shiny=true;opts.battle_shadows=false
  local state=start(case)
  -- Real public providers decode and build via their normal update hooks.
  values.enabled=true
  for _=1,180 do
   loader.hooks:call('core.update',function()end,game,1/60)
   render()
  end
  frozen=0
  values.enabled=false;local before=render();local beforeTrace=trace
  values.enabled=true;local after=render();local afterTrace=trace
  assert(before==after,'HDB changed native sprite draw arguments in case '..index)
  assert(#beforeTrace>=(case.double and 4 or 2),'Missing native sprite draws '..index)
  local d=mod.exports.diagnostics()
  assert(d.status=='active',Json.encode(d))
  assert(type(d.spriteContacts)=='table','Missing sprite contact diagnostics')
  local slots=0;for _ in pairs(d.spriteContacts.slots or{})do slots=slots+1 end
  assert(slots==(case.double and 4 or 2),'Missing calibrated contacts '..index..': '..Json.encode(d.spriteContacts))
  for _,err in pairs(d.spriteContacts.errors or{})do error('Contact lookup failed: '..tostring(err))end
  local row={index=index,case=case,native_sprite_draws_unchanged=true,draws=afterTrace,
   spriteContacts=d.spriteContacts,composition=d.composition}
  row.bodyContacts=bodyContacts(afterTrace,d.spriteContacts,case,d)
  for _,body in ipairs(row.bodyContacts)do assert(body.shiny==case.shiny,'Native shiny palette fixture mismatch')end
  if index%9==1 or(index>54 and index<=62)or case.capture then
   row.screenshot=string.format('%02d-style%d-size%d-anchor%d-%s-%s%s',index,case.style,case.size,case.anchor,case.player,case.enemy,case.double and'-double'or'')
   capture(row.screenshot)
  end
  if case.aspectReview then
   row.aspectTransitions={}
   for _,size in ipairs({{1280,720},{5120,1440},{900,1600},{1280,720}})do
    assert(love.window.setMode(size[1],size[2],{resizable=true,vsync=0}))
    values.enabled=false;local old=render();values.enabled=true;local current=render()
    assert(old==current,'Aspect transition changed native sprite arguments')
    local diagnostics=mod.exports.diagnostics()
    local check={width=size[1],height=size[2],screenshot=string.format('%02d-style%d-view%d-double-%dx%d',index,case.style,case.view,size[1],size[2])}
    capture(check.screenshot);check.bodyContacts=bodyContacts(trace,diagnostics.spriteContacts,case,diagnostics)
    row.aspectTransitions[#row.aspectTransitions+1]=check
   end
  end
  report.cases[#report.cases+1]=row
  write('partial-report.json',Json.encode(report))
  write('progress.json',Json.encode({complete=#report.cases,total=total,last=case}))
  print('FOOTING '..index..'/'..total..' style '..case.style..' PASS')
  io.stdout:flush()
 end
 end
 report.case_count=total;report.native_sprite_arguments_unchanged=true
 report.limitations='Native single/double presentation fixtures, not full move mechanics or every species in battle. Exhaustive source/frame geometry is a separate offline audit. Authored animation and intentional hovering remain unchanged.'
 write('footing-report.json',Json.encode(report))
 love.timer.getTime=nativeTime;G.draw=draw;Ui.sidePic=sidePic
 Renderer.blitCanvas=blit
end
