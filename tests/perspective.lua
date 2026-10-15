local M=assert(loadfile(root..'/lib/perspective.lua'))()
-- Synthetic coordinates are test fixtures, not calibrated production metadata.
local template={schema_version=1,composition_id='fixture',reference_size={width=5120,height=1440},aspect_ratio='32:9',horizon_y=.4,depth={player=1,opponent=.7},safe_area={left=.03,top=.04,right=.97,bottom=.96},player={mound_anchor={.3,.78},pokemon_ground_anchor={.3,.75},shadow_offset={0,.01},mound_scale=1,sprite_scale=1,mound_bounds={.2,.08},layer=20},opponent={mound_anchor={.72,.52},pokemon_ground_anchor={.72,.49},shadow_offset={0,.01},mound_scale=.7,sprite_scale=.7,mound_bounds={.15,.05},layer=10}}
local catalog={base=template,forest={inherits='base',composition_id='forest',lighting={ambient=.7}},cave={inherits='base',composition_id='cave',horizon_y=.3}}
local forest=assert(M.resolve(catalog,'forest'));assert(forest.player~=template.player)
local edits={global={player={mound_x=.01}},aspects={['32:9']={player={pokemon_y=.02}}}}
local p=assert(M.layout(forest,{width=5120,height=1440},edits))
assert(math.abs(p.player.mound.x-1587.2)<.001 and math.abs(p.player.pokemon.y-1108.8)<.001)
assert(template.player.mound_anchor[1]==.3 and edits.global.player.mound_x==.01)
local resized=assert(M.layout(forest,{width=2560,height=720}));assert(resized.opponent.pokemon.x==p.opponent.pokemon.x/2)
local cave=assert(M.resolve(catalog,'cave'));assert(cave.horizon_y==.3 and forest.horizon_y==.4)
catalog.cycle={inherits='cycle'};assert(not M.resolve(catalog,'cycle'));assert(not M.resolve(catalog,'missing'))
forest.schema_version=99;assert(not M.validate(forest));forest.schema_version=1
assert(not M.layout(forest,{width=0,height=1440}))
local origin=assert(M.spriteOrigin({x=100,y=200},80,120,{.45,.9},2));assert(origin.x==28 and origin.y==-16)
assert(not M.layout(forest,{x=0/0,width=100,height=100}))
assert(not M.layout(forest,{width=100,height=100},nil,{player={scale=-1}}))
local scaled=assert(M.layout(forest,{width=5120,height=1440},{global={player={mound_scale=2}}}))
assert(scaled.player.mound.scale==2 and scaled.player.mound.bounds[1]==5120*.2)
for _,bad in ipairs({true,{global=true},{aspects=true},{global={enemy={mound_x=1}}},{global={player={mound_scale=-1}}},{aspects={['16:9']={player={pokemon_x=0/0}}}}})do
 assert(not M.validateAdjustments(bad));assert(not M.layout(forest,{width=100,height=100},bad))
end
assert(not M.resolve(false,'missing'))
forest.opponent.mound_origin={.5,.62}
local isletLayout=assert(M.layout(forest,{width=1920,height=1080}))
assert(isletLayout.opponent.mound.origin[2]==.62)
isletLayout.opponent.mound.origin[2]=.1
assert(forest.opponent.mound_origin[2]==.62,'Layout must not mutate authored image origin')
forest.opponent.mound_origin={.5,1.1};assert(not M.validate(forest))
forest.opponent.mound_origin=nil
local prototype=assert(loadfile(root..'/metadata/prototype.lua'))()
for _,entry in ipairs(prototype.compositions)do
 local d=assert(M.resolve(prototype.metadata,entry.metadata));assert(d.composition_id==entry.id and d.aspect_ratio==entry.aspect_ratio)
 assert(d.hud==nil,'Scenery metadata must not configure battle UI')
end
print('PASS metadata inheritance, cycles/missing/schema validation, immutable adjustments, 5120x1440 layout, resizing, contact-point positioning')

-- Raised grassland framing must keep the distant horizon above the native
-- opponent's ground plane without changing the native sprite/HUD slots.
for _,id in ipairs({'grassland-01-16x9','grassland-01-32x9'})do
 local metadata=assert(M.resolve(prototype.metadata,id))
 assert(metadata.horizon_y>0 and metadata.horizon_y<.28,'Grassland horizon is too low')
end
