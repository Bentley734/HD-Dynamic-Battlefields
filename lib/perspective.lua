-- Pure data resolver: no graphics, game, filesystem or mutable catalog state.
local M={schema=1}
local function copy(t)
 if type(t)~='table'then return t end
 local out={};for k,v in pairs(t)do out[k]=copy(v)end;return out
end
local function merge(a,b)
 local out=copy(a or{})
 for k,v in pairs(b or{})do
  if type(v)=='table'and type(out[k])=='table'then out[k]=merge(out[k],v)else out[k]=copy(v)end
 end
 return out
end
local function finite(n)return type(n)=='number'and n==n and n~=math.huge and n~=-math.huge end
local function point(p)return type(p)=='table'and finite(p[1])and finite(p[2])end
function M.validate(d)
 if type(d)~='table'or d.schema_version~=M.schema then return nil,'unsupported metadata schema'end
 if type(d.composition_id)~='string'or d.composition_id==''then return nil,'missing composition ID'end
 local r=d.reference_size
 if type(r)~='table'or not finite(r.width)or not finite(r.height)or r.width<=0 or r.height<=0 then return nil,'invalid reference size'end
 if type(d.aspect_ratio)~='string'or not finite(d.horizon_y)or d.horizon_y<0 or d.horizon_y>1 then return nil,'invalid perspective'end
 if type(d.depth)~='table'or not finite(d.depth.player)or not finite(d.depth.opponent)then return nil,'missing depth'end
 local safe=d.safe_area
 if type(safe)~='table'or not finite(safe.left)or not finite(safe.top)or not finite(safe.right)or not finite(safe.bottom)or safe.left<0 or safe.top<0 or safe.right>1 or safe.bottom>1 or safe.left>=safe.right or safe.top>=safe.bottom then return nil,'invalid safe area'end
 for _,side in ipairs({'player','opponent'})do
  local p=d[side]
  if type(p)~='table'or not point(p.mound_anchor)or not point(p.pokemon_ground_anchor)or not point(p.shadow_offset)or not finite(p.mound_scale)or p.mound_scale<=0 or not finite(p.sprite_scale)or p.sprite_scale<=0 or not point(p.mound_bounds)or p.mound_bounds[1]<=0 or p.mound_bounds[2]<=0 then return nil,'invalid '..side..' anchors'end
  if not finite(p.layer)then return nil,'missing '..side..' layer'end
  if p.mound_origin~=nil and(not point(p.mound_origin)or p.mound_origin[1]<0 or p.mound_origin[1]>1 or p.mound_origin[2]<0 or p.mound_origin[2]>1)then return nil,'invalid '..side..' mound image origin'end
  if d.hud then
   local hud=type(d.hud)=='table'and d.hud[side]
   if type(hud)~='table'or not point(hud.anchor)or not finite(hud.pixel_scale)or hud.pixel_scale<=0 then return nil,'invalid '..side..' HUD layout'end
  end
 end
 if d.hud then
  for _,key in ipairs({'bottom','moveSelect','mimicSelect'})do
   local spec=d.hud[key]
   if spec~=nil and(type(spec)~='table'or not point(spec.anchor)or not finite(spec.pixel_scale)or spec.pixel_scale<=0)then return nil,'invalid '..key..' UI layout'end
   if spec and spec.hud_overrides~=nil then
    if type(spec.hud_overrides)~='table'then return nil,'invalid phase HUD overrides'end
    for side,hud in pairs(spec.hud_overrides)do
     if side~='player'and side~='opponent'or type(hud)~='table'or not point(hud.anchor)or not finite(hud.pixel_scale)or hud.pixel_scale<=0 then return nil,'invalid phase HUD override'end
    end
   end
  end
  if d.hud.paper~=nil then
   if type(d.hud.paper)~='table'or #d.hud.paper~=4 then return nil,'invalid HUD paper'end
   for _,n in ipairs(d.hud.paper)do if not finite(n)or n<0 or n>1 then return nil,'invalid HUD paper color'end end
  end
 end
 return true
end
function M.resolve(catalog,id)
 if type(catalog)~='table'then return nil,'invalid metadata catalog'end
 local visiting={}
 local function resolve(key,depth)
  if depth>64 then return nil,'metadata inheritance exceeds 64 levels'end
  if visiting[key]then return nil,'metadata inheritance cycle'end
  local d=catalog[key];if type(d)~='table'then return nil,'missing metadata: '..tostring(key)end
  visiting[key]=true;local base={}
  if d.inherits then local err;base,err=resolve(d.inherits,depth+1);if not base then return nil,err end end
  visiting[key]=nil;return merge(base,d)
 end
 local d,err=resolve(id,1);if not d then return nil,err end
 local ok;ok,err=M.validate(d);if not ok then return nil,err end
 return d
end
function M.validateAdjustments(a)
 if a==nil then return true end
 if type(a)~='table'then return nil,'invalid adjustment settings'end
 local allowed={mound_x=true,mound_y=true,pokemon_x=true,pokemon_y=true,mound_scale=true}
 local function group(t)
  if t==nil then return true end
  if type(t)~='table'then return nil,'invalid adjustment group'end
  for side,u in pairs(t)do
   if side~='player'and side~='opponent'or type(u)~='table'then return nil,'invalid adjustment side'end
   for key,value in pairs(u)do
    if not allowed[key]or not finite(value)or key=='mound_scale'and value<=0 then return nil,'invalid adjustment: '..tostring(key)end
   end
  end
  return true
 end
 for k in pairs(a)do if k~='global'and k~='aspects'and k~='compositions'then return nil,'unknown adjustment group'end end
 local ok,err=group(a.global);if not ok then return nil,err end
 if a.aspects~=nil then
  if type(a.aspects)~='table'then return nil,'invalid aspect adjustments'end
  for aspect,t in pairs(a.aspects)do
   if type(aspect)~='string'then return nil,'invalid aspect key'end
   ok,err=group(t);if not ok then return nil,err end
  end
 end
 if a.compositions~=nil then
  if type(a.compositions)~='table'then return nil,'invalid composition adjustments'end
  for id,t in pairs(a.compositions)do
   if type(id)~='string'or #id==0 or #id>512 then return nil,'invalid composition key'end
   ok,err=group(t);if not ok then return nil,err end
  end
 end
 return true
end
function M.layout(d,viewport,adjustments,corrections)
 local ok,err=M.validate(d);if not ok then return nil,err end
 if not viewport or not finite(viewport.width)or not finite(viewport.height)or viewport.width<=0 or viewport.height<=0 then return nil,'invalid viewport'end
 local w,h=viewport.width,viewport.height;local x,y=viewport.x or 0,viewport.y or 0
 if not finite(x)or not finite(y)then return nil,'invalid viewport origin'end
 ok,err=M.validateAdjustments(adjustments);if not ok then return nil,err end
 local a=adjustments or{};a=merge(merge(a.global,a.aspects and a.aspects[d.aspect_ratio]),a.compositions and a.compositions[d.composition_id])
 local out={composition_id=d.composition_id,horizon=y+d.horizon_y*h,safe_area={x=x+d.safe_area.left*w,y=y+d.safe_area.top*h,w=(d.safe_area.right-d.safe_area.left)*w,h=(d.safe_area.bottom-d.safe_area.top)*h}}
 for _,side in ipairs({'player','opponent'})do
  local p=d[side];local u=a[side]or{};local c=corrections and corrections[side]or{}
  if type(u)~='table'or type(c)~='table'then return nil,'invalid correction data'end
  if c.x~=nil and not finite(c.x)or c.y~=nil and not finite(c.y)or c.scale~=nil and (not finite(c.scale)or c.scale<=0)then return nil,'invalid sprite correction'end
  for _,k in ipairs({'mound_x','mound_y','pokemon_x','pokemon_y'})do if u[k]~=nil and not finite(u[k])then return nil,'invalid user offset'end end
  local scale=u.mound_scale or 1;if not finite(scale)or scale<=0 then return nil,'invalid user scale'end
  out[side]={mound={x=x+(p.mound_anchor[1]+(u.mound_x or 0))*w,y=y+(p.mound_anchor[2]+(u.mound_y or 0))*h,scale=p.mound_scale*scale,bounds={p.mound_bounds[1]*w,p.mound_bounds[2]*h}},
   pokemon={x=x+(p.pokemon_ground_anchor[1]+(u.pokemon_x or 0)+(c.x or 0))*w,y=y+(p.pokemon_ground_anchor[2]+(u.pokemon_y or 0)+(c.y or 0))*h,scale=p.sprite_scale*(c.scale or 1)},
   shadow={x=p.shadow_offset[1]*w,y=p.shadow_offset[2]*h},layer=p.layer,depth=d.depth[side]}
  if p.mound_origin then out[side].mound.origin={p.mound_origin[1],p.mound_origin[2]}end
 end
 return out
end
function M.spriteOrigin(anchor,width,height,contact,scale)
 if type(anchor)~='table'or not finite(anchor.x)or not finite(anchor.y)or not point(contact)or not finite(width)or width<=0 or not finite(height)or height<=0 or not finite(scale)or scale<=0 then return nil,'invalid sprite contact'end
 return {x=anchor.x-contact[1]*width*scale,y=anchor.y-contact[2]*height*scale}
end
return M
