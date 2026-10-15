-- Calibration draft. Entries are registered only after their original artwork
-- exists. Remaining environment/aspect variations are not silently substituted.
local base = {schema_version=1,composition_id='meadow-perspective-16x9',
 reference_size={width=1920,height=1080},aspect_ratio='16:9',horizon_y=.40,
 depth={player=1,opponent=.75},safe_area={left=.06,top=.07,right=.94,bottom=.76},
 player={mound_anchor={.28,.66},pokemon_ground_anchor={.28,.64},mound_scale=1,
  sprite_scale=5,shadow_offset={0,.008},mound_bounds={.30,.19},layer=20},
 opponent={mound_anchor={.72,.45},pokemon_ground_anchor={.72,.43},mound_scale=.75,
  sprite_scale=4,shadow_offset={0,.008},mound_bounds={.28,.17},layer=10}}
local metadata={['meadow-perspective-16x9']=base}
metadata['meadow-perspective-32x9']={inherits='meadow-perspective-16x9',composition_id='meadow-perspective-32x9',
 reference_size={width=5120,height=1440},aspect_ratio='32:9',horizon_y=.46,
 player={mound_anchor={.34,.68},pokemon_ground_anchor={.34,.66},sprite_scale=7,mound_bounds={.16,.17}},
 opponent={mound_anchor={.66,.52},pokemon_ground_anchor={.66,.50},sprite_scale=6,mound_bounds={.16,.16}}}
metadata['meadow-perspective-9x16']={inherits='meadow-perspective-16x9',composition_id='meadow-perspective-9x16',
 reference_size={width=900,height=1600},aspect_ratio='9:16',horizon_y=.33,
 safe_area={left=.04,top=.05,right=.96,bottom=.80},
 player={mound_anchor={.29,.65},pokemon_ground_anchor={.29,.63},sprite_scale=5,mound_bounds={.54,.15}},
 opponent={mound_anchor={.70,.4075},pokemon_ground_anchor={.70,.40},sprite_scale=4,mound_bounds={.47,.12}}}
local compositions={}
for _,environment in ipairs({'grassland','forest','cave'})do
 local id=environment..'-01-16x9'
 metadata[id]={inherits='meadow-perspective-16x9',composition_id=id}
 compositions[#compositions+1]={id=id,environment=environment,variation=1,aspect_ratio='16:9',quality='HD',
  metadata=id,background='art/source/'..environment..'-01-16x9.png'}
 if environment=='grassland'then
  -- Authored lower framing: the distant ground must be above the native
  -- opponent's feet. Preserve a uniform 16:9 sample; do not move the HUD
  -- or native battlers to compensate for scenery perspective.
  compositions[#compositions].source_rect={x=195.1111111111,y=220,width=1281.7777777778,height=721}
  metadata[id].horizon_y=(.40*941-220)/721
 end
 local material=environment=='grassland'and'grass'or environment
 compositions[#compositions].mounds={player='art/source/mound-'..material..'-01.png',opponent='art/source/mound-'..material..'-01.png'}
end
metadata['grassland-01-32x9']={inherits='meadow-perspective-32x9',composition_id='grassland-01-32x9',horizon_y=(64+.46*604.40625-200)/532}
compositions[#compositions+1]={id='grassland-01-32x9',environment='grassland',variation=1,aspect_ratio='32:9',quality='HD',
 metadata='grassland-01-32x9',background='art/source/grassland-01-32x9.png',
 -- Original panoramic illustration, with a calibrated region excluding
 -- surplus sky/foreground. The image is not stretched into this region.
 source_rect={x=128.7222222222,y=200,width=1891.5555555556,height=532},
 mounds={player='art/source/mound-grass-01.png',opponent='art/source/mound-grass-01.png'}}
metadata['grassland-01-9x16']={inherits='meadow-perspective-9x16',composition_id='grassland-01-9x16'}
compositions[#compositions+1]={id='grassland-01-9x16',environment='grassland',variation=1,aspect_ratio='9:16',quality='HD',
 metadata='grassland-01-9x16',background='art/source/grassland-01-9x16.png',
 mounds={player='art/source/mound-grass-01.png',opponent='art/source/mound-grass-01.png'}}
metadata['forest-01-32x9']={inherits='meadow-perspective-32x9',composition_id='forest-01-32x9'}
compositions[#compositions+1]={id='forest-01-32x9',environment='forest',variation=1,aspect_ratio='32:9',quality='HD',
 metadata='forest-01-32x9',background='art/source/forest-01-32x9.png',
 source_rect={x=0,y=80,width=2089,height=587.53125},
 mounds={player='art/source/mound-forest-01.png',opponent='art/source/mound-forest-01.png'}}
metadata['cave-01-32x9']={inherits='meadow-perspective-32x9',composition_id='cave-01-32x9',horizon_y=.30,
 opponent={pokemon_ground_anchor={.66,.55},mound_anchor={.66,.57}}}
compositions[#compositions+1]={id='cave-01-32x9',environment='cave',variation=1,aspect_ratio='32:9',quality='HD',
 metadata='cave-01-32x9',background='art/source/cave-01-32x9.png',
 source_rect={x=0,y=235,width=1983,height=557.71875},
 mounds={player='art/source/mound-cave-01.png',opponent='art/source/mound-cave-01.png'}}
metadata['forest-01-9x16']={inherits='meadow-perspective-9x16',composition_id='forest-01-9x16',horizon_y=.355}
compositions[#compositions+1]={id='forest-01-9x16',environment='forest',variation=1,aspect_ratio='9:16',quality='HD',
 metadata='forest-01-9x16',background='art/source/forest-01-9x16.png',
 mounds={player='art/source/mound-forest-01.png',opponent='art/source/mound-forest-01.png'}}
metadata['cave-01-9x16']={inherits='meadow-perspective-9x16',composition_id='cave-01-9x16',horizon_y=.445,
 opponent={pokemon_ground_anchor={.70,.49},mound_anchor={.70,.4975}}}
compositions[#compositions+1]={id='cave-01-9x16',environment='cave',variation=1,aspect_ratio='9:16',quality='HD',
 metadata='cave-01-9x16',background='art/source/cave-01-9x16.png',
 mounds={player='art/source/mound-cave-01.png',opponent='art/source/mound-cave-01.png'}}
metadata['grassland-02-16x9']={inherits='meadow-perspective-16x9',composition_id='grassland-02-16x9',horizon_y=.28}
compositions[#compositions+1]={id='grassland-02-16x9',environment='grassland',variation=2,aspect_ratio='16:9',quality='HD',
 metadata='grassland-02-16x9',background='art/source/grassland-02-16x9.png',
 mounds={player='art/source/mound-grass-01.png',opponent='art/source/mound-grass-01.png'}}
metadata['grassland-02-32x9']={inherits='meadow-perspective-32x9',composition_id='grassland-02-32x9',horizon_y=.25}
compositions[#compositions+1]={id='grassland-02-32x9',environment='grassland',variation=2,aspect_ratio='32:9',quality='HD',
 metadata='grassland-02-32x9',background='art/source/grassland-02-32x9.png',
 source_rect={x=0,y=165,width=2089,height=587.53125},
 night_source_rect={x=0,y=166,width=2087,height=586.96875},
 mounds={player='art/source/mound-grass-01.png',opponent='art/source/mound-grass-01.png'}}
metadata['grassland-02-9x16']={inherits='meadow-perspective-9x16',composition_id='grassland-02-9x16',horizon_y=.28}
compositions[#compositions+1]={id='grassland-02-9x16',environment='grassland',variation=2,aspect_ratio='9:16',quality='HD',
 metadata='grassland-02-9x16',background='art/source/grassland-02-9x16.png',
 mounds={player='art/source/mound-grass-01.png',opponent='art/source/mound-grass-01.png'}}
for _,spec in ipairs({{'4x3','4:3',1440,1080},{'16x10','16:10',1600,1000},{'3x2','3:2',1536,1024}})do
 local id='grassland-02-'..spec[1]
 metadata[id]={inherits='meadow-perspective-16x9',composition_id=id,aspect_ratio=spec[2],
  reference_size={width=spec[3],height=spec[4]},horizon_y=.28}
 compositions[#compositions+1]={id=id,environment='grassland',variation=2,aspect_ratio=spec[2],quality='HD',
  metadata=id,background='art/source/'..id..'.png',
  mounds={player='art/source/mound-grass-01.png',opponent='art/source/mound-grass-01.png'}}
end
for _,spec in ipairs({{'21x9','21:9',2520,1080,'meadow-perspective-16x9'},
 {'9x19_5','9:19.5',900,1950,'meadow-perspective-9x16'},
 {'9x20','9:20',900,2000,'meadow-perspective-9x16'}})do
 local id='grassland-02-'..spec[1]
 metadata[id]={inherits=spec[5],composition_id=id,aspect_ratio=spec[2],
  reference_size={width=spec[3],height=spec[4]},horizon_y=.28}
 compositions[#compositions+1]={id=id,environment='grassland',variation=2,aspect_ratio=spec[2],quality='HD',
  metadata=id,background='art/source/'..id..'.png',
  mounds={player='art/source/mound-grass-01.png',opponent='art/source/mound-grass-01.png'}}
end
metadata['grassland-03-16x9']={inherits='meadow-perspective-16x9',composition_id='grassland-03-16x9',horizon_y=.27}
compositions[#compositions+1]={id='grassland-03-16x9',environment='grassland',variation=3,aspect_ratio='16:9',quality='HD',
 metadata='grassland-03-16x9',background='art/source/grassland-03-16x9.png',
 mounds={player='art/source/mound-grass-01.png',opponent='art/source/mound-grass-01.png'}}
for _,aspect in ipairs({'32x9','9x16'})do
 local id='grassland-03-'..aspect
 metadata[id]={inherits='meadow-perspective-'..aspect,composition_id=id,horizon_y=.27}
 local entry={id=id,environment='grassland',variation=3,aspect_ratio=aspect=='32x9'and'32:9'or'9:16',quality='HD',
  metadata=id,background='art/source/'..id..'.png',
  mounds={player='art/source/mound-grass-01.png',opponent='art/source/mound-grass-01.png'}}
 if aspect=='32x9'then
  entry.source_rect={x=0,y=100,width=2172,height=610.875}
  entry.night_source_rect={x=0,y=100,width=2172,height=610.875}
  metadata[id].horizon_y=(.27*724-100)/610.875
 end
 compositions[#compositions+1]=entry
end
metadata['forest-02-16x9']={inherits='meadow-perspective-16x9',composition_id='forest-02-16x9',horizon_y=.39}
compositions[#compositions+1]={id='forest-02-16x9',environment='forest',variation=2,aspect_ratio='16:9',quality='HD',
 metadata='forest-02-16x9',background='art/source/forest-02-16x9.png',
 mounds={player='art/source/mound-forest-01.png',opponent='art/source/mound-forest-01.png'}}
metadata['cave-02-16x9']={inherits='meadow-perspective-16x9',composition_id='cave-02-16x9',horizon_y=(.39*941-101)/840}
compositions[#compositions+1]={id='cave-02-16x9',environment='cave',variation=2,aspect_ratio='16:9',quality='HD',
 metadata='cave-02-16x9',background='art/source/cave-02-16x9.png',
 source_rect={x=89.3333333333,y=101,width=1493.3333333333,height=840},
 mounds={player='art/source/mound-sandstone-01.png',opponent='art/source/mound-sandstone-01.png'}}
metadata['forest-03-16x9']={inherits='meadow-perspective-16x9',composition_id='forest-03-16x9',horizon_y=.38}
compositions[#compositions+1]={id='forest-03-16x9',environment='forest',variation=3,aspect_ratio='16:9',quality='HD',
 metadata='forest-03-16x9',background='art/source/forest-03-16x9.png',
 mounds={player='art/source/mound-autumn-01.png',opponent='art/source/mound-autumn-01.png'}}
for _,aspect in ipairs({'32x9','9x16'})do
 local id='forest-02-'..aspect
 metadata[id]={inherits='meadow-perspective-'..aspect,composition_id=id,horizon_y=.34}
 local entry={id=id,environment='forest',variation=2,aspect_ratio=aspect=='32x9'and'32:9'or'9:16',quality='HD',
  metadata=id,background='art/source/'..id..'.png',
  mounds={player='art/source/mound-forest-01.png',opponent='art/source/mound-forest-01.png'}}
 if aspect=='32x9'then
  entry.source_rect={x=0,y=147.875,width=2116,height=595.125}
  entry.night_source_rect={x=0,y=147.875,width=2116,height=595.125}
  metadata[id].horizon_y=(.44*743-147.875)/595.125
 end
 compositions[#compositions+1]=entry
end
for _,aspect in ipairs({'32x9','9x16'})do
 local id='cave-02-'..aspect
 metadata[id]={inherits='meadow-perspective-'..aspect,composition_id=id,horizon_y=.33}
 local entry={id=id,environment='cave',variation=2,aspect_ratio=aspect=='32x9'and'32:9'or'9:16',quality='HD',
  metadata=id,background='art/source/'..id..'.png',
  mounds={player='art/source/mound-sandstone-01.png',opponent='art/source/mound-sandstone-01.png'}}
 if aspect=='32x9'then
  entry.source_rect={x=0,y=147.875,width=2116,height=595.125}
  metadata[id].horizon_y=(.44*743-147.875)/595.125
 end
 compositions[#compositions+1]=entry
end
for _,spec in ipairs({{'16x9','16:9',.32},{'32x9','32:9',.18},{'9x16','9:16',.32}})do
 local id='cave-03-'..spec[1]
 metadata[id]={inherits='meadow-perspective-'..spec[1],composition_id=id,horizon_y=spec[3]}
 local entry={id=id,environment='cave',variation=3,aspect_ratio=spec[2],quality='HD',
  metadata=id,background='art/source/'..id..'.png',
  mounds={player='art/source/mound-limestone-02.png',opponent='art/source/mound-limestone-02.png'}}
 if spec[1]=='32x9'then
  entry.source_rect={x=0,y=130,width=2121,height=596.53125}
 end
 compositions[#compositions+1]=entry
end
for _,spec in ipairs({{'4x3','4:3',1440,1080},{'16x10','16:10',1600,1000},{'3x2','3:2',1536,1024}})do
 local id='forest-02-'..spec[1]
 metadata[id]={inherits='meadow-perspective-16x9',composition_id=id,aspect_ratio=spec[2],
  reference_size={width=spec[3],height=spec[4]},horizon_y=.38}
 compositions[#compositions+1]={id=id,environment='forest',variation=2,aspect_ratio=spec[2],quality='HD',
  metadata=id,background='art/source/'..id..'.png',
  mounds={player='art/source/mound-forest-01.png',opponent='art/source/mound-forest-01.png'}}
end
for _,spec in ipairs({{'21x9','21:9',2520,1080,'meadow-perspective-16x9'},
 {'9x19_5','9:19.5',900,1950,'meadow-perspective-9x16'},
 {'9x20','9:20',900,2000,'meadow-perspective-9x16'}})do
 local id='forest-02-'..spec[1]
 metadata[id]={inherits=spec[5],composition_id=id,aspect_ratio=spec[2],
  reference_size={width=spec[3],height=spec[4]},horizon_y=.30}
 compositions[#compositions+1]={id=id,environment='forest',variation=2,aspect_ratio=spec[2],quality='HD',
  metadata=id,background='art/source/'..id..'.png',
  mounds={player='art/source/mound-forest-01.png',opponent='art/source/mound-forest-01.png'}}
end
metadata['beach-01-16x9']={inherits='meadow-perspective-16x9',composition_id='beach-01-16x9',horizon_y=.30}
compositions[#compositions+1]={id='beach-01-16x9',environment='beach',variation=1,aspect_ratio='16:9',quality='HD',
 metadata='beach-01-16x9',background='art/source/beach-01-16x9.png',
 mounds={player='art/source/mound-sand-01.png',opponent='art/source/mound-sand-01.png'}}
for _,spec in ipairs({{2,'sand'},{3,'gray-sand'}})do
 local id='beach-0'..spec[1]..'-16x9'
 metadata[id]={inherits='meadow-perspective-16x9',composition_id=id,horizon_y=.30}
 compositions[#compositions+1]={id=id,environment='beach',variation=spec[1],aspect_ratio='16:9',quality='HD',
  metadata=id,background='art/source/'..id..'.png',
  mounds={player='art/source/mound-'..spec[2]..'-01.png',opponent='art/source/mound-'..spec[2]..'-01.png'}}
end
for _,aspect in ipairs({'32x9','9x16'})do
 local id='beach-01-'..aspect
 metadata[id]={inherits='meadow-perspective-'..aspect,composition_id=id,horizon_y=.23}
 local entry={id=id,environment='beach',variation=1,aspect_ratio=aspect=='32x9'and'32:9'or'9:16',quality='HD',
  metadata=id,background='art/source/'..id..'.png',
  mounds={player='art/source/mound-sand-01.png',opponent='art/source/mound-sand-01.png'}}
 if aspect=='32x9'then
  entry.source_rect={x=0,y=100,width=2116,height=595.125}
  entry.night_source_rect={x=0,y=100,width=2116,height=595.125}
 end
 compositions[#compositions+1]=entry
end
metadata['mountain-01-16x9']={inherits='meadow-perspective-16x9',composition_id='mountain-01-16x9',horizon_y=(.40*941-100)/840}
compositions[#compositions+1]={id='mountain-01-16x9',environment='mountain',variation=1,aspect_ratio='16:9',quality='HD',
 metadata='mountain-01-16x9',background='art/source/mountain-01-16x9.png',
 source_rect={x=89.3333333333,y=100,width=1493.3333333333,height=840},
 night_source_rect={x=89.3333333333,y=100,width=1493.3333333333,height=840},
 mounds={player='art/source/mound-highland-01.png',opponent='art/source/mound-highland-01.png'}}
for _,spec in ipairs({{2,'highland',.30},{3,'terracotta',.35}})do
 local id='mountain-0'..spec[1]..'-16x9'
 metadata[id]={inherits='meadow-perspective-16x9',composition_id=id,horizon_y=spec[3]}
 compositions[#compositions+1]={id=id,environment='mountain',variation=spec[1],aspect_ratio='16:9',quality='HD',
  metadata=id,background='art/source/'..id..'.png',
  mounds={player='art/source/mound-'..spec[2]..'-01.png',opponent='art/source/mound-'..spec[2]..'-01.png'}}
end
for _,aspect in ipairs({'32x9','9x16'})do
 local id='mountain-01-'..aspect
 metadata[id]={inherits='meadow-perspective-'..aspect,composition_id=id,horizon_y=.32}
 local entry={id=id,environment='mountain',variation=1,aspect_ratio=aspect=='32x9'and'32:9'or'9:16',quality='HD',
  metadata=id,background='art/source/'..id..'.png',
  mounds={player='art/source/mound-highland-01.png',opponent='art/source/mound-highland-01.png'}}
 if aspect=='32x9'then
  entry.background='art/source/mountain-01-32x9-v2.png'
  metadata[id].horizon_y=.30
  -- Revised painting keeps the complete skyline in this uniform top sample.
  entry.source_rect={x=0,y=0,width=2116,height=595.125}
  entry.night_source_rect={x=0,y=0,width=2115,height=594.84375}
 end
 compositions[#compositions+1]=entry
end
for _,spec in ipairs({
 {'4x3','4:3',1440,1080,'meadow-perspective-16x9',.33,{x=57.3333333333,y=80,width=1333.3333333333,height=1000}},
 {'16x10','16:10',1600,1000,'meadow-perspective-16x9',.34,{x=73,y=90,width=1440,height=900}},
 {'3x2','3:2',1536,1024,'meadow-perspective-16x9',.33,{x=63,y=80,width=1410,height=940}},
 {'21x9','21:9',2520,1080,'meadow-perspective-16x9',.29,{x=188,y=160,width=1540,height=660}},
 {'9x19_5','9:19.5',900,1950,'meadow-perspective-9x16',.36},
 {'9x20','9:20',900,2000,'meadow-perspective-9x16',.28}})do
 local id='mountain-01-'..spec[1]
 metadata[id]={inherits=spec[5],composition_id=id,aspect_ratio=spec[2],
  reference_size={width=spec[3],height=spec[4]},horizon_y=spec[6]}
 compositions[#compositions+1]={id=id,environment='mountain',variation=1,aspect_ratio=spec[2],quality='HD',
  metadata=id,background='art/source/'..id..'.png',source_rect=spec[7],night_source_rect=spec[7],
  mounds={player='art/source/mound-highland-01.png',opponent='art/source/mound-highland-01.png'}}
 if spec[1]=='21x9'then
  local entry=compositions[#compositions]
  entry.background='art/source/mountain-01-21x9-v2.png'
  entry.source_rect,entry.night_source_rect=nil,nil
  metadata[id].horizon_y=.27
 end
end
for variation=1,3 do
 local id='rocky_terrain-0'..variation..'-16x9'
 metadata[id]={inherits='meadow-perspective-16x9',composition_id=id,horizon_y=.34}
 compositions[#compositions+1]={id=id,environment='rocky_terrain',variation=variation,aspect_ratio='16:9',quality='HD',
  metadata=id,background='art/source/'..id..'.png',
  mounds={player='art/source/mound-gravel-01.png',opponent='art/source/mound-gravel-01.png'}}
end
for _,aspect in ipairs({'32x9','9x16'})do
 local id='rocky_terrain-01-'..aspect
 metadata[id]={inherits='meadow-perspective-'..aspect,composition_id=id,horizon_y=.29}
 local entry={id=id,environment='rocky_terrain',variation=1,aspect_ratio=aspect=='32x9'and'32:9'or'9:16',quality='HD',
  metadata=id,background='art/source/'..id..'.png',
  mounds={player='art/source/mound-gravel-01.png',opponent='art/source/mound-gravel-01.png'}}
 if aspect=='32x9'then
  entry.source_rect={x=0,y=100,width=2115,height=594.84375}
  entry.night_source_rect={x=0,y=100,width=2115,height=594.84375}
 end
 compositions[#compositions+1]=entry
end
metadata['rocky_terrain-01-4x3']={inherits='meadow-perspective-16x9',composition_id='rocky_terrain-01-4x3',
 reference_size={width=1448,height=1086},aspect_ratio='4:3',horizon_y=.34}
compositions[#compositions+1]={id='rocky_terrain-01-4x3',environment='rocky_terrain',variation=1,
 aspect_ratio='4:3',quality='HD',metadata='rocky_terrain-01-4x3',background='art/source/rocky_terrain-01-4x3.png',
 mounds={player='art/source/mound-pale-gravel-01.png',opponent='art/source/mound-pale-gravel-01.png'}}
for _,spec in ipairs({
 {'16x10','16:10',1600,1000,'meadow-perspective-16x9',.35},
 {'3x2','3:2',1536,1024,'meadow-perspective-16x9',.34},
 {'21x9','21:9',2520,1080,'meadow-perspective-16x9',.32},
 {'9x19_5','9:19.5',900,1950,'meadow-perspective-9x16',.33},
 {'9x20','9:20',900,2000,'meadow-perspective-9x16',.35}})do
 local id='rocky_terrain-01-'..spec[1]
 metadata[id]={inherits=spec[5],composition_id=id,aspect_ratio=spec[2],
  reference_size={width=spec[3],height=spec[4]},horizon_y=spec[6]}
 local entry={id=id,environment='rocky_terrain',variation=1,aspect_ratio=spec[2],quality='HD',
  metadata=id,background='art/source/'..id..'.png',
  mounds={player='art/source/mound-pale-gravel-01.png',opponent='art/source/mound-pale-gravel-01.png'}}
 if spec[1]=='21x9'then
  -- Uniform authored framing brings the open floor above native contact points.
  entry.source_rect={x=188,y=160,width=1540,height=660}
  entry.night_source_rect={x=188,y=160,width=1540,height=660}
 end
 compositions[#compositions+1]=entry
end
for _,environment in ipairs({'river','ocean','pond'})do
for variation,material in ipairs({'islet-grass','islet-rock','islet-sand'})do
 local id=environment..'-0'..variation..'-16x9'
 metadata[id]={inherits='meadow-perspective-16x9',composition_id=id,horizon_y=environment=='river'and .28 or .25,
  opponent={mound_origin={.5,.62}}}
 compositions[#compositions+1]={id=id,environment=environment,variation=variation,aspect_ratio='16:9',quality='HD',
  metadata=id,background='art/source/'..id..'.png',
  mounds={player='art/source/mound-'..material..'-01.png',opponent='art/source/mound-'..material..'-01.png'}}
end
end
-- Outdoor periods are distinct original illustrations, not post-process
-- lighting variants. Underground cave art has no outdoor day/night cycle.
for _,entry in ipairs(compositions)do
 local materials={grassland='grass',forest='forest',beach='sand',mountain='highland',rocky_terrain='gravel',river='islet-grass',ocean='islet-grass',pond='islet-grass'}
 if materials[entry.environment]then
  local material=materials[entry.environment]
  if entry.id=='forest-03-16x9'then material='autumn'end
  if entry.id=='beach-03-16x9'then material='gray-sand'end
  if entry.id=='mountain-03-16x9'then material='terracotta'end
  if entry.environment=='river'or entry.environment=='ocean'or entry.environment=='pond'then material=({'islet-grass','islet-rock','islet-sand'})[entry.variation]end
  if entry.environment=='rocky_terrain'and entry.variation~=2 then
   material='pale-gravel'
   entry.mounds={player='art/source/mound-pale-gravel-01.png',opponent='art/source/mound-pale-gravel-01.png'}
  end
  entry.backgrounds={day=entry.background,night=entry.background:gsub('%.png$','-night.png')}
  if entry.id=='forest-01-32x9'then entry.night_source_rect={x=0,y=80,width=2087,height=586.96875}end
  entry.night_mounds={player='art/source/mound-'..material..'-01-night.png',opponent='art/source/mound-'..material..'-01-night.png'}
 end
end
return {metadata=metadata,compositions=compositions}
