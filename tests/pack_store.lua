local P = assert(loadfile(root..'/lib/pack_store.lua'))()
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
