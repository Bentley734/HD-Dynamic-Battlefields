-- Composition selection depends on catalog data, never background-specific branches.
local M={ratios={{'4:3',4/3},{'16:9',16/9},{'16:10',16/10},{'3:2',3/2},{'21:9',21/9},{'32:9',32/9},{'9:16',9/16},{'9:19.5',9/19.5},{'9:20',9/20}}}
function M.aspect(width,height,override)
 if override and override~='auto'then
  for _,r in ipairs(M.ratios)do if r[1]==override then return override end end
  return nil,'unknown aspect family'
 end
 if type(width)~='number'or type(height)~='number'or width~=width or height~=height or width==math.huge or height==math.huge or width<=0 or height<=0 then return nil,'invalid viewport'end
 local best,distance
 for _,r in ipairs(M.ratios)do local d=math.abs(math.log((width/height)/r[2]));if not distance or d<distance then best,distance=r[1],d end end
 return best
end
local function hash(text)
 local h=0;for i=1,#text do h=(h*131+text:byte(i))%2147483647 end;return h
end
function M.new(catalog,installed,random)
 local self={active=setmetatable({},{__mode='k'}),last={},fixed={}}
 function self:exportAssignments()
  local out={};for k,v in pairs(self.fixed)do out[k]=v end;return out
 end
 function self:importAssignments(assignments)
  if type(assignments)~='table'then return nil,'invalid assignments'end
  local out={};for k,v in pairs(assignments)do if type(k)~='string'or type(v)~='string'then return nil,'invalid assignment entry'end;out[k]=v end
  self.fixed=out;return true
 end
 function self:resetAssignments()self.fixed={};self.active=setmetatable({},{__mode='k'})end
 function self:choose(battle,context,viewport,options)
  options=options or{};context=context or{}
  if type(battle)~='table'or type(viewport)~='table'then return nil,'missing battle or viewport'end
  local aspect,err=M.aspect(viewport.width,viewport.height,options.aspect);if not aspect then return nil,err end
  local environment=options.environment or context.environment
  if not environment then return nil,'unknown environment; retain native scenery'end
  local candidates={}
  for _,entry in ipairs(catalog)do
   if entry.environment==environment and entry.aspect_ratio==aspect and entry.quality==(options.quality or'HD')and installed(entry)then candidates[#candidates+1]=entry end
  end
  table.sort(candidates,function(a,b)return a.id<b.id end)
  if #candidates==0 then return nil,'no installed matching compositions; retain native scenery'end
  local location=tostring(context.game)..':'..tostring(context.map)..':'..environment
  local active=self.active[battle];local variation=active and active.environment==environment and active.variation
  local selected
  if variation then for _,entry in ipairs(candidates)do if entry.variation==variation then selected=entry;break end end end
  if not selected then
   local key=location..':'..aspect
   local id=(options.assignments or self.fixed)[key]
   if options.mode=='fixed'and id then
    local variationId=type(id)=='string'and tonumber(id:match('^variation:(%d+)$'))
    for _,entry in ipairs(candidates)do if entry.id==id or variationId and entry.variation==variationId then selected=entry;break end end
   end
   if not selected and options.mode=='fixed'then selected=candidates[hash(location)%#candidates+1]
   elseif not selected then
    local choices={};for _,entry in ipairs(candidates)do if #candidates==1 or entry.variation~=self.last[environment]then choices[#choices+1]=entry end end
    if #choices==0 then choices=candidates end
    local n=(random or math.random)(#choices);selected=choices[math.max(1,math.min(#choices,n))]
   end
   if options.mode=='fixed'then self.fixed[key]='variation:'..tostring(selected.variation)end
  end
  self.active[battle]={environment=environment,variation=selected.variation}
  self.last[environment]=selected.variation
  return selected
 end
 return self
end
return M
