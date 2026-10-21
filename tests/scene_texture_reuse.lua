local P=assert(loadfile(root..'/lib/perspective.lua'))()
local S=assert(loadfile(root..'/lib/scene.lua'))()
local catalog=assert(loadfile(root..'/metadata/prototype.lua'))()
local original=catalog.compositions[1]
local counts={}
local function load(path)
 if path=='bad'then error('corrupt texture')end
 counts[path]=(counts[path]or 0)+1
 return{getWidth=function()return path:find('mound')and 900 or 1920 end,
  getHeight=function()return path:find('mound')and 300 or 1080 end,
  release=function(self)assert(not self.released,'Double release');self.released=true end}
end
local scene=S.new({},P,load,function(path)return path:gsub('^installed:','')end)
local function entry(background,mounds)
 return{id=background,background=background,metadata=original.metadata,
  aspect_ratio=original.aspect_ratio,mounds=mounds}
end
local first=entry('first',{player='installed:mound-shared',opponent='installed:mound-shared'})
assert(scene:prepare(first,catalog.metadata))
local shared=scene.textures['installed:mound-shared'];local old=scene.textures.first
assert(scene.moundSourcePaths.player=='mound-shared')
assert(scene:prepare(entry('second',first.mounds),catalog.metadata))
assert(counts['installed:mound-shared']==1 and scene.textures['installed:mound-shared']==shared)
assert(old.released and not shared.released)
local retained=scene.textures.second
assert(not scene:prepare(entry('second',{player='mound-new',opponent='bad'}),catalog.metadata))
assert(scene.textures.second==retained and not retained.released and not shared.released)
assert(counts.second==1,'Failed replacement reloaded borrowed background')
scene:release();assert(retained.released and shared.released and not scene.moundSourcePaths)
print('PASS active texture reuse, canonical mound identity, transactional failure and release ownership')
