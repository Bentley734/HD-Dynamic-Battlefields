"""Build independent request/source metadata for observing public KIM calls."""
import collections
import json
import os
from pathlib import Path
import sys
from audit_paths import OUT as HERE, DEX as ROOT, SAVE, KIM, require_dex_version
require_dex_version()
from lupa.lua53 import LuaRuntime

lua=LuaRuntime(unpack_returned_tuples=True)
def load(p):return lua.execute(p.read_text(encoding='utf-8'))
def plain(t):
    if not hasattr(t,'items'):return t
    return {str(k):plain(v) for k,v in t.items()}
data=load(ROOT/'sprites/data/dbk_data.lua')
roster={row.name:row.id for _,row in load(ROOT/'encounters/roster.lua').items()}

provider=(KIM/'lib/dex_sprite_provider.lua').read_text(encoding='utf-8')
provider=provider[:provider.index('  local bytes=')]+'  return record\n end\n mod.exports.__auditCatalog=catalog()\nend\n'
mod=lua.table_from({'exports':lua.table_from({})})
mod.read=lambda _,p:(KIM/p).read_text(encoding='utf-8') if (KIM/p).is_file() else None
mod.exports.normalizeSpeciesKey=load(KIM/'lib/species_key.lua')
lua.execute(provider)(mod)
get=mod.exports.getDexSpriteSheet

all_records={}
def walk(value):
    if not hasattr(value,'items'):return
    if value.image:
        record=plain(value)
        for base in [SAVE/'mod_cache/kim1025/kim_assets/files',SAVE/'mod_cache/kim1025/kim1025_assets/files',KIM]:
            if (base/value.image).is_file():record['path']=str(base/value.image);break
        all_records[value.image]=record
    else:
        for _,child in value.items():walk(child)
walk(mod.exports.__auditCatalog)

requests={};aliases={k:v for k,v in data.species.items()};stem_requests=collections.defaultdict(set)
for alias,stem in aliases.items():
    stem_requests[stem].add(alias)
for stem in data.stems.keys():
    letter=None
    if stem.startswith('UNOWN_'):
        try:letter=int(stem.split('_',1)[1])
        except ValueError:pass
    if letter is not None:
        stem_requests[stem]={f'UNOWN_{chr(65+letter)}' if letter<=25 else 'UNOWN_EXCLAMATION' if letter==26 else 'UNOWN_QUESTION'}
    if not stem_requests[stem]:stem_requests[stem].add(stem)

for stem,names in list(stem_requests.items()):
    if data.female[stem]:
        stem_requests[stem+'_female'].update(name+'_FEMALE' for name in names)
for stem,names in sorted(stem_requests.items()):
    for species in sorted(names):
        dex=roster.get(species) or roster.get(species.removesuffix('_FEMALE').removesuffix('_female'))
        request_key=species+'|'+str(dex or '')
        entry={'species':species,'dex':dex,'stem':stem,'sources':{}}
        for side in ('front','back'):
            for shiny in (False,True):
                record=get(species,side,shiny,dex)
                if record is not None:
                    entry['sources'][side+('_shiny' if shiny else '')]=record.image
        previous=requests.get(request_key)
        if previous is not None and previous['stem']!=stem:
            raise AssertionError((request_key,previous['stem'],stem))
        requests[request_key]=entry

payload={'dexVersion':'1.5.2','kimVersion':'1.7.46','speciesToStem':aliases,
         'requests':requests,'records':all_records}
(HERE/'kim-candidate-requests.json').write_text(json.dumps(payload,separators=(',',':')),encoding='utf-8')
(HERE/'kim_records-all.json').write_text(json.dumps(all_records,separators=(',',':')),encoding='utf-8')

# Lua data contains original identifiers and independent geometry facts only;
# source art and cache paths stay in the local audit JSON, not in shipped data.
def quote(s):return json.dumps(str(s),ensure_ascii=True)
lines=['-- Generated source identity facts for read-only observation of KIM public requests.',
       '-- No peer source, sprite pixels, or runtime image mutation.',
       'return {dexVersion="1.5.2",kimVersion="1.7.46",speciesToStem={']
for key,value in sorted(aliases.items()):lines.append('['+quote(key)+']='+quote(value)+',')
lines.append('},requests={')
for key,row in sorted(requests.items()):
    sources=','.join('['+quote(k)+']='+quote(v) for k,v in sorted(row['sources'].items()))
    lines.append('['+quote(key)+']={stem='+quote(row['stem'])+',sources={'+sources+'}},')
lines.append('},records={')
for key,row in sorted(all_records.items()):
    values=','.join(k+'='+str(row[k]) for k in ['width','height','frames','columns'])
    lines.append('['+quote(key)+']={'+values+'},')
lines.append('}}')
(HERE/'kim_source_catalog.lua').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print(json.dumps({'allKimImages':len(all_records),'allKimFrames':sum(r['frames'] for r in all_records.values()),
 'missingFiles':sum('path'not in r for r in all_records.values()),'possibleRequests':len(requests),
 'requestsWithKIM':sum(bool(r['sources'])for r in requests.values()),'aliases':len(aliases)}))
