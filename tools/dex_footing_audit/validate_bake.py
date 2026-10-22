"""Run unmodified scan/setup/pixel bake against original sprite alpha in LuaJIT.

This verifies sampled sources, not a visual review of every anatomical foot.
The exhaustive source unions and option layout matrix are separate artifacts.
"""
import json, sys, time
from pathlib import Path
from audit_paths import OUT as HERE, WORKSPACE as ROOT, DEX, require_dex_version
require_dex_version()
from PIL import Image
from lupa.luajit21 import LuaRuntime
records={r['sourceKey']:r for r in map(json.loads,(HERE/'alpha-inventory.jsonl').read_text(encoding='utf-8').splitlines())}
plans=json.loads((HERE/'resolution-luajit.json').read_text())['plans']
source=(DEX/'sprites/main.lua').read_text()
def block(start,end):
    a=source.index(start);return source[a:source.index(end,a+len(start))]
lua=LuaRuntime(unpack_returned_tuples=True)
lua.execute('''
function sourceData(data,w,h)
 return {w=w,h=h,data=data,getDimensions=function(self)return self.w,self.h end,
 getPixel=function(self,x,y)assert(x>=0 and y>=0 and x<self.w and y<self.h);return 1,1,1,self.data:byte(y*self.w+x+1)/255 end}
end
function outputData(w,h)
 return {w=w,h=h,p={},getDimensions=function(self)return self.w,self.h end,
 getPixel=function(self,x,y)return 1,1,1,self.p[y*self.w+x]or0 end,
 setPixel=function(self,x,y,r,g,b,a)assert(x>=0 and y>=0 and x<self.w and y<self.h);self.p[y*self.w+x]=a end}
end
function outputBounds(data)
 local x0,y0,x1,y1=data.w,data.h,-1,-1
 for p,a in pairs(data.p)do if a>0 then local y=math.floor(p/data.w);local x=p%data.w
 x0=math.min(x0,x);x1=math.max(x1,x);y0=math.min(y0,y);y1=math.max(y1,y)end end
 return x0,y0,x1,y1
end
function newImage(data)return {data=data,setFilter=function()end}end
'''.replace('or0','or 0'))
env=lua.table_from(dict(GEN=3,FRONT_SCALE=2,BACK_SCALE=3,ANCHOR_FEET=0,ANCHOR_PACK=1,
    GEN3_SPRITE_LIFT=0,FLOAT_LIFT=.05,FLOAT_LIFT_MIN=.05,CLOUD_BAND=.26,CLOUD_MIN_H=5,
    CLOUD_MASS_BOT=.585,CLOUD_OVERLAP=2,ourFrames=lua.table(),gen3BattleLiftByImage=lua.table(),
    audit_mode=1,audit_anchor=0,audit_float=False))
lua.eval('function(e)setmetatable(e,{__index=_G})end')(env)
env.love=lua.table_from(dict(image=lua.table_from(dict(newImageData=lua.globals().outputData)),
    graphics=lua.table_from(dict(newImage=lua.globals().newImage))))
env.DATA=lua.table_from(dict(static=lua.table_from(dict(metrics=lua.execute((DEX/'sprites/data/static_metrics.lua').read_text())))))
env.METRICS=lua.execute((DEX/'sprites/data/dbk_metrics.lua').read_text())
env.FLOATERS=lua.execute((DEX/'sprites/data/dbk_float.lua').read_text())
env.boxFor=lua.eval('function(back,box)return box or {w=64,h=64}end')
chunk='''local function round(n)return math.floor(n+.5)end
local function spriteSizeMode()return audit_mode end
local function spriteAnchor()return audit_anchor end
local function floatOn()return audit_float end
'''+block('  local function cloudSink(','  -- BIG is the default divisor')+block('  local function floatLift(','  local function fpsValue(')+block('  local function beginBuild(',"  -- The crystal film's per-pixel colour")+block('  local function buildOneFrame(','  -- One bounded step.')+'\nreturn {begin=beginBuild,scan=scanChunk,setup=setupFrames,frame=buildOneFrame}'
loader=lua.eval('function(s,e)local f,err=loadstring(s);assert(f,err);setfenv(f,e);return f()end')
api=loader(chunk,env)
checks=[];started=time.time()
species=('METAGROSS','SALAMENCE','PIKACHU','CHARIZARD','MAGNEMITE','GENGAR','SWAMPERT','MEW')
selected={}
for plan in plans:
    if plan['species'] in species and plan['gender']=='default' and plan['palette']=='normal':
        selected[(plan['sourceKey'],plan['unionMode'])]=plan
for (key,union_mode),plan in selected.items():
    row=records[key]
    with Image.open(row['path'])as image:
        alpha=image.convert('RGBA').getchannel('A')
        if row['pack']=='kim':
            rec=row['record'];strip=Image.new('L',(rec['width']*rec['frames'],rec['height']))
            for f in range(rec['frames']):
                x=(f%rec['columns'])*rec['width'];y=(f//rec['columns'])*rec['height']
                strip.paste(alpha.crop((x,y,x+rec['width'],y+rec['height'])),(f*rec['width'],0))
            alpha=strip
        image_data=lua.globals().sourceData(alpha.tobytes(),*alpha.size)
    sheet=lua.table_from(dict(stem=plan['stem'],sourceStem=plan['sourceStem'],
        back=plan['side']=='back',style=plan['style'],static=plan['pack']=='static',ee=plan['pack']=='ee'))
    if plan['pack']in('bw','kim'):sheet.bwTiming=lua.table()
    if plan['pack']=='kim':sheet.kimRecord=lua.table_from(dict(count=row['frames']))
    assert api.begin(sheet,image_data)
    b=sheet.build
    while b.row<b.H:api.scan(b,256)
    wanted=row['first'if union_mode=='first'else'union']
    actual=[b.x0,b.y0,b.x1,b.y1]
    assert actual==wanted,(key,union_mode,actual,wanted)
    # Probe the full animated union at each offered size and anchor. A frame
    # that lacks the union's bottom may be an intentional bob/pose, not a defect.
    for size in (1,2,3):
        env.audit_mode=size
        for anchor in(0,1,2):
            env.audit_anchor=anchor
            for hover in(False,True):
                env.audit_float=hover
                assert api.setup(b)
                union_bottom=-1;nonempty=0
                for frame in range(b.count):
                    b.frame=frame;api.frame(sheet)
                    bounds=lua.globals().outputBounds(sheet.frames[frame+1].data)
                    if bounds[3]>=0:union_bottom=max(union_bottom,bounds[3]);nonempty+=1
                expected=b.oy+b.dh-1
                # Styles selecting only the first pose retain full strip union
                # for DBK static fallbacks; that pose can intentionally be above it.
                full_loop=not plan['outputFirstOnly']or row['frames']==1 or union_mode=='first'
                if full_loop:assert union_bottom==expected,(key,size,anchor,hover,union_bottom,expected)
                checks.append(dict(sourceKey=key,stem=plan['stem'],style=plan['style'],size=size,
                    anchor=anchor,hover=hover,frames=b.count,unionBottom=union_bottom,
                    layoutBottom=expected,fullLoop=full_loop,nonempty=nonempty))
    if len(checks)%180==0:print(f'validated{len(checks)}option profiles in{time.time()-started:.1f}s',flush=True)
report=dict(schema=1,sourceSheets=len(selected),profiles=len(checks),frameBakes=sum(c['frames']for c in checks),
    elapsedSeconds=round(time.time()-started,2),errors=[],checks=checks,
    note='Real unmodified LuaJIT production beginBuild/scan/setup/buildOneFrame with original alpha; body only, no shadow/cloud/tera overlays.')
(HERE/'production-bake-validation.json').write_text(json.dumps(report,separators=(',',':')),encoding='utf-8')
print(json.dumps({k:v for k,v in report.items()if k!='checks'},indent=2))
