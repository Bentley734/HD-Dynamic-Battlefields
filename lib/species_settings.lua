-- Additive, per-game Pokemon corrections; never edits mound or authored data.
return function(mod,open,group)
 local Version=require('src.core.GameVersion')
 local nativeWidth,nativeHeight=160,144
 if mod.exports.nativeSize then nativeWidth,nativeHeight=mod.exports.nativeSize()end
 local selected={}
 local status=''
 local function key(side)
  local species=selected[side]
  return species and Version.get()..':'..species
 end
 local function correction(side)
  local data=mod.exports.getAdjustments();local id=key(side)
  return id and data.species and data.species[id]and data.species[id][side]or{}
 end
 local function axis(side,field,label,units)
  return{id='hd_species_'..side..field,label=label,value=function()
   return tostring(math.floor((correction(side)[field]or 0)*units+.5))..' PX'
  end,step=function(game,dir)
   local id=key(side);if not id then status='CHOOSE SPECIES';return false end
   local data=mod.exports.getAdjustments();data.species=data.species or{}
   data.species[id]=data.species[id]or{};data.species[id][side]=data.species[id][side]or{}
   local pixels=math.floor((data.species[id][side][field]or 0)*units+.5)+(dir or 1)
   data.species[id][side][field]=math.max(-units/2,math.min(units/2,pixels))/units
   local ok,err=mod.exports.applyAdjustments(data);status=ok and'SAVED'or tostring(err);return false
  end}
 end
 local pages={}
 for _,side in ipairs({'player','opponent'})do
  local rows={{id='hd_species_choose_'..side,label='POKEMON',value=function()return selected[side]or'CHOOSE SPECIES'end,
   activate=function(game)
    local choices={}
    for _,record in ipairs(mod.exports.getSpeciesChoices())do local species=record.id
     choices[#choices+1]={id='hd_species_pick_'..side..species,label=record.name,
      activate=function(ctx)selected[side]=species;ctx.stack:pop()end}
    end
    open(game,choices)
   end},axis(side,'pokemon_x','HORIZONTAL',nativeWidth),axis(side,'pokemon_y','VERTICAL',nativeHeight),
   {id='hd_species_status_'..side,label='STATUS',value=function()return status end},
   {id='hd_species_reset_'..side,label='RESET THIS POKEMON',activate=function()
    local id=key(side);if not id then status='CHOOSE SPECIES';return end
    local data=mod.exports.getAdjustments()
    if data.species and data.species[id]then
     data.species[id][side]=nil;if not next(data.species[id])then data.species[id]=nil end
    end
    local ok,err=mod.exports.applyAdjustments(data);status=ok and'RESET'or tostring(err)
   end}}
  local row=group('species_'..side,side=='player'and'PLAYER'or'OPPONENT',rows)
  local activate=row.activate
  row.activate=function(game)
   if not selected[side]then selected[side]=mod.exports.diagnostics()[side=='player'and'playerSpecies'or'opponentSpecies']end
   return activate(game)
  end
  pages[#pages+1]=row
 end
 return group('species','SPECIES POSITIONS',pages)
end
