local C=assert(loadfile(root..'/lib/species_catalog.lua'))()
local records={SQUIRTLE={name='Squirtle',index=7},PECHARUNT={name='Pecharunt',index=1089,dex=1025},
 RAICHU_ALOLA={name='Raichu Alola',index=1090,dex=26},['other:SPECIES']={name='Other',index=2000}}
local reg={each=function()return pairs(records)end}
local rows,slots=C.collect(reg,{SQUIRTLE={name='Squirtle',index=7},ALIAS={name='Alias',index=1090},generation=3,growthRates={}})
assert(#rows==4 and slots[1089]=='PECHARUNT'and slots[1090]=='RAICHU_ALOLA'and slots[2000]=='other:SPECIES')
records.NEW_SPECIES={name='New Species',index=2200}
local live=C.new({content={pokemon=reg}});live:refresh({data={pokemon={}}})
assert(#live.rows==5 and live:identity(2200)=='NEW_SPECIES'and live:identity('SQUIRTLE')=='SQUIRTLE')
records.RAICHU_ALOLA.name='Raichu';records.RAICHU={name='Raichu',index=26}
rows=C.collect(reg,{})
local labels={};for _,row in ipairs(rows)do labels[row.id]=row.name end
assert(labels.RAICHU=='RAICHU'and labels.RAICHU_ALOLA=='RAICHU ALOLA')
local P=assert(loadfile(root..'/lib/perspective.lua'))()
assert(P.validateAdjustments({species={['firered:other:SPECIES']={player={pokemon_x=1/160}}}}))
print('PASS effective species registry: native/mod species, forms, sparse slots, late registrations, aliases and namespaced IDs')
