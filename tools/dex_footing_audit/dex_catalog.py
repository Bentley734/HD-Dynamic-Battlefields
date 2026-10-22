"""Compact independent source-resolution facts for HD mound geometry."""
import hashlib
import json
from pathlib import Path
import sys
from audit_paths import OUT as HERE, DEX as ROOT, require_dex_version
require_dex_version()
from lupa.lua53 import LuaRuntime
lua=LuaRuntime()
def load(p):return lua.execute((ROOT/p).read_text(encoding='utf-8'))
dbk=load('sprites/data/dbk_data.lua');ee=load('sprites/data/ee_data.lua');static=load('sprites/data/static_data.lua')
census=json.loads((HERE/'resolution.json').read_text())
stems={}
for row in census['plans']:
    if row['gender']=='default' and row['side']=='front' and row['palette']=='normal' and row['style'] in (0,3):
        stems.setdefault(row['species'],{})['base' if row['style']==0 else 'ee']=row['stem']
payload={'schema':1,'peerVersion':'1.5.2','species':stems,
 'female':{k:k+'_female' for k,v in dbk.female.items() if v},'eeFemale':{},'eeMissing':{},'staticMissing':{},'staticRemap':{},
 'fingerprints':{p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in ['sprites/main.lua','sprites/data/dbk_data.lua','sprites/data/ee_data.lua','sprites/data/static_data.lua']}}
for stem in dbk.stems.keys():
    if ee.files.front[stem+'_female'] or dbk.female[stem]:payload['eeFemale'][stem]=stem+'_female'
for folder in ('front','front_shiny','back','back_shiny'):
    payload['eeMissing'][folder]={};payload['staticMissing'][folder]={};payload['staticRemap'][folder]={}
    for stem in dbk.stems.keys():
        if not ee.files[folder][stem]:payload['eeMissing'][folder][stem]=True
        target=stem if static.files[folder][stem] else static.aliases[stem]
        if not target or not static.files[folder][target]:payload['staticMissing'][folder][stem]=True
        elif target!=stem:payload['staticRemap'][folder][stem]=target
def quote(value):return json.dumps(value,ensure_ascii=True)
def literal(value):
    if isinstance(value,dict):return '{'+','.join('['+quote(k)+']='+literal(v) for k,v in sorted(value.items()))+'}'
    if isinstance(value,bool):return 'true' if value else 'false'
    if isinstance(value,str):return quote(value)
    return str(value)
(HERE/'dex_source_catalog.lua').write_text('-- Generated independent source identity facts; no artwork or peer code.\nreturn '+literal(payload)+'\n',encoding='utf-8')
(HERE/'dex_source_catalog.json').write_text(json.dumps(payload,separators=(',',':')),encoding='utf-8')
print('Wrote',len(stems),'species, bytes',(HERE/'dex_source_catalog.lua').stat().st_size)
