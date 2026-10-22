"""Rank body-contact ambiguity and render original sprites through production bake.

QA contact sheets are temporary review artifacts, never replacement artwork.
Candidates are hypotheses for human review, not automatic anatomical landmarks.
"""
import collections,json,math,sys,time
from pathlib import Path
from audit_paths import OUT as HERE, WORKSPACE as ROOT, DEX, require_dex_version
require_dex_version()
from PIL import Image,ImageDraw,ImageFont
import numpy as np
started=time.time()
records={r['sourceKey']:r for r in map(json.loads,(HERE/'alpha-inventory.jsonl').read_text(encoding='utf-8').splitlines())}
plans=json.loads((HERE/'resolution-luajit.json').read_text())['plans']
floaters=json.loads((HERE/'source-geometry.json').read_text())['floaterStems']
chosen={}
for p in plans:
    if p['palette']!='normal':continue
    key=p['sourceKey']
    # Prefer a normal animated/full-union representative of a physical image.
    priority=(p['unionMode']=='first',p['style']==1,p['gender']=='female',p['species'])
    if key not in chosen or priority<chosen[key][0]:chosen[key]=(priority,p)

def first_image(row):
    with Image.open(row['path'])as im:
        fw,fh=row['frameW'],row['frameH']
        return im.crop((0,0,fw,fh)).convert('RGBA')

candidates=[]
for index,(_,plan)in enumerate(chosen.values(),1):
    row=records[plan['sourceKey']]
    im=first_image(row);a=np.asarray(im)[:,:,3]>0
    bounds=row['first']
    if not bounds:continue
    x0,y0,x1,y1=bounds;body=a[y0:y1+1,x0:x1+1]
    width=body.sum(axis=1);ch,cw=body.shape;maxw=int(width.max())
    threshold=max(2,maxw*.24);thin=0
    for w in width[::-1]:
        if w>=threshold:break
        thin+=1
    native_scale=min(1,64/(row['union'][2]-row['union'][0]+1),64/(row['union'][3]-row['union'][1]+1))
    low=body[max(0,ch-max(1,round(ch*.08))):]
    bx=np.flatnonzero(low.any(axis=0));allx=np.flatnonzero(body.any(axis=0))
    asym=abs(float(bx.mean())-(cw-1)/2)/max(1,cw)if len(bx)else 0
    support=float(width[-min(3,ch):].mean())/max(1,maxw)
    segment_count=sum(1 for x in range(1,len(bx))if bx[x]>bx[x-1]+1)+bool(len(bx))
    # Thin elongated appendages below the broad lower body are the strongest
    # signal; asymmetry and isolated bottom supports break ties only.
    score=thin*native_scale*5+(1-min(1,support))*3+asym*4+max(0,segment_count-2)*.3
    rec=dict(sourceKey=plan['sourceKey'],species=plan['species'],stem=plan['stem'],
        pack=plan['pack'],side=plan['side'],style=plan['style'],gender=plan['gender'],
        sourceStem=plan['sourceStem'],unionMode=plan['unionMode'],
        intentionalFloater=bool(floaters.get(plan['stem'])),score=round(score,4),
        thinBottomSourceRows=thin,thinBottomNativePixels=round(thin*native_scale,3),
        lowerSupportRatio=round(support,4),bottomAsymmetry=round(asym,4),
        bottomSupportSegments=int(segment_count),firstPoseUnionGap=row['union'][3]-y1,
        candidateWiderSupportSourceY=max(y0,y1-thin),firstPoseBounds=bounds,
        note='Risk score is a human-review hypothesis; wider support may be a belly, fin or tail rather than feet.')
    candidates.append(rec)
    if index%2000==0:print(f'ranked {index}/{len(chosen)} in {time.time()-started:.1f}s',flush=True)

(HERE/'visual-qa').mkdir(exist_ok=True)
(HERE/'visual-qa/candidates.json').write_text(json.dumps(candidates,separators=(',',':')),encoding='utf-8')

# Reuse the unmodified production extraction from the bake validation harness.
# Stop before its separate validation execution, then replace alpha-only ImageData
# adapters with RGBA adapters for a faithful colored first-pose review.
support=Path(__file__).with_name('validate_bake.py')
namespace={'__file__':str(support),'__name__':'qa_production_support'}
initial=support.read_text().split('checks=[];started=time.time()')[0]
exec(compile(initial,str(support),'exec'),namespace)
lua,env,api=namespace['lua'],namespace['env'],namespace['api']
lua.execute('''
function sourceRGBA(data,w,h,stride)
 return {w=w,h=h,data=data,stride=stride,getDimensions=function(self)return self.w,self.h end,
 getPixel=function(self,x,y)local q=(y*self.stride+x)*4+1;local r,g,b,a=self.data:byte(q,q+3);return r/255,g/255,b/255,a/255 end}
end
function outputRGBA(w,h)
 return {w=w,h=h,p={},c={},getDimensions=function(self)return self.w,self.h end,
 getPixel=function(self,x,y)local p=self.c[y*self.w+x];if p then return p[1],p[2],p[3],p[4]end;return 0,0,0,0 end,
 setPixel=function(self,x,y,r,g,b,a)assert(x>=0 and y>=0 and x<self.w and y<self.h);local p=y*self.w+x;self.p[p]=a;self.c[p]={r,g,b,a}end}
end
function rgbaBytes(data)
 local rows={};for y=0,data.h-1 do local row={};for x=0,data.w-1 do
 local p=data.c[y*data.w+x]or{0,0,0,0};row[#row+1]=string.char(math.floor(p[1]*255+.5),math.floor(p[2]*255+.5),math.floor(p[3]*255+.5),math.floor(p[4]*255+.5))end
 rows[#rows+1]=table.concat(row)end;return table.concat(rows)
end
''')
env.love.image.newImageData=lua.globals().outputRGBA
# Lupa's default UTF8 decoding should not touch arbitrary pixel byte strings.
rgba_bytes=lua.eval('function(data)local hex=rgbaBytes(data):gsub(".",function(c)return string.format("%02x",string.byte(c))end);return hex end')

def bake(rec):
    row=records[rec['sourceKey']];image=first_image(row)
    # Only framezero is read while baking this pose; dimensions still describe
    # the full source strip so beginBuild computes its exact production fw/count.
    W=row['frameW']*row['frames']if row['pack']=='kim'else row['width']
    data=lua.globals().sourceRGBA(image.tobytes(),W,row['frameH'],row['frameW'])
    sheet=lua.table_from(dict(stem=rec['stem'],sourceStem=rec['sourceStem'],back=rec['side']=='back',
        style=rec['style'],static=rec['pack']=='static',ee=rec['pack']=='ee'))
    if rec['pack']in('bw','kim'):sheet.bwTiming=lua.table()
    if rec['pack']=='kim':sheet.kimRecord=lua.table_from(dict(count=row['frames']))
    env.audit_mode=1;env.audit_anchor=0;env.audit_float=True
    assert api.begin(sheet,data);b=sheet.build
    bounds=row['first'if rec['unionMode']=='first'else'union']
    b.x0,b.y0,b.x1,b.y1=bounds
    assert api.setup(b);api.frame(sheet)
    pixeldata=sheet.frames[1].data
    raw=bytes.fromhex(rgba_bytes(pixeldata))
    image=Image.frombytes('RGBA',(64,64),raw)
    rec['bake']=dict(ox=b.ox,oy=b.oy,dw=b.dw,dh=b.dh,scale=b.scale,ground=64,
        firstPoseBakedBounds=list(lua.globals().outputBounds(pixeldata)))
    return image

def qa_font(size):
    try:return ImageFont.truetype('DejaVuSansMono.ttf',size)
    except OSError:return ImageFont.load_default(size=size)
font,small,titlefont=qa_font(13),qa_font(11),qa_font(20)
pages=[];selections=[]
for floating,count in((False,200),(True,60)):
    for pack in('dbk','ee','static','bw','kim'):
        ranked=sorted((r for r in candidates if r['pack']==pack and r['intentionalFloater']==floating),key=lambda r:-r['score'])
        # Retain forms and female artwork while avoiding a single base family's
        # many aliases consuming a complete page of candidates.
        chosen_rows=[];family=collections.Counter()
        for rec in ranked:
            base=rec['species'].split('_')[0]
            if family[base]>=8:continue
            chosen_rows.append(rec);family[base]+=1
            if len(chosen_rows)>=count:break
        selections.extend(chosen_rows)
        for start in range(0,len(chosen_rows),100):
            batch=chosen_rows[start:start+100];cw,ch=192,188;header=52
            canvas=Image.new('RGB',(cw*10,header+ch*math.ceil(len(batch)/10)),(24,27,33))
            draw=ImageDraw.Draw(canvas)
            label=f'{pack.upper()} {"INTENTIONAL FLOATERS"if floating else"GROUNDED CONTACT RISK"} | page {start//100+1} | original production BIG/FEET first pose'
            draw.text((12,7),label,fill=(240,240,244),font=titlefont)
            draw.text((12,32),'Cyan = stable mound ground. Gray ellipse = QA support. Thin-tip score is a hypothesis; inspect anatomical feet.',fill=(165,185,205),font=small)
            for n,rec in enumerate(batch):
                col,rownum=n%10,n//10;x,y=col*cw,header+rownum*ch
                draw.rectangle((x+1,y+1,x+cw-2,y+ch-2),fill=(37,41,48),outline=(65,70,80))
                ground=y+134;draw.ellipse((x+20,ground-5,x+172,ground+10),fill=(73,82,75))
                draw.line((x+12,ground,x+180,ground),fill=(35,218,225),width=2)
                sprite=bake(rec).resize((128,128),Image.Resampling.NEAREST)
                canvas.paste(sprite,(x+32,y+6),sprite)
                ident=f'{pack[0].upper()}{"F"if floating else"G"}{start+n+1:03}'
                rec['qaId']=ident
                draw.text((x+5,y+140),ident+' '+rec['stem'][:21],font=font,fill=(247,245,231))
                draw.text((x+5,y+156),f'{rec["side"]} s{rec["style"]} risk{rec["score"]:.1f} tip{rec["thinBottomNativePixels"]:.1f}',font=small,fill=(181,201,220))
                draw.text((x+5,y+170),f'pose gap {rec["firstPoseUnionGap"]} source px',font=small,fill=(160,180,195))
            name=f'{pack}-{"floaters"if floating else"grounded"}-{start//100+1:02}.png'
            target=HERE/'visual-qa'/name;canvas.save(target)
            pages.append(dict(path=str(target),pack=pack,floating=floating,ids=[r['qaId']for r in batch]))
            print(f'rendered {name} ({len(batch)} sprites) in {time.time()-started:.1f}s',flush=True)
report=dict(schema=1,ranked=len(candidates),groundedCandidateCount=sum(not r['intentionalFloater']for r in selections),
    floatingCandidates=sum(r['intentionalFloater']for r in selections),pages=pages,selections=selections,
    confirmedAnatomicalLandmarks=[],reviewStatus='Rendered for human anatomical review; risk scores are not accepted foot landmarks.',
    exclusions='Shiny duplicates excluded from visualranking; all palettes remain in exhaustive alpha/layout audit.',
    limitations='Ranked candidates have not yet been anatomically reviewed by a human. Do not automatically apply candidateWiderSupportSourceY as feet.',
    elapsedSeconds=round(time.time()-started,2))
(HERE/'visual-qa/report.json').write_text(json.dumps(report,separators=(',',':')),encoding='utf-8')
print(json.dumps({k:v for k,v in report.items()if k not in('pages','selections')},indent=2))
