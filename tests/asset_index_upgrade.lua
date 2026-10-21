local Updates=assert(loadfile(root..'/lib/asset_updates.lua'))()
local Json=assert(loadfile(engine..'/src/link/Json.lua'))()
local Semver=assert(loadfile(engine..'/src/mods/Semver.lua'))()
local disk={};local body
local backend={encode=Json.encode,decode=Json.decode,hash=sha256,compareVersions=Semver.compare,
 read=function(path)return disk[path]end,write=function(path,value)disk[path]=value;return true end,
 get=function()return{}end,poll=function()return{status='ok',body=body}end,
 release=function()end,cancel=function()end,compatible=function()return true end}
local schema={validate=function()return true end,assetUrl=function()return true end}
local function index(version)return{schema_version=1,repository='example/assets',version=version,packs={}}end
local function cache(slot,version,sequence)
 local value=Json.encode(index(version));disk['asset-index-'..slot..'.json']=Json.encode({body=value,sha256=sha256(value),sequence=sequence})
end
cache(1,'0.2.0-beta.1',50)
local u=Updates({},backend,schema,index('0.3.0-beta.1'))
assert(u.index.version=='0.3.0-beta.1','Stale cache hid the bundled Hoenn catalog')
body=Json.encode(index('0.2.0-beta.1'));assert(u:check());u:update()
assert(u.status=='error'and u.index.version=='0.3.0-beta.1')
body=Json.encode(index('0.3.0-beta.2'));assert(u:check());u:update()
assert(u.status=='updated'and u.index.version=='0.3.0-beta.2')
body=Json.encode(index('0.3.0-beta.1'));assert(u:check());u:update()
assert(u.status=='error'and u.index.version=='0.3.0-beta.2')
cache(1,'0.3.0-beta.3',4);cache(2,'0.3.0-beta.2',100)
u=Updates({},backend,schema,index('0.3.0-beta.1'))
assert(u.index.version=='0.3.0-beta.3','Sequence displaced a newer catalog version')
print('PASS bundled index upgrade, stale cache rejection, newer remote catalog, rollback rejection and semantic-version cache selection')
