local D=assert(loadfile(root..'/lib/dex_mound_profile.lua'))()
local C=assert(loadfile(root..'/lib/mound_contact.lua'))()
local checks=0
local function eq(actual,wanted,why)checks=checks+1;assert(actual==wanted,why..': '..tostring(actual)..' ~= '..tostring(wanted))end
local folders={'front','back','front_shiny','back_shiny'}
local catalog={schema=1,peerVersion='1.5.2',species={TEST={base='TEST',ee='TEST_EE'},MISSING={base='MISSING',ee='MISSING'},ALIAS={base='ALIAS',ee='ALIAS'},UNOWN={base='UNOWN',ee='UNOWN'}},female={TEST='TEST_female'},eeFemale={TEST_EE='TEST_EE_female'},eeMissing={},staticMissing={},staticRemap={}}
local gaps={schema=1,profiles={{},{},{}},sources={}}
for i=1,18 do gaps.profiles[1][i]=i;gaps.profiles[2][i]=3;gaps.profiles[3][i]=18+i end
for _,folder in ipairs(folders)do
 catalog.eeMissing[folder]={MISSING=true};catalog.staticMissing[folder]={MISSING=true};catalog.staticRemap[folder]={ALIAS='REMAPPED'}
 for _,provider in ipairs({'dbk','ee','bw','static'})do
  for _,stem in ipairs({'TEST','TEST_EE','TEST_female','TEST_EE_female','MISSING','REMAPPED','UNOWN','UNOWN_1'})do
   gaps.sources[provider..'/'..folder..'/'..stem..'#all']=1
   gaps.sources[provider..'/'..folder..'/'..stem..'#first']=2
   if folder=='front'or folder=='front_shiny'then
    gaps.sources[provider..'/'..folder..'/'..stem..'#all@back']=3
    gaps.sources[provider..'/'..folder..'/'..stem..'#first@back']=3
   end
  end
 end
end
gaps.sources['kim/p.png#all']=1
local kimCatalog={kimVersion='1.7.46',dexVersion='1.5.2',speciesToStem={RAW='TEST'},requests={['RAW|1']={stem='TEST',sources={front='p.png'}}},records={['p.png']={width=2,height=3,frames=4}}}
local function fixture(opts,peerVersion)
 local loaded=0
 local peers={['1025dex']={version=peerVersion or'1.5.2',exports={}}}
 local mod={game={mods={modOptions={['1025dex']=opts or{}}}},find=function(_,id)return peers[id]end}
 local function load(path)
  loaded=loaded+1
  if path=='metadata/dex_source_catalog.lua'then return catalog
  elseif path=='metadata/dex_pack_gaps.lua'then return gaps
  elseif path=='metadata/dex_kim_sources.lua'then return kimCatalog end
 end
 return mod,peers,load,function()return loaded end
end
local opts={enemy_sprite_style=0,player_sprite_style=0,sprite_anchor=1,sprite_size=1}
local mod,peers,load,loads=fixture(opts)
local helper=D.new(mod,load)
eq(loads(),0,'No eager metadata load without optional KIM provider')
local b=assert(helper:bake('TEST',false,{},1))
eq(b.source,'dbk/front/TEST','DBK actual source');eq(b.contactGap,1,'Gen1 front matrix column')
eq(b.box.h,56,'Gen1 front native canvas');eq(b.dh,55,'Compact bake carries stable contact edge')
eq(assert(C.localContact(b)).y,55,'Contact resolver consumes compact runtime profile')
eq(assert(helper:bake('TEST',true,{},1)).contactGap,7,'Gen1 back matrix column')
eq(assert(helper:bake('TEST',true,{},2)).contactGap,13,'Gen2 back matrix column')
eq(assert(helper:bake('TEST',false,{},3)).contactGap,7,'Gen3 front native64 column')
opts.sprite_size=2
eq(assert(helper:bake('TEST',false,{},3,{cloud=true})).contactGap,10,'Size2/cloud exact profile column')
opts.dynamax_cloud=false
eq(assert(helper:bake('TEST',false,{},3,{cloud=true})).contactGap,9,'Disabled cloud leaves ordinary production layout')
opts.sprite_size=1;opts.dynamax_cloud=nil
opts.sprite_anchor=0
eq(assert(helper:bake('TEST',false,{},3)).contactGap,0,'FEET never confuses hover padding with PACK gap')
opts.sprite_anchor=2
eq(assert(helper:bake('TEST',false,{},3)).contactGap,0,'BOX retains canvas ground')
opts.sprite_anchor=1
gaps.sources['dbk/front/TEST#all']=nil
checks=checks+1;assert(not helper:bake('TEST',false,{},1),'Unknown source must not be confused with a zero gap')
gaps.sources['dbk/front/TEST#all']=0
eq(assert(helper:bake('TEST',false,{},1)).contactGap,0,'Explicit zero is a calibrated source')
gaps.sources['dbk/front/TEST#all']=1

local mon={gender='female',shiny=true}
b=assert(helper:bake('TEST',true,mon,1))
eq(b.source,'dbk/back_shiny/TEST_female','Gen1 actual female shiny source')
opts.sprite_shiny=false;opts.sprite_female=false
eq(assert(helper:bake('TEST',true,mon,1)).source,'dbk/back/TEST','Gen1 presentation gates match provider')
b=assert(helper:bake('TEST',true,mon,3,{shiny=true}))
eq(b.source,'dbk/back_shiny/TEST','Gen3 direct picture seam ignores female and shiny options')
opts.sprite_shiny=true;opts.sprite_female=true
eq(assert(helper:bake('TEST',false,mon,1,{shiny=false})).shiny,false,'Explicit false shiny input stays false')
opts.player_sprite_view=2
b=assert(helper:bake('TEST',true,{},3))
eq(b.folder,'front','Mirrored front sources front image in back native canvas')
eq(b.flip,true,'Mirroring preserved in contact bake');eq(b.box.h,64,'View never changes back native box')
eq(b.contactGap,25,'Player front art retains logical back PACK metrics')
opts.player_sprite_view=1
eq(assert(helper:bake('TEST',true,{},3)).contactGap,25,'Front and mirrored front share logical back alignment')
eq(assert(helper:bake('TEST',true,{},2)).contactGap,31,'Gen2 front player view uses back metrics in48px canvas')
opts.player_sprite_view=0

opts.enemy_sprite_style=3
eq(assert(helper:bake('TEST',false,mon,1)).source,'ee/front_shiny/TEST_EE_female','EE overrides then female resolver')
eq(assert(helper:bake('MISSING',false,{},1)).source,'dbk/front/MISSING','Missing EE artwork falls back to matching DBK')
opts.enemy_sprite_style=4
eq(assert(helper:bake('TEST',false,{},3)).contactGap,3,'EE static uses first-frame union')
opts.enemy_sprite_style=1
eq(assert(helper:bake('ALIAS',false,{},3)).source,'static/front/REMAPPED','Static source alias matches actual sheet')
eq(assert(helper:bake('MISSING',false,{},3)).source,'dbk/front/MISSING','Missing static source uses DBK all-frame union')
opts.enemy_sprite_style=2
eq(assert(helper:bake('TEST',false,{},3)).source,'dbk/front/TEST','Absent BW provider fallback')
peers['1025dex-bw-sprites']={version='1.0.0',exports={sprite=function(folder,stem)return stem=='TEST'and{total_ticks=5}or nil end,decodeSprite=function()end}}
eq(assert(helper:bake('TEST',false,{},3)).source,'bw/front/TEST','BW source uses actual public timing availability')
eq(assert(helper:bake('MISSING',false,{},3)).source,'dbk/front/MISSING','Absent BW species fallback')
peers['1025dex-bw-sprites'].version='2.0.0'
checks=checks+1;assert(not helper:bake('TEST',false,{},3),'Unknown BW geometry safely falls back')
opts.enemy_sprite_style=5
eq(assert(helper:bake('TEST',false,{},3)).source,'ee/front/TEST_EE','Missing KIM side style resolves EE style override')
opts.enemy_sprite_style=-1;opts.sprite_style=5
eq(assert(helper:bake('TEST',false,{},3)).source,'ee/front/TEST','Legacy KIM fallback retains base stem')

local kimCalls=0
local data,record={}, {width=2,height=3,count=4}
local original=function(species,side,isShiny,dex)
 kimCalls=kimCalls+1;eq(species,'RAW','Observer retains original species request');eq(side,'front','Observer retains original source side')
 eq(isShiny,false,'Observer retains palette');eq(dex,1,'Observer retains dex')
 return data,record,nil,'last-return'
end
local kim={version='1.7.46',exports={getDexSpriteSheet=original}}
peers.kim1025=kim
opts.enemy_sprite_style=5
checks=checks+1;assert(not helper:bake('TEST',false,{},3),'KIM waits for actual provider request')
eq(kimCalls,0,'Lookup never issues an extra KIM decode request')
local r1,r2,r3,r4=kim.exports.getDexSpriteSheet('RAW','front',false,1)
eq(r1,data,'Original image data is returned unchanged');eq(r2,record,'Original metadata returned unchanged')
eq(r3,nil,'Nil return preserved');eq(r4,'last-return','Return count preserved')
b=assert(helper:bake('TEST',false,{},3))
eq(b.source,'kim/p.png','Observed KIM request selects audited physical source')
eq(b.contactGap,7,'Observed KIM source selects exact contact matrix');eq(kimCalls,1,'Bakes never decode KIM again')
-- Replaced public provider is re-observed; nil means real matching fallback.
kim.exports.getDexSpriteSheet=function()return nil end
helper:observeKIM();kim.exports.getDexSpriteSheet('RAW','front',false,1)
eq(assert(helper:bake('TEST',false,{},3)).source,'ee/front/TEST','Actual nil KIM source uses matching EE artwork')
local sentinel={original=true}
kim.exports.getDexSpriteSheet=function()error(sentinel)end
helper:observeKIM()
local ok,err=pcall(kim.exports.getDexSpriteSheet,'RAW','front',false,1)
eq(ok,false,'Provider exception still reaches original caller');eq(err,sentinel,'Original provider error object is unchanged')
eq(assert(helper:bake('TEST',false,{},3)).source,'ee/front/TEST','Caught KIM error matches actual 1025Dex fallback')
kim.exports.getDexSpriteSheet=function()return data,{width=99,height=3,count=4}end
helper:observeKIM();kim.exports.getDexSpriteSheet('RAW','front',false,1)
checks=checks+1;assert(not helper:bake('TEST',false,{},3),'Changed KIM source geometry is not guessed')

local oldSave=package.loaded['src.core.SaveData']
package.loaded['src.core.SaveData']={loadOptions=function()return{modOptions={['1025dex']={enemy_sprite_style=4,sprite_anchor=1}}}end}
mod.game.mods.modOptions={}
peers.kim1025=nil
eq(assert(helper:bake('TEST',false,{},3)).style,4,'SaveData supplies options when loader store is absent')
package.loaded['src.core.SaveData']=oldSave
local futureMod,_,futureLoad,futureLoads=fixture({},'1.5.3')
local future=D.new(futureMod,futureLoad)
checks=checks+1;assert(not future:bake('TEST',false,{},3),'Future private bake math must not use old calibration')
eq(futureLoads(),0,'Unvalidated peer never loads metadata')
local missingMod=fixture({})
local missing=D.new(missingMod,function()error('metadata missing')end)
checks=checks+1;assert(not missing:bake('TEST',false,{},3),'Missing metadata safely retains existing mound')
checks=checks+1;assert(not helper:bake('UNKNOWN',false,{},3),'Unregistered sources safely retain existing mound')
checks=checks+1;assert(not helper:bake('TEST',false,{},3,{ready=false}),'Pending replacement keeps existing mound')
print(('PASS %d 1025Dex mound-profile assertions: exact native canvases/options, gender/palette seams, style/source fallbacks, first-frame geometry, read-only observed KIM returns and version guards'):format(checks))
