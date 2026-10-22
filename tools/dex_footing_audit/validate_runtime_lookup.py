"""Compare the HD-only helper with the independent production source census."""
from pathlib import Path
import collections,json,os,sys,time
from audit_paths import OUT as HERE, REPO as ROOT, BW
from lupa.luajit21 import LuaRuntime
lua=LuaRuntime(unpack_returned_tuples=True)
load=lambda p:lua.execute(p.read_text(encoding='utf-8'))
catalog=load(ROOT/'metadata/dex_source_catalog.lua')
kim=load(ROOT/'metadata/dex_kim_sources.lua')
gaps=load(ROOT/'metadata/dex_pack_gaps.lua')
data=json.loads((HERE/'resolution-luajit.json').read_text())
bw=json.loads((BW/'inventory.json').read_text())
lua.globals().cat=catalog;lua.globals().kimcat=kim;lua.globals().gaps=gaps
lua.globals().bwkeys=lua.table_from({k:True for k in bw})
lua.globals().profile_root=ROOT.as_posix()
runner=lua.execute('''
local D=assert(loadfile(profile_root..'/lib/dex_mound_profile.lua'))()
local options={sprite_anchor=1,sprite_size=1,player_sprite_view=0,sprite_female=true,sprite_shiny=true}
local peers={['1025dex']={version='1.5.2',exports={}},
 ['1025dex-bw-sprites']={version='1.0.0',exports={sprite=function(folder,stem)return bwkeys[folder..'/'..stem]and{}or nil end,decodeSprite=function()end}},
 kim1025={version=kimcat.kimVersion,exports={getDexSpriteSheet=function(species,side,shiny,dex)
  local request=kimcat.requests[tostring(species)..'|'..tostring(dex or'')]
  local folder=side..(shiny and'_shiny'or'')
  local source=request and request.sources[folder]
  local record=source and kimcat.records[source]
  if record then return{},{width=record.width,height=record.height,count=record.frames}end
 end}}}
local mod={find=function(_,id)return peers[id]end,game={mods={modOptions={['1025dex']=options}}}}
local helper=D.new(mod,function(path)
 if path=='metadata/dex_source_catalog.lua'then return cat
 elseif path=='metadata/dex_pack_gaps.lua'then return gaps
 elseif path=='metadata/dex_kim_sources.lua'then return kimcat end
end)
return function(species,stem,style,back,shiny,female,rawSpecies,rawDex)
 options.enemy_sprite_style,options.player_sprite_style=style,style
 if rawSpecies then peers.kim1025.exports.getDexSpriteSheet(rawSpecies,back and'back'or'front',shiny,rawDex)end
 return helper:bake(species,back,{gender=female and'female'or'male',shiny=shiny},1,{shiny=shiny})
end
''')
started=time.time();failures=[];counts=collections.Counter();pending=[]
for plan in data['plans']:
    raw=None;dex=None
    if plan['style']==5:
        raw_request=plan.get('kimRequest')
        if raw_request:
            raw,dex=raw_request['species'],raw_request.get('dex')
        else:
            pending.append({k:plan[k] for k in ('species','stem','folder','sourceKey')});continue
    result=runner(plan['species'],plan['stem'],plan['style'],plan['side']=='back',plan['palette']=='shiny',plan['gender']=='female',raw,dex)
    if isinstance(result,tuple):bake,reason=result
    else:bake,reason=result,None
    if bake is None or bake['source']!=plan['sourceKey'] or bake['stem']!=plan['stem'] or bake['union']!=plan['unionMode']:
        failures.append({'plan':{k:plan[k] for k in ('species','style','side','palette','gender','sourceKey','stem','unionMode')},
                         'actual':dict(bake.items()) if bake is not None else reason})
    counts[plan['pack']]+=1
report={'sourceVersion':'1.5.2','checked':sum(counts.values()),'counts':dict(counts),'failures':failures,'missingObservedRequestMappings':pending,
 'scope':'Every production LuaJIT source census plan, including gender/palette/fallback/first-frame selection. Replay the exact raw KIM public species/dex/side/palette requests captured by the production source selector and validate returned record geometry against the independent physical-source catalog. Native renders are separate evidence.',
 'elapsedSeconds':round(time.time()-started,3)}
(HERE/'runtime-lookup-validation.json').write_text(json.dumps(report,separators=(',',':')))
print(json.dumps({k:v for k,v in report.items() if k not in ('failures','missingObservedRequestMappings')},indent=2))
print('Failures:',len(failures),'Unmapped KIM requests:',len(pending))
for failure in failures[:4]:print(failure)
assert not failures and not pending
