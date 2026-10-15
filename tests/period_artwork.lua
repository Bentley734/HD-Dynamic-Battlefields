local S=assert(loadfile(root..'/lib/scene.lua'))()
local P=assert(loadfile(root..'/lib/perspective.lua'))()
local catalog=assert(loadfile(root..'/metadata/prototype.lua'))()
local images={}
local G={newQuad=function()return{release=function()end}end}
local scene=S.new(G,P,function(path)
 if path=='missing'then error('Missing night art')end
 local item={getWidth=function()return path:find('mound')and 900 or 1672 end,
  getHeight=function()return path:find('mound')and 300 or 941 end,release=function(self)self.released=true end}
 images[path]=item;return item
end)
local entry=catalog.compositions[1]
assert(scene:prepare(entry,catalog.metadata,'day'))
local day=images[entry.backgrounds.day]
assert(scene.backgroundPath==entry.backgrounds.day and scene.period=='day')
assert(scene:prepare(entry,catalog.metadata,'night'))
assert(day.released and scene.backgroundPath==entry.backgrounds.night and scene.period=='night')
assert(scene.moundPaths.player==entry.night_mounds.player)
local night=images[entry.backgrounds.night]
local broken={};for k,v in pairs(entry)do broken[k]=v end
broken.backgrounds={day=entry.background,night='missing'}
assert(not scene:prepare(broken,catalog.metadata,'night'))
assert(scene.period=='night'and scene.backgroundPath==entry.backgrounds.night and not night.released)
broken.backgrounds={day=entry.background}
assert(not scene:prepare(broken,catalog.metadata,'night'))
assert(not scene:prepare(entry,catalog.metadata,'sunset'))
assert(scene:prepare(entry,catalog.metadata,'day'))
assert(night.released and scene.backgroundPath==entry.backgrounds.day)
scene:release()
print('PASS separate day/night artwork and mounds, live period replacement/release, failed/missing night-art retention and invalid-period rejection')
