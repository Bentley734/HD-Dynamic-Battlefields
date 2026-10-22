"""Read-only source identity census using 1025Dex 1.5.2 production resolvers."""
import collections
import hashlib
import json
import os
from pathlib import Path
import sys

from audit_paths import OUT as HERE, WORKSPACE, DEX as ROOT, SAVE, KIM, BW, require_dex_version
require_dex_version()
WORK = WORKSPACE / '.work'
if len(sys.argv)>1 and sys.argv[1]=='luajit':
    from lupa.luajit21 import LuaRuntime
elif len(sys.argv)>1 and sys.argv[1]=='lua53':
    from lupa.lua53 import LuaRuntime
else:
    from lupa import LuaRuntime

lua = LuaRuntime(unpack_returned_tuples=True)
if len(sys.argv)>1 and sys.argv[1]=='luajit':
    lua.execute("local native=load;load=function(s,n,m,e)if type(s)=='string'then local f,err=loadstring(s,n);if f and e then setfenv(f,e)end;return f,err end;return native(s,n)end")
def load(path):
    return lua.execute(path.read_text(encoding='utf-8'))
def plain(value):
    if hasattr(value, 'items'):
        keys = list(value.keys())
        if keys and all(isinstance(k, int) for k in keys) and set(keys) == set(range(1, len(keys)+1)):
            return [plain(value[k]) for k in range(1, len(keys)+1)]
        return {str(k):plain(v) for k,v in value.items()}
    return value
def section(text, start, end):
    a=text.index(start); return text[a:text.index(end,a+len(start))]

source=(ROOT/'sprites/main.lua').read_text(encoding='utf-8')
data=load(ROOT/'sprites/data/dbk_data.lua')
data.ee=load(ROOT/'sprites/data/ee_data.lua')
data.static=load(ROOT/'sprites/data/static_data.lua')
data.spriteStyle=lua.eval('function()return 3 end')
catalog=load(ROOT/'compat/asset_catalog.lua')
bw_inventory=json.loads((BW/'inventory.json').read_text(encoding='utf-8'))

# Execute the unmodified KIM catalog and identity-selection prefix. Stop before
# image decoding: the source record is exactly what the public provider uses.
kim_source=(KIM/'lib/dex_sprite_provider.lua').read_text(encoding='utf-8')
kim_source=kim_source[:kim_source.index('  local bytes=')]+'  return record\n end\nend\n'
kim_mod=lua.table_from({'exports':lua.table_from({})})
kim_mod.read=lambda _,p:(KIM/p).read_text(encoding='utf-8') if (KIM/p).is_file() else None
kim_mod.exports.normalizeSpeciesKey=load(KIM/'lib/species_key.lua')
lua.execute(kim_source)(kim_mod)
kim_get=kim_mod.exports.getDexSpriteSheet
kim_records={}
kim_missing=set()
last_kim_request=None
last_kim_status=None
def kim_record(species,side,shiny,dex):
    global last_kim_request
    last_kim_request={'species':species,'side':side,'shiny':shiny,'dex':dex,
        'image':None}
    try:
        record=kim_get(species,side,shiny,dex)
    except Exception as error:
        last_kim_request['error']=str(error)
        raise
    last_kim_request['image']=record.image if record is not None else None
    if record is None:return None
    key=record.image
    paths=[SAVE/'mod_cache/kim1025/kim_assets/files'/key,
           SAVE/'mod_cache/kim1025/kim1025_assets/files'/key,KIM/key]
    real=next((p for p in paths if p.is_file()),None)
    if real is None:
        kim_missing.add(key);return None
    value=plain(record);value['path']=str(real)
    kim_records[key]=value
    # The production sheet selector only needs truthy decoded data and the
    # provider's returned width/height/count/timing metadata.
    return 'decoded-source',lua.table_from({'width':record.width,'height':record.height,
        'count':record.frames,'sourceImage':key})

kim_peer=lua.table_from({'getDexSpriteSheet':kim_record})
def bw_sprite(folder,stem):
    return lua.table_from(bw_inventory[folder+'/'+stem]) if folder+'/'+stem in bw_inventory else None
bw_peer=lua.table_from({'sprite':bw_sprite})
data.kimPeer=lambda:kim_peer
data.bwPeer=lambda:bw_peer
mod=lua.table_from({})
mod.read=lambda _,p:(ROOT/'sprites'/p).read_text(encoding='utf-8')
mod.rootRead=lambda _,p:(ROOT/p).read_text(encoding='utf-8')
mod.info=lambda _,p:lua.table_from({'type':'file'}) if catalog['assets/sprites/'+p] else None
env=lua.table_from({'DATA':data,'mod':mod,'frameCounter':0,'RECHECK_FRAMES':900,
    'localFolder':lua.eval("function(back,shiny)return(back and'back'or'front')..(shiny and'_shiny'or'')end"),
    'debugOn':lua.eval('function()return false end'),
    'diag':lua.table_from({'stats':lua.table_from({'missing':0})}),
    'diagPush':lua.eval('function()end')})
lua.eval('function(e)setmetatable(e,{__index=_G})end')(env)
resolver=section(source,'  local function stripLastWord','  -- Resolve a live mon')
selector=section(source,'  local function sheetStart','  local function evictIfNeeded')
def kim_status(ok,data,record):
    global last_kim_status
    last_kim_status={'ok':ok,'error':str(data) if not ok else None}
env.auditKimStatus=kim_status
selector=selector.replace('        if ok and data and record then','        auditKimStatus(ok,data,record)\n        if ok and data and record then')
api=lua.eval('function(s,e)return assert(load(s,"production resolver","t",e))()end')(
    resolver+selector+'return {resolve=resolveStem,female=femaleStem,start=sheetStart}',env)

national=load(ROOT/'dex/data/species/generated/national.lua')
species=sorted(set(national.patch.keys())|set(national.register.keys()))
rows=[];fallbacks=collections.Counter();missing=[];resolved=collections.Counter()
for species_id in species:
    for style in range(6):
        base=api.resolve(species_id,style)
        for female in (False,True):
            stem=api.female(base,style) if base and female else base
            for side in ('front','back'):
                for shiny in (False,True):
                    row={'species':species_id,'gender':'female' if female else 'default',
                         'style':style,'side':side,'palette':'shiny' if shiny else 'normal',
                         'stem':stem,'unionMode':'first' if style==4 else 'all'}
                    if stem:
                        last_kim_request=None
                        last_kim_status=None
                        sheet=lua.table_from({'stem':stem,'back':side=='back','shiny':shiny,'style':style,'status':'new'})
                        api.start(sheet)
                        if style==5:
                            row['kimRequest']=last_kim_request
                            row['kimCallStatus']=last_kim_status
                        folder=side+('_shiny' if shiny else '')
                        if sheet.kimRecord:
                            pack='kim';key='kim/'+sheet.kimRecord.sourceImage
                            row['record']=kim_records[sheet.kimRecord.sourceImage]
                        elif sheet.bwPeer:
                            pack='bw';key=f'bw/{folder}/{stem}'
                        elif sheet.static:
                            pack='static';key=f'static/{folder}/{sheet.sourceStem}'
                        elif sheet.ee:
                            pack='ee';key=f'ee/{folder}/{stem}'
                        elif sheet.status=='local':
                            pack='dbk';key=f'dbk/{folder}/{stem}'
                        else:
                            pack='missing';key=None;missing.append(row.copy())
                        row.update(pack=pack,folder=folder,sourceStem=sheet.sourceStem or stem,sourceKey=key,
                                   outputFirstOnly=style in (1,4))
                        resolved[pack]+=1
                        desired={0:'dbk',1:'static',2:'bw',3:'ee',4:'ee',5:'kim'}[style]
                        if pack!=desired:fallbacks[f'{style}:{pack}']+=1
                    else:
                        row.update(pack='unresolved',sourceKey=None);missing.append(row.copy())
                    rows.append(row)

report={'version':'1.5.2','sourceSha256':hashlib.sha256(source.encode()).hexdigest(),
    'speciesCount':len(species),'planCount':len(rows),'resolvedPacks':dict(resolved),
    'fallbacks':dict(fallbacks),'missing':missing,'kimMissingFiles':sorted(kim_missing),'plans':rows}
HERE.mkdir(parents=True,exist_ok=True)
suffix='-'+sys.argv[1] if len(sys.argv)>1 else ''
(HERE/('resolution'+suffix+'.json')).write_text(json.dumps(report,separators=(',',':')),encoding='utf-8')
(HERE/'species_ids.json').write_text(json.dumps(species),encoding='utf-8')
(HERE/'kim_records.json').write_text(json.dumps(kim_records,separators=(',',':')),encoding='utf-8')
print(json.dumps({k:v for k,v in report.items() if k!='plans'},indent=2))
print('KIM distinct selected image records:',len(kim_records))
