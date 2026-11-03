package.path=engine..'/?.lua;'..package.path
local Version={engine='0.3.98'}
package.loaded['src.core.Version']=Version
local Semver=require('src.mods.Semver')
local make=assert(loadfile(root..'/lib/runtime_backend.lua'))()
local backend=make({}, {})
local checks=0
local function check(value,message)checks=checks+1;assert(value,message)end
for _,range in ipairs({'>=0.3.88 <0.4.0','>=0.3.89 <=0.4.0','>=0.3.95','0.0.0-dev || >=0.3.88 <0.4.0','^0.3.88'})do
 for _,version in ipairs({'0.3.98','0.4.0','1.0.0','9.0.0'})do
  Version.engine=version;check(backend.compatible({game_version=range}),range..' rejects '..version)
 end
 Version.engine='0.3.87';check(not backend.compatible({game_version=range}),'Minimum bypassed: '..range)
end
Version.engine='0.0.0-dev'
check(backend.compatible({game_version='0.0.0-dev || >=0.3.88 <0.4.0'}),'Explicit development alternative lost')
for _,range in ipairs({'',' ','>=garbage <0.4.0','>=0.3.88 ||','|| >=0.3.88','>=0.3.88 <<0.4.0','>=0.3.88 || garbage'})do
 check(not backend.compatible({game_version=range}),'Malformed range accepted: '..range)
end
check(not backend.compatible({}),'Missing range accepted')
check(not backend.compatible({game_version=3}),'Non-string range accepted')
-- Dependency matching must retain its independent upper bounds.
check(not Semver.satisfies('2.0.0','>=1.0.0 <2.0.0'),'Dependency maximum changed')
-- Content validation still rejects missing metadata before reading textures.
local ok,why=backend.validate({},function()return nil end)
check(not ok and why=='Missing compositions.json','Content guard changed')
print('PASS minimum-only legacy artwork-pack runtime policy: '..checks..' checks')
