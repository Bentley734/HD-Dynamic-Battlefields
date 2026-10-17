-- Native options subpages; no battle rendering or input changes.
return function(mod)
 local nativeWidth,nativeHeight=mod.exports.nativeSize()
 local Version=require('src.core.GameVersion')
 local frlg=Version.get()=='firered'or Version.get()=='leafgreen'
 local adapter=frlg and assert(loadstring(assert(mod:read('lib/adapters/frlg_settings.lua'))))()()or nil
 local Menu=not frlg and require('src.ui.OptionsMenu')or nil
 local function open(game,rows,title)
  if adapter then return adapter.open(game,rows,title)end
  local page=Menu.new(game,{rows=rows});local update=page.update
  -- Native Options prioritizes activate over step. Our own pages intercept
  -- directional input only, retaining the runtime's other navigation.
  page.update=function(self,dt)
   local input=self.game.input;local row=(self.view or self.rows)[self.index]
   if row and row.step and(input:wasPressed('left')or input:wasPressed('right'))then
    row.step(self.game,input:wasPressed('left')and -1 or 1);return
   end
   return update(self,dt)
  end
  game.stack:push(page)
 end
 local function write(game,key,value)
  game.options=game.options or{};game.options.modOptions=game.options.modOptions or{}
  local bucket=game.options.modOptions[mod.id]or{};game.options.modOptions[mod.id]=bucket
  bucket[key]=value
  if game.mods and game.mods.modOptions then game.mods.modOptions[mod.id]=bucket end
  if game.writeOptions then game:writeOptions()end
 end
 local function choice(key,label,values)
  local function index()local current=mod.options:get(key);for i,v in ipairs(values)do if v[2]==current then return i end end;return 1 end
  local row={id='hd_'..key,label=label,value=function()return values[index()][1]end}
  row.step=function(game,dir)write(game,key,values[(index()-1+(dir or 1))%#values+1][2]);return false end
  row.activate=function(game)
   local rows={}
   for _,v in ipairs(values)do local label,value=v[1],v[2]
    rows[#rows+1]={id='hd_pick_'..key..tostring(#rows+1),label=label,value=function()return mod.options:get(key)==value and'SELECTED'or''end,
     activate=function(ctx)write(ctx,key,value);ctx.stack:pop()end}
   end
   open(game,rows)
  end
  return row
 end
 local function group(id,label,rows)return{id='hd_group_'..id,label=label,group=true,value=function()return'OPEN'end,activate=function(game)open(game,rows,label)end}end
 local function toggle(key,label)return choice(key,label,{{'OFF',false},{'ON',true}})end
 local environmentChoices={}
 for _,item in ipairs(mod.exports.environmentChoices)do environmentChoices[#environmentChoices+1]={item[1]:upper(),item[2]}end
 local backgrounds={toggle('enabled','HD BACKGROUNDS'),choice('selection','VARIATION',{{'RANDOM','random'},{'FIXED','fixed'}}),
  choice('timeMode','TIME OF DAY',{{'AUTOMATIC','auto'},{'SYSTEM CLOCK','system'},{'DAY','day'},{'NIGHT','night'}}),
  choice('weatherMode','WEATHER',{{'AUTOMATIC','auto'},{'CLEAR','clear'},{'RAIN','rain'},{'SNOW','snow'},{'SANDSTORM','sandstorm'},{'FOG','fog'},{'SUNLIGHT','sun'}}),
  choice('environment','ENVIRONMENT',environmentChoices)}
 local animation={choice('animation','QUALITY',{{'OFF','off'},{'LOW','low'},{'MEDIUM','medium'},{'HIGH','high'}})}
 local status=''
 local function action(id,label,callback)return{id='hd_action_'..id,label=label,value=function()return status end,activate=function(game)
  local ok,err=callback(game);status=ok and'SAVED'or tostring(err or'FAILED')
 end}end
 backgrounds[#backgrounds+1]=action('reset_assignments','RESET FIXED ASSIGNMENTS',mod.exports.resetAssignments)
 local scope='global'
 local function adjustmentGroup(data,create)
  if scope=='global'then if create then data.global=data.global or{}end;return data.global end
  if scope:sub(1,12)=='composition:'then
   local id=scope:sub(13)
   if create then data.compositions=data.compositions or{};data.compositions[id]=data.compositions[id]or{}end
   return data.compositions and data.compositions[id]
  end
  if create then data.aspects=data.aspects or{};data.aspects[scope]=data.aspects[scope]or{}end
  return data.aspects and data.aspects[scope]
 end
 local function calibrationRow(side,key,label,default,step,minimum,maximum)
  local function current()
   local group=adjustmentGroup(mod.exports.getAdjustments());return group and group[side]and group[side][key]or default
  end
  return{id='hd_calibrate_'..side..key,label=label,value=function()return string.format('%.2f',current())end,
   step=function(game,dir)
    local data=mod.exports.getAdjustments();local group=adjustmentGroup(data,true);group[side]=group[side]or{}
    local value=math.max(minimum,math.min(maximum,current()+(dir or 1)*step))
    local units=key=='pokemon_x'and nativeWidth or key=='pokemon_y'and nativeHeight or 10000
    group[side][key]=math.floor(value*units+.5)/units
    local ok,err=mod.exports.applyAdjustments(data);status=ok and'SAVED'or tostring(err);return false
   end}
 end
 local scopeChoices={{'GLOBAL','global'}}
 for _,aspect in ipairs({'4:3','16:9','16:10','3:2','21:9','32:9','9:16','9:19.5','9:20'})do scopeChoices[#scopeChoices+1]={aspect,aspect}end
 local scopeRow={id='hd_calibration_scope',label='ADJUSTMENT SCOPE',value=function()return scope end,activate=function(game)
  local rows={};for _,item in ipairs(scopeChoices)do local label,value=item[1],item[2]
   rows[#rows+1]={label=label,id='hd_scope_'..value,activate=function(ctx)scope=value;ctx.stack:pop()end}
  end
  local composition=mod.exports.diagnostics().metadata
  if composition then rows[#rows+1]={id='hd_scope_composition',label='CURRENT BACKGROUND',value=function()return composition end,
   activate=function(ctx)scope='composition:'..composition;ctx.stack:pop()end}end
  open(game,rows)
 end}
 local mounds={toggle('mounds','BATTLE MOUNDS'),scopeRow}
 for _,side in ipairs({'player','opponent'})do
  local title=side=='player'and'PLAYER'or'OPPONENT'
  mounds[#mounds+1]=group(side,title,{
   calibrationRow(side,'mound_x','HORIZONTAL OFFSET',0,.005,-.5,.5),
   calibrationRow(side,'mound_y','VERTICAL OFFSET',0,.005,-.5,.5),
   calibrationRow(side,'mound_scale','MOUND SCALE',1,.05,.1,3),
   calibrationRow(side,'pokemon_x','POKEMON HORIZONTAL',0,1/nativeWidth,-.5,.5),
   calibrationRow(side,'pokemon_y','POKEMON VERTICAL',0,1/nativeHeight,-.5,.5)})
 end
 mounds[#mounds+1]=assert(loadstring(assert(mod:read('lib/species_settings.lua'))))()(mod,open,group)
 mounds[#mounds+1]=action('reset_scope','RESET THIS SCOPE',function()
  local data=mod.exports.getAdjustments()
  if scope=='global'then data.global=nil
  elseif scope:sub(1,12)=='composition:'then if data.compositions then data.compositions[scope:sub(13)]=nil end
  elseif data.aspects then data.aspects[scope]=nil end
  return mod.exports.applyAdjustments(data)
 end)
 mounds[#mounds+1]=action('reset_all','RESET ALL POSITIONS',function()return mod.exports.applyAdjustments({})end)
 local aspects={{'AUTOMATIC','auto'}}
 for _,item in ipairs(scopeChoices)do if item[2]~='global'then aspects[#aspects+1]=item end end
 local display={choice('aspect','ARTWORK ASPECT',aspects),toggle('calibration','VIEWPORT GUIDES'),
  choice('quality','TEXTURE TIER',{{'MOBILE','Mobile'},{'HD','HD'},{'ULTRA-HD','Ultra-HD'}}),
  {id='hd_viewport_info',label='VIEWPORT',value=function()local v=mod.exports.diagnostics().viewport;return v and(tostring(v.width)..'x'..tostring(v.height))or'--'end}}
 local diagnostics={}
 for _,item in ipairs({{'stage','BUILD'},{'game','GAME'},{'map','MAP'},{'environment','ENVIRONMENT'},{'composition','BACKGROUND'},{'metadata','METADATA'},{'quality','TEXTURE TIER'},{'aspect','ARTWORK ASPECT'},{'pack','ASSET PACK'},{'assetError','ASSET ERROR'},{'period','ARTWORK PERIOD'},{'weather','WEATHER'},{'status','STATUS'},{'reason','FALLBACK REASON'}})do
  local key,label=item[1],item[2]
  diagnostics[#diagnostics+1]={id='hd_diag_'..key,label=label,value=function()return tostring(mod.exports.diagnostics()[key]or'--')end}
 end
 diagnostics[#diagnostics+1]=toggle('calibration','CALIBRATION GUIDES')
 diagnostics[#diagnostics+1]=action('export_calibration','EXPORT CALIBRATION DRAFT',mod.exports.exportCalibration)
 diagnostics[#diagnostics+1]={id='hd_last_export',label='LAST EXPORT',value=function()return mod.exports.diagnostics().lastExport or'NONE'end}
 local function module(path)return assert(loadstring(assert(mod:read(path)),'@'..mod.path..'/'..path))()end
 local assets=module('lib/asset_manager.lua')(mod,open,module('metadata/asset_index.lua'),module('lib/compositions.lua'))
 local rows={group('backgrounds','BACKGROUNDS',backgrounds),group('animation','ANIMATION',animation),group('mounds','MOUNDS',mounds),group('display','DISPLAY',display),assets,group('diagnostics','DIAGNOSTICS',diagnostics)}
 if adapter then adapter.mount(group('root','HD BATTLEFIELDS',rows));return end
 mod.hooks:wrap('ui.options.rows',function(nextFn,game,native)
  local result=nextFn(game,native);local out={};for _,row in ipairs(result)do out[#out+1]=row end
  out[#out+1]=group('root','HD BATTLEFIELDS',rows);return out
 end)
end
