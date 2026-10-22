-- Real Loader/Sandbox; only KIM's entry is replaced with its public source API.
-- This deliberately does not claim compatibility with KIM's complete scene.
return function(project,game,values)
 local function read(path)local f=assert(io.open(path,'rb'));local b=f:read('*a');f:close();return b end
 local source=read(project..'/tools/rse_native_probe/loader.lua')
 local function replace(old,new)
  local a=assert(source:find(old,1,true),'Missing loader fixture seam '..old)
  source=source:sub(1,a-1)..new..source:sub(a+#old)
 end
 replace("local enabled={'hd-dynamic-battlefields'}",[[
 roots['1025dex-bw-sprites']=assert(os.getenv('HDB_BW_ROOT')):gsub('\\','/')
 roots.kim1025=assert(os.getenv('HDB_KIM_ROOT')):gsub('\\','/')
 local enabled={'hd-dynamic-battlefields','1025dex-bw-sprites','kim1025'}]])
 replace('local function source(path)',[=[local function source(path)
  local kimCache=path:match('^mod_cache/kim1025/(.+)$')
  if kimCache then local f=io.open(assert(os.getenv('HDB_KIM_CACHE'))..'/'..kimCache,'rb');if f then local b=f:read('*a');f:close();return b end end
  if path=='mods/kim1025/manifest.json'then
   local m=Json.decode(read(roots.kim1025..'/manifest.json'))
   m.entry='dex_footing_provider.lua';m.optional_dependencies={};m.dependencies={}
   m.description='ISOLATED FIXTURE: actual KIM public sprite provider only; no KIM battle scene.'
   return Json.encode(m)
  elseif path=='mods/kim1025/dex_footing_provider.lua'then
   return [[return function(mod)
    mod.exports=mod.exports or{}
    mod.exports.normalizeSpeciesKey=assert((loadstring or load)(assert(mod:read('lib/species_key.lua'))))()
    mod._kimAssetProvider={read=function(path)
     return mod.cache:read('kim_assets/files/'..path)or mod.cache:read('kim1025_assets/files/'..path)or mod:read(path)
    end}
    assert((loadstring or load)(assert(mod:read('lib/dex_sprite_provider.lua'))))()(mod)
   end]]
  end]=])
 replace("configured.modOptions={['hd-dynamic-battlefields']=values}",[[configured.modOptions={['hd-dynamic-battlefields']=values,
  ['1025dex']={player_sprite_style=1,enemy_sprite_style=1,sprite_size=1,sprite_anchor=0,sprite_float=false,
    sprite_shiny=true,sprite_female=true,battle_shadows=false,player_sprite_view=0,sprite_fps=12},
  kim1025={battleSystem=false,battleSprites=false,hdBattleBackgrounds=false}}]])
 return assert(loadstring(source,'@dex-footing-real-loader'))()(project,game,values)
end
