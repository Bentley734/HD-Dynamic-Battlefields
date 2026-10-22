"""Compact HD-only PACK anchor gap metadata from audited production layouts."""
import collections, json
from pathlib import Path
from audit_paths import OUT as HERE
data=json.loads((HERE/'source-geometry.json').read_text(encoding='utf-8'))
resolution=json.loads((HERE/'resolution-luajit.json').read_text(encoding='utf-8'))
keys=data['layoutKeys']; geometries=data['geometries']; source=data['sources']
profiles=[];profileids={};entries={};missing=[];rows=[]
# Native Gen1 front / Gen1back+Gen3 / Gen2back. Gen2front uses56.
selectors=[f'{box}:{size}:1:0:{cloud}' for box in ('g1front','g1back','g2back')
    for size in (1,2,3) for cloud in (0,1)]
indices=[keys.index(k) for k in selectors]
for key in sorted(source):
    record=source.get(key)
    while isinstance(record,str):record=source.get(record)
    if not record:missing.append(key);continue
    values=tuple(geometries[record['geometry'][i]][1]-sum(geometries[record['geometry'][i]][j] for j in (3,5)) for i in indices)
    if not any(values):entries[key]=0;continue
    pid=profileids.get(values)
    if pid is None:pid=len(profiles)+1;profileids[values]=pid;profiles.append(values)
    entries[key]=pid

def q(s):return json.dumps(s,ensure_ascii=True)
parts=['-- Generated only from uncomposited original body alpha + 1025Dex1.5.2 production setupFrames.',
 '-- ALL physical sources and both union modes are cataloged. Source0 is known zero; nil is unknown.',
 '-- PACK mode only. FEET/BOX target canvas ground; intentional hover stays above it.',
 '-- Profile columns: box56 sizes1/2/3 thenbox64 thenbox48; each size cloud-off,cloud-on.',
 '-- @back means front artwork requested for the logical player/back slot.',
 'local sources={}', 'local function add(t)for k,v in pairs(t)do sources[k]=v end end',
 'local profiles={']
for profile in profiles:parts.append(' {'+','.join(map(str,profile))+'},')
parts.append('}')
items=list(entries.items())
for start in range(0,len(items),1000):
    # LuaJIT limits constants per function. Keep independent literal batches
    # below that ceiling even when allphysical and logical-back variants grow.
    parts.append('do local function batch()return {')
    parts.extend(f' [{q(key)}]={value},'for key,value in items[start:start+1000])
    parts.append('}end add(batch())end')
parts.extend(['return {schema=1,profiles=profiles,sources=sources}',''])
(HERE/'runtime-pack-gaps.lua').write_text('\n'.join(parts),encoding='utf-8')
stats=collections.Counter();floatplans=0;maxgap=0
for plan in resolution['plans']:
    key=plan['sourceKey']+'#'+plan['unionMode'];rec=source.get(key)
    while isinstance(rec,str):rec=source.get(rec)
    if not rec:continue
    stats[plan['pack']]+=1
    floatplans+=bool(data['floaterStems'].get(plan['stem']))
    if entries.get(key):maxgap=max(maxgap,max(profiles[entries[key]-1]))
coverage=dict(plans=len(resolution['plans']),registeredSpecies=resolution['speciesCount'],
    missingGeometry=missing,plansByPack=dict(stats),floaterPlans=floatplans,
    compactKnownSources=len(entries),compactZeroGapSources=sum(v==0 for v in entries.values()),
    compactNonzeroPackSources=sum(v!=0 for v in entries.values()),compactUniqueGapProfiles=len(profiles),
    maximumPackGapPixels=maxgap,profileKeys=selectors,
    physicalSources=len({p['sourceKey'] for p in resolution['plans']}),
    sourceUnionProfiles=len({p['sourceKey']+'#'+p['unionMode'] for p in resolution['plans']}),
    genotype='Production resolution under LuaJIT2.1, matching LÖVE desktop. Pure-art source geometry shared by allthree player views.',
    excludes='Icons, bakedcomposite shadow/cloud/tera. Cloud-on size reservation is audited without treating cloud pixels as body feet.')
(HERE/'coverage.json').write_text(json.dumps(coverage,separators=(',',':')),encoding='utf-8')
print(json.dumps(coverage,indent=2))
