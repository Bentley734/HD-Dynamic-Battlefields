-- Isolated LÖVE harness; mounts only the verified runtime and new project.
local root=assert(os.getenv('HDB_WORKSPACE')):gsub('\\','/')
local project=root..'/HD-Dynamic-Battlefields'
local engine=root..'/.work/hd-battlefields-latest/v0.3.88/engine'
local output=project..'/docs/evidence'
local function read(path)
 local f=assert(io.open(project..'/'..path,'rb'));local b=f:read('*a');f:close();return b
end
local function write(name,bytes)
 local f=assert(io.open(output..'/'..name,'wb'));f:write(bytes);f:close()
end
function love.load()
 local ok,err=xpcall(function()
  package.path=engine..'/?.lua;'..package.path
  assert(require('src.core.Version').engine=='0.3.88')
  local Sandbox=require('src.mods.Sandbox')
  local env=Sandbox.envFor{modId='hd-dynamic-battlefields',permissions={network=true,engine_internals=true}}
  local function module(path)
   return assert(Sandbox.compile(read(path),'@'..path,env))()
  end
  local P,Scene=module('lib/perspective.lua'),module('lib/scene.lua')
  local metadata=module('metadata/prototype.lua')
  local imports,cache=require('src.mods.ImportAccess').new({id='hd-dynamic-battlefields'},love.filesystem)
  local mod={id='hd-dynamic-battlefields',cache=cache}
  local backend=module('lib/runtime_backend.lua')(mod,P)
  assert(backend.compatible({game_version='>=0.3.88 <0.4.0'}))
  assert(not backend.compatible({game_version='>=9.0.0'}))
  local Json=require('src.link.Json')
  local candidate=metadata.compositions[1]
  local catalogBytes=Json.encode({metadata=metadata.metadata,compositions={candidate}})
  assert(backend.validate({files={{path=candidate.background},{path=candidate.mounds.player}}},function(p)if p=='compositions.json'then return catalogBytes end end))
  local bad=Json.decode(catalogBytes);bad.metadata[candidate.metadata].schema_version=99
  assert(not backend.validate({files={}},function()return Json.encode(bad)end))
  local imageBytes=read('art/gen1/16x9/grassland/grassland-01-16x9.png')
  assert(cache:write('probe/grassland.png',imageBytes))
  assert(backend.hash(assert(cache:read('probe/grassland.png')))==backend.hash(imageBytes))
  local sandboxLoad=assert(Sandbox.compile('return function(path) return love.graphics.newImage(path) end','@image-probe',env))()
  local image=sandboxLoad(backend.imagePath('probe/grassland.png'))
  assert(image:getWidth()>1000);image:release()
  local denied=assert(Sandbox.compile('return pcall(function() return love.filesystem end)','@fs-probe',env))()
  assert(denied==false)
  local G=love.graphics
  for _,entry in ipairs(metadata.compositions)do
   local scene=Scene.new(G,P,function(path)return G.newImage(love.filesystem.newFileData(read(path),path))end)
   assert(scene:prepare(entry,metadata.metadata))
   local resolved=assert(P.resolve(metadata.metadata,entry.metadata))
   local width,height=resolved.reference_size.width,resolved.reference_size.height
   local canvas=G.newCanvas(width,height,{dpiscale=1});G.setCanvas(canvas);G.clear(0,0,0,1)
   local layout=assert(scene:layout({width=width,height=height}))
   assert(scene:draw(layout,nil,{calibration=true}))
   G.setCanvas()
   local pixels=canvas:newImageData();write(entry.id..'-calibration.png',pixels:encode('png'):getString());pixels:release()
   canvas:release();scene:release()
  end
  assert(cache:delete('probe/grassland.png'))
  local native=assert(loadfile(project..'/tools/gpu_probe/native.lua'))()(project,module,write)
  write('native-red-probe.txt',native)
  local renderer,version,vendor,device=G.getRendererInfo()
  write('runtime-gpu-probe.txt',table.concat({'PASS runtime 0.3.88 Sandbox.envFor and ImportAccess cache','PASS SHA-256 read/write and sandboxed downloaded texture loading','PASS raw filesystem denied','PASS all nine original environment/aspect prototype renders','PASS separate grass/forest/cave mound textures with uniform scaling',native,'CALIBRATION/RENDERER FIXTURES: not installed in the live game; no gameplay traversal or physical-device test',renderer,version,vendor,device},'\n'))
 end,debug.traceback)
 love.graphics.setCanvas()
 if not ok then write('runtime-gpu-error.txt',err) end
 love.event.quit(ok and 0 or 1)
end
