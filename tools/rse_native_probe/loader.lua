-- Real Loader/Sandbox, with only the candidate game's manifest allowlist added
-- in the virtual read layer. Published eligibility remains unchanged.
return function(project,game,values)
 local Json=require('src.link.Json')
 local SaveData=require('src.core.SaveData')
 local workspace=assert(os.getenv('HDB_WORKSPACE')):gsub('\\','/')
 local function read(path)local f=io.open(path,'rb');if not f then return end;local b=f:read('*a');f:close();return b end
 local inventory=Json.decode(assert(read(workspace..'/.work/hd-rse-loader-directory-index.json')))
 local roots={['hd-dynamic-battlefields']=project,gen3transparency=os.getenv('HDB_MENU_ROOT')or workspace..'/.work/menu-gen3-font-fix'}
 local enabled={'hd-dynamic-battlefields'}
 if os.getenv('HDB_MENU_CUSTOMIZER')=='1'then enabled[#enabled+1]='gen3transparency'end
 local function source(path)
  local id,rel=path:match('^mods/([^/]+)/(.+)$')
  if id then
   local b=roots[id]and read(roots[id]..'/'..rel)
   if id=='hd-dynamic-battlefields'and rel=='manifest.json'and b then
    local m=Json.decode(b);m.games[#m.games+1]=game.session.version;return Json.encode(m)
   end
   return b
  end
  return love.filesystem.read(path)
 end
 local configured=SaveData.defaultOptions()
 configured.mods={}
 for _,id in ipairs(enabled)do configured.mods[id]=true end
 configured.modOptions={['hd-dynamic-battlefields']=values}
 game.options=configured;SaveData.loadOptions=function()return configured end
 local disk={}
 local fs={read=function(p)return disk[p]or source(p)end,
  write=function(p,b)disk[p]=b;return true end,remove=function(p)disk[p]=nil;return true end,
  createDirectory=function()return true end,
  getDirectoryItems=function(p)if p=='mods'then return enabled end;return inventory[p]or{}end}
 function fs.getInfo(path)
  if path=='mods'or inventory[path]then return{type='directory'}end
  local b=fs.read(path);if b then return{type='file',size=#b}end
 end
 function fs.load(path)return assert(loadstring(assert(fs.read(path)),'@'..path))end
 local loader=require('src.mods.Loader').new{fs=fs,generation=3,version=game.session.version,dev=false}
 loader.game=game;game.mods=loader;loader:load(game.data)
 for _,id in ipairs(enabled)do
  assert(loader.mods[id]and loader.mods[id].state=='loaded',id..': '..table.concat(loader.errors,'\n'))
 end
 local exports=loader.exports['hd-dynamic-battlefields']
 local species=exports.getSpeciesChoices()
 local found=false;for _,row in ipairs(species)do if row.id=='TREECKO'then found=true end end
 assert(found,'Native Treecko missing from species position chooser')
 return{exports=exports},loader,enabled,#species
end
