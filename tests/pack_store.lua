local P = assert(loadfile(root..'/lib/pack_store.lua'))()
local raw='https://raw.githubusercontent.com/example/assets/'..string.rep('a',40)..'/art/gen2/16x9/room/room-01.png'
assert(P.assetUrl(raw,'example/assets'))
assert(not P.assetUrl(raw,'other/assets'))
assert(not P.assetUrl(raw:gsub(string.rep('a',40),'main')))
assert(not P.assetUrl(raw:gsub('/art/','/../')))
assert(not P.assetUrl(raw..'?redirect=elsewhere'))
local Json = assert(loadfile(engine..'/src/link/Json.lua'))()
local disk, requests, transfers = {}, {}, 0
local rejectCommit, corruptBody, rejectMetadata = false, false, false
local backend = {
 encode=Json.encode, decode=Json.decode, hash=sha256,
 read=function(p) return disk[p] end,
 write=function(p,v)
  if rejectCommit and p:find('commit-',1,true) then disk[p]='torn';return nil,'disk full' end
  disk[p]=v;return true
 end,
 delete=function(p) disk[p]=nil;return true end,
 imagePath=function(p) return 'mod_cache/hd-dynamic-battlefields/'..p end,
 compatible=function(p) return p.runtime=='0.3.88','runtime incompatible' end,
 validate=function(p,read) return not rejectMetadata and read('layout.json')=='{}','invalid perspective metadata' end,
 get=function(url) local h={url=url};requests[h]=true;transfers=transfers+1;return h end,
 poll=function(h) return {status='ok',body=corruptBody and 'bad' or '{}'} end,
 cancel=function(h) requests[h]=nil end, release=function(h) requests[h]=nil end,
}
local function pack(version)
 return {schema_version=1,metadata_schema=1,id='forest',version=version,runtime='0.3.88',quality='HD',aspects={'16:9'},environments={'forest'},installed_size=2,
 files={{path='layout.json',size=2,sha256=sha256('{}'),url='https://github.com/example/assets/releases/download/v1/layout.json'}}}
end
local function finish(s) for i=1,10 do s:update();if s.status~='downloading' then break end end end
local s=P.new(backend);assert(s:start(pack('1')));finish(s);assert(s.status=='installed');assert(s:installed('forest').version=='1')
assert(s:verify(s:installed('forest')))
-- A corrupt update cannot replace the live pack.
corruptBody=true;assert(s:start(pack('2')));finish(s);assert(s.status=='error');assert(s:installed('forest').version=='1');corruptBody=false
-- A torn commit leaves the older slot intact; restart resumes verified objects.
rejectCommit=true;assert(s:start(pack('2')));finish(s);assert(s.status=='error');assert(s:installed('forest').version=='1');rejectCommit=false
local before=transfers;s=P.new(backend);assert(s:start(pack('2')));finish(s);assert(s.status=='installed' and transfers==before);assert(s:installed('forest').version=='2')
rejectMetadata=true;assert(s:start(pack('3')));finish(s);assert(s.status=='error' and s:installed('forest').version=='2');rejectMetadata=false
-- Invalid compatibility, paths, schema and identities never install.
for _,mutation in ipairs({function(p)p.runtime='0.3.51'end,function(p)p.files[1].path='../escape'end,function(p)p.metadata_schema=9 end,function(p)p.id='../x'end}) do
 local p=pack('4');mutation(p);assert(not s:start(p));assert(s:installed('forest').version=='2')
end
assert(s:start(pack('4')));s:update();s:cancel();assert(s.status=='cancelled' and next(requests)==nil)
-- An externally imported future-runtime commit must not shadow a usable slot.
local incompatible=pack('future');incompatible.runtime='0.4.0'
local body=Json.encode({sequence=99,pack=incompatible})
disk['packs/forest/commit-2.json']=Json.encode({body=body,sha256=sha256(body)})
assert(P.new(backend):installed('forest').version=='2')
assert(not s:verify(incompatible))
assert(s:remove('forest'));assert(not P.new(backend):installed('forest'))
print('PASS pack integrity, offline records, interrupted resume, torn commit rollback, compatibility/schema/path rejection, metadata validation, cancel and removal')

-- A process restart halfway through a multi-file update must resume only the
-- verified objects, while the previous installation remains authoritative.
local payloads={['one.json']='one',['two.json']='two',['three.json']='three'}
local requested={}
backend.get=function(url)
 local name=url:match('/([^/]+)$');requested[#requested+1]=name
 local h={name=name};requests[h]=true;return h
end
backend.poll=function(h)return{status='ok',body=payloads[h.name]}end
backend.validate=function()return true end
local function multi(version)
 local p=pack(version);p.id='resume-multiple';p.files={};p.installed_size=0
 for _,name in ipairs({'one.json','two.json','three.json'})do
  local value=payloads[name]
  p.files[#p.files+1]={path=name,size=#value,sha256=sha256(value),url='https://github.com/example/assets/releases/download/v1/'..name}
  p.installed_size=p.installed_size+#value
 end
 return p
end
local original=multi('1');local first=P.new(backend);assert(first:start(original));finish(first)
assert(first.status=='installed')
local update=multi('2');assert(first:start(update))
first:update();first:update() -- first object is now durably staged
assert(first.completed==3 and first:installed(update.id).version=='1')
first:update();assert(first.handle);first:cancel();assert(next(requests)==nil)
local count=#requested
local restarted=P.new(backend);assert(restarted:start(update));finish(restarted)
assert(restarted.status=='installed' and restarted:verify(restarted:installed(update.id)))
assert(#requested==count+2 and requested[count+1]=='two.json' and requested[count+2]=='three.json','Restart downloaded an already verified object')
-- Corrupting a staged object forces repair rather than trusting its existence.
local repair=multi('3');local repairStore=P.new(backend);assert(repairStore:start(repair))
repairStore:update();repairStore:update();repairStore:cancel()
local object='packs/'..repair.id..'/3/'..repair.files[1].sha256..'/one.json'
disk[object]='bad';count=#requested
repairStore=P.new(backend);assert(repairStore:start(repair));finish(repairStore)
assert(repairStore.status=='installed' and #requested==count+3)
assert(repairStore:verify(repairStore:installed(repair.id)))
print('PASS multi-file restart resumes verified objects, retains previous installed version until commit, and repairs corrupt staged bytes')
