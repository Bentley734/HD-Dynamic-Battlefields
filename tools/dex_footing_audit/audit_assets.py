"""Read-only original sprite alpha and production layout audit.

All output lives in the configured external audit directory. No source assets or mod code are changed.
Alpha bounds are contact proxies, never a claim to recognize anatomical feet.
"""
from __future__ import annotations
import argparse, collections, concurrent.futures, hashlib, json, math, os
from pathlib import Path
import sys, time

from audit_paths import WORKSPACE as ROOT, OUT, DEX, ART, SAVE, BW, KIM, KIM_CACHE, require_dex_version
import numpy as np
from PIL import Image
from lupa import LuaRuntime, lua_type

lua = LuaRuntime(unpack_returned_tuples=True)

def py(value):
    if lua_type(value) != 'table': return value
    keys = list(value.keys())
    if keys and set(keys) == set(range(1,len(keys)+1)):
        return [py(value[i]) for i in range(1,len(keys)+1)]
    return {str(k):py(v) for k,v in value.items()}

def readlua(path):
    return py(lua.execute(path.read_text(encoding='utf-8-sig')))

def writejson(name, value):
    (OUT/name).write_text(json.dumps(value, ensure_ascii=False, separators=(',',':')), encoding='utf-8')

def catalog():
    rows = []
    for pack, base in [('dbk',ART),('ee',ART/'ee'),('static',ART/'static'),('bw',BW/'assets')]:
        for folder in ('front','back','front_shiny','back_shiny'):
            if not (base/folder).is_dir(): continue
            for path in sorted((base/folder).glob('*.png')):
                rows.append(dict(sourceKey=f'{pack}/{folder}/{path.stem}', pack=pack, folder=folder,
                    stem=path.stem,path=str(path)))
    kimrecords = {}
    def walk(node):
        if isinstance(node,dict):
            if node.get('image') and all(node.get(k) for k in ('width','height','columns','frames')):
                kimrecords[node['image']] = node
            else:
                for child in node.values(): walk(child)
        elif isinstance(node,list):
            for child in node: walk(child)
    for filename in ('hd_pokemon_sprites.lua','hd_pokemon_national.lua','hd_unown_forms.lua','hd_deoxys_forms.lua'):
        path = KIM/'data'/filename
        if path.is_file(): walk(readlua(path))
    for rel, record in sorted(kimrecords.items()):
        path = KIM/rel
        if not path.is_file(): path=KIM_CACHE/rel
        # Preserve missing catalog entries: a style can fall back instead of using this record.
        folder = ('back' if '/back/' in rel else 'front') + ('_shiny' if '/shiny/' in rel else '')
        rows.append(dict(sourceKey='kim/'+rel,pack='kim',folder=folder,stem=Path(rel).stem,
            path=str(path),record={k:record[k] for k in ('width','height','columns','frames')}))
    return rows

def runs(xs):
    if not len(xs): return []
    parts=np.split(xs,np.flatnonzero(np.diff(xs)>1)+1)
    return [[int(p[0]),int(p[-1])] for p in parts]

def analyze(row):
    out=dict(row)
    path=Path(row['path'])
    if not path.is_file(): return dict(out,status='missing')
    try:
        with Image.open(path) as im:
            W,H=im.size
            alpha=np.asarray(im.convert('RGBA').getchannel('A'))
        if row['pack']=='kim':
            rec=row['record'];fw,fh,count,columns=(rec[k] for k in ('width','height','frames','columns'))
            if W<min(count,columns)*fw or H<math.ceil(count/columns)*fh:
                return dict(out,status='invalid_kim_dimensions',width=W,height=H)
            frames=[alpha[(f//columns)*fh:(f//columns+1)*fh,(f%columns)*fw:(f%columns+1)*fw]>0 for f in range(count)]
        else:
            count=max(1,math.floor((W+H/2)/H));fw=W//count;fh=H
            if row['pack']=='static': count=1;fw=W
            frames=[alpha[:fh,f*fw:(f+1)*fw]>0 for f in range(count)]
        boxes=[];bottoms=[];contacts=[];unions=np.zeros((fh,fw),dtype=bool)
        for mask in frames:
            xs=np.flatnonzero(mask.any(axis=0));ys=np.flatnonzero(mask.any(axis=1))
            if not len(xs): boxes.append(None);bottoms.append(None);contacts.append([]);continue
            y=int(ys[-1]);boxes.append([int(xs[0]),int(ys[0]),int(xs[-1]),y]);bottoms.append(y)
            contacts.append(runs(np.flatnonzero(mask[y])))
            unions |= mask
        tail_width=0;tail_opaque=0
        if row['pack']!='kim' and W>fw*count:
            # Production scanChunk reads all W columns even when fw=floor(W/count).
            # Its last partial strip uses x modulo fw; include it in the union
            # although buildOneFrame emits only the declared complete frames.
            tail_width=W-fw*count;tail=alpha[:,fw*count:]>0
            tail_opaque=int(np.count_nonzero(tail));unions[:,:tail_width] |= tail
        def bounds(mask):
            xs=np.flatnonzero(mask.any(axis=0));ys=np.flatnonzero(mask.any(axis=1))
            if not len(xs): return None
            return [int(xs[0]),int(ys[0]),int(xs[-1]),int(ys[-1])]
        union=bounds(unions)
        active=[b for b in bottoms if b is not None]
        out.update(status='ok',width=W,height=H,frameW=fw,frameH=fh,frames=count,
            union=union,first=boxes[0],frameBounds=boxes,bottomRuns=contacts,
            alphaBottomRange=[min(active),max(active)] if active else None,
            unionBottomRuns=runs(np.flatnonzero(unions[union[3]])) if union else [],
            emptyFrames=len(frames)-len(active),bytes=path.stat().st_size)
        if tail_width:out.update(scanTailWidth=tail_width,scanTailOpaquePixels=tail_opaque)
        return out
    except Exception as exc:
        return dict(out,status='error',error=f'{type(exc).__name__}: {exc}')

def production_layout():
    source=(DEX/'sprites/main.lua').read_text(encoding='utf-8-sig')
    start=source.index('  local function setupFrames(')
    end=source.index("  -- The crystal film's per-pixel colour",start)
    setup=source[start:end]
    flstart=source.index('  local function floatLift(')
    flend=source.index('  local function fpsValue(',flstart)
    env=lua.table_from(dict(GEN=3,FRONT_SCALE=2,BACK_SCALE=3,ANCHOR_FEET=0,ANCHOR_PACK=1,
        GEN3_SPRITE_LIFT=0,FLOAT_LIFT=.05,FLOAT_LIFT_MIN=.05,
        CLOUD_BAND=.26,CLOUD_MIN_H=5,CLOUD_MASS_BOT=.585,CLOUD_OVERLAP=2,
        METRICS=lua.table(),FLOATERS=lua.table(),audit_mode=1,audit_anchor=0,audit_float=False))
    lua.eval('function(e) setmetatable(e,{__index=_G}) end')(env)
    maker=lua.eval('function(source,env) return assert(load(source,"production-layout","t",env))() end')
    api=maker('local function round(n)return math.floor(n+.5)end\n'
        'local function spriteSizeMode()return audit_mode end\n'
        'local function spriteAnchor()return audit_anchor end\n'
        'local function floatOn()return audit_float end\n'
        +source[source.index('  local function cloudSink('):source.index('  -- BIG is the default divisor')]
        +source[flstart:flend]+setup+'\nreturn {setup=setupFrames,floatLift=floatLift}',env)
    return api,env

def main():
    require_dex_version()
    parser=argparse.ArgumentParser();parser.add_argument('--workers',type=int,default=6)
    parser.add_argument('--limit',type=int,default=0);parser.add_argument('--resume',action='store_true')
    args=parser.parse_args();OUT.mkdir(exist_ok=True)
    started=time.time();rows=catalog();writejson('asset-catalog.json',rows)
    if args.limit:rows=rows[:args.limit]
    cached={}
    alpha_path=OUT/'alpha-inventory.jsonl'
    if args.resume and alpha_path.exists():
        for line in alpha_path.read_text(encoding='utf-8').splitlines():
            try:
                r=json.loads(line)
                if r.get('pack')!='kim' and r.get('width')!=r.get('frameW',0)*r.get('frames',0) and 'scanTailWidth'not in r:continue
                cached[r['sourceKey']]=r
            except Exception: pass
    done=[]
    with alpha_path.open('w',encoding='utf-8') as handle:
        with concurrent.futures.ThreadPoolExecutor(max_workers=args.workers) as pool:
            work=pool.map(lambda r:cached.get(r['sourceKey']) or analyze(r), rows)
            for i,r in enumerate(work,1):
                done.append(r);handle.write(json.dumps(r,separators=(',',':'))+'\n')
                if i%1000==0:handle.flush();print(f'alpha {i}/{len(rows)} in {time.time()-started:.1f}s',flush=True)
    dbkmetrics=readlua(DEX/'sprites/data/dbk_metrics.lua')
    staticmetrics=readlua(DEX/'sprites/data/static_metrics.lua')
    floaters=readlua(DEX/'sprites/data/dbk_float.lua')
    api,env=production_layout();env.METRICS=lua.table_from({k:lua.table_from(v) for k,v in dbkmetrics.items()})
    env.FLOATERS=lua.table_from(floaters)
    # Fixed engine boxes. Gen2 front equals Gen1 front; Gen3 both sides64.
    boxes=[('g1front',1,56,56),('g1back',1,64,64),('g2back',2,48,48),('g3',3,64,64)]
    layoutkeys=[f'{name}:{size}:{anchor}:{int(hover)}:{int(cloud)}' for name,_,_,_ in boxes
        for size in (1,2,3) for anchor in (0,1,2) for hover in (False,True) for cloud in (False,True)]
    geoms=[];geom_ids={};variants={};counts=collections.Counter();errors=[]
    for i,row in enumerate(done,1):
        counts[f'{row["pack"]}:{row["folder"]}:{row["status"]}']+=1
        if row['status']!='ok':errors.append({k:row[k] for k in ('sourceKey','status','error') if k in row});continue
        if not row['union']:errors.append(dict(sourceKey=row['sourceKey'],status='all_transparent'));continue
        # A physical KIM image may be selected for more than one resolved stem.
        # The matrix models both hypothetical grounded and flagged-floater cases;
        # callers choose hover only if the production resolved-stem floater flag is true.
        env.FLOATERS[row['stem']]=True
        for union_mode in ('all','first'):
            if union_mode=='first' and (row['frames']==1 or row['first']==row['union']):
                variants[row['sourceKey']+'#first']=row['sourceKey']+'#all';continue
            x0,y0,x1,y1=row['union' if union_mode=='all' else 'first']
            base=dict(W=row['frameW']*row['frames'],H=row['frameH'],fw=row['frameW'],
                x0=x0,y0=y0,x1=x1,y1=y1,back=row['folder'].startswith('back'),stem=row['stem'],
                density=row['frameH']/96 if row['pack']=='static' else 1,
                static=row['pack']=='static',native=row['pack'] in ('bw','kim'),ee=row['pack']=='ee',
                metrics=lua.table_from(staticmetrics.get(row['stem'],{})))
            matrix=[]
            for _,generation,w,h in boxes:
                env.GEN=generation
                for size in (1,2,3):
                    env.audit_mode=size
                    for anchor in (0,1,2):
                        env.audit_anchor=anchor
                        for hover in (False,True):
                            env.audit_float=hover
                            for cloud in (False,True):
                                b=lua.table_from(base);b.box=lua.table_from(dict(w=w,h=h));b.cloud=cloud
                                if not api.setup(b):raise ValueError('production rejected nonempty source')
                                lift=api.floatLift(row['stem'],y1-y0+1)
                                v=(w,h,b.ox,b.oy,b.dw,b.dh,round(b.scale,10),lift)
                                gid=geom_ids.get(v)
                                if gid is None:gid=len(geoms);geom_ids[v]=gid;geoms.append(v)
                                matrix.append(gid)
            variants[row['sourceKey']+'#'+union_mode]=dict(geometry=matrix,union=[x0,y0,x1,y1],
                sourceKey=row['sourceKey'],unionMode=union_mode,pack=row['pack'],folder=row['folder'],
                stem=row['stem'],density=base['density'],floater=bool(floaters.get(row['stem'])),
                metrics=staticmetrics.get(row['stem']) if base['static'] else dbkmetrics.get(row['stem']))
        if i%2000==0: print(f'layout {i}/{len(done)} in {time.time()-started:.1f}s',flush=True)
    # A front image requested for the player's front/mirrored-front view still
    # carries sheet.back=true. PACK consequently uses bx/by and BACK_SCALE,
    # independent of the physical source folder. Audit that logical side too.
    for row in done:
        if row['status']!='ok' or not row['union'] or not row['folder'].startswith('front'):continue
        for union_mode in ('all','first'):
            variant_key=row['sourceKey']+'#'+union_mode+'@back'
            if union_mode=='first' and(row['frames']==1 or row['first']==row['union']):
                variants[variant_key]=row['sourceKey']+'#all@back';continue
            x0,y0,x1,y1=row['union'if union_mode=='all'else'first']
            base=dict(W=row['frameW']*row['frames'],H=row['frameH'],fw=row['frameW'],
                x0=x0,y0=y0,x1=x1,y1=y1,back=True,stem=row['stem'],
                density=row['frameH']/96 if row['pack']=='static'else 1,
                static=row['pack']=='static',native=row['pack']in('bw','kim'),ee=row['pack']=='ee',
                metrics=lua.table_from(staticmetrics.get(row['stem'],{})))
            matrix=[]
            for _,generation,w,h in boxes:
                env.GEN=generation
                for size in(1,2,3):
                    env.audit_mode=size
                    for anchor in(0,1,2):
                        env.audit_anchor=anchor
                        for hover in(False,True):
                            env.audit_float=hover
                            for cloud in(False,True):
                                b=lua.table_from(base);b.box=lua.table_from(dict(w=w,h=h));b.cloud=cloud
                                assert api.setup(b)
                                lift=api.floatLift(row['stem'],y1-y0+1)
                                v=(w,h,b.ox,b.oy,b.dw,b.dh,round(b.scale,10),lift)
                                gid=geom_ids.get(v)
                                if gid is None:gid=len(geoms);geom_ids[v]=gid;geoms.append(v)
                                matrix.append(gid)
            variants[variant_key]=dict(geometry=matrix,union=[x0,y0,x1,y1],sourceKey=row['sourceKey'],
                unionMode=union_mode,logicalBack=True,pack=row['pack'],folder=row['folder'],stem=row['stem'],
                density=base['density'],floater=bool(floaters.get(row['stem'])),
                metrics=staticmetrics.get(row['stem'])if base['static']else dbkmetrics.get(row['stem']))
    writejson('source-geometry.json',dict(schema=1,production=str(DEX/'sprites/main.lua'),
        geometryFields=['boxW','boxH','ox','oy','dw','dh','scale','floatLift'],layoutKeys=layoutkeys,
        floaterStems=floaters,floatMatrixMeaning='The hover branch assumes the resolved species stem is a flagged floater AND the float option is enabled. Otherwise select hover0.',
        geometries=geoms,sources=variants))
    totals=collections.Counter();dynamic=collections.Counter();female=collections.Counter()
    for row in done:
        if row['status']=='ok':
            totals[row['pack']]+=row['frames'];dynamic[row['pack']]+=int(row['frames']>1)
            female[row['pack']]+=int(row['stem'].lower().endswith('_female'))
    summary=dict(schema=1,created=time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime()),
        sourceVersion=json.loads((DEX/'manifest.json').read_text(encoding='utf-8-sig'))['version'],
        actualSheets=len(done),byPackFolderStatus=dict(sorted(counts.items())),framesByPack=dict(totals),
        productionSha256=hashlib.sha256((DEX/'sprites/main.lua').read_bytes()).hexdigest(),
        incompleteStripTails=[dict(sourceKey=r['sourceKey'],width=r['scanTailWidth'],opaquePixels=r['scanTailOpaquePixels']) for r in done if r.get('scanTailWidth')],
        animatedSheetsByPack=dict(dynamic),femaleSheetsByPack=dict(female),uniqueGeometries=len(geoms),
        sourceUnionVariants=len(variants),elapsedSeconds=round(time.time()-started,2),errors=errors,
        scope='Raw body PNGs only; icons, separate shadows, tera film and dynamax clouds excluded.',
        limits=['Alpha union is a silhouette contact proxy; tails, wings, dangling limbs and support props may be lower than anatomical feet.',
            'Intentionally floating/flying sprites must keep intentional hover relative to mound ground.',
            'Animation union is stable across all poses. A per-frame lowest pixel is not a valid reason to move a mound every frame.',
            'KIM source art may contain author-painted cosmetics or detached pixels; this audit does not semantically segment them.',
            'Production setupFrames was executed with exact original alpha unions; no claim is made that every in-game render was visually inspected.',
            'Horizontal front mirroring changes the x landmark only; art bottom and vertical geometry are unchanged.',
            'Natural/custom battle scenes have independent scale/headroom and must calculate layout using their actual draw transform.'])
    writejson('summary.json',summary)
    def original_hash(row):
        return row['sourceKey'],hashlib.sha256(Path(row['path']).read_bytes()).hexdigest()
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.workers)as pool:
        hashes=dict(pool.map(original_hash,(r for r in done if r['status']=='ok')))
    writejson('asset-provenance.json',dict(schema=1,bodySheets=len(hashes),sha256BySource=hashes,
        sourceSha256=summary['productionSha256']))
    print(json.dumps({k:summary[k] for k in ('actualSheets','framesByPack','uniqueGeometries','sourceUnionVariants','elapsedSeconds')},indent=2),flush=True)

if __name__=='__main__':main()
