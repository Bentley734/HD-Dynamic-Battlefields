-- Real Loader/Sandbox, with only the candidate game's manifest allowlist added
-- in the virtual read layer. Published eligibility remains unchanged.
return function(project,game,values)
 local Json=require('src.link.Json')
 local SaveData=require('src.core.SaveData')
 local workspace=assert(os.getenv('HDB_WORKSPACE')):gsub('\\','/')
 local function read(path)local f=io.open(path,'rb');if not f then return end;local b=f:read('*a');f:close();return b end
 local inventory=Json.decode(assert(read(os.getenv('HDB_INVENTORY_PATH')or workspace..'/.work/hd-rse-loader-directory-index.json')))
 local roots=assert(loadfile(project..'/tools/rse_native_probe/sources.lua'))()(workspace,project)
 local receiptRoot=(os.getenv('HDB_DEX_RECEIPT_ROOT')or workspace..'/.work/hd-rse-compat-latest/dex-manager-fixture'):gsub('\\','/')
 if os.getenv('HDB_PREPARE_DEX_ASSETS')=='1'then
  local result=assert(loadfile(project..'/tools/rse_native_probe/prepare_dex_assets.lua'))()(workspace,roots['1025dex'],
   os.getenv('HDB_DEX_ASSET_ROOT')or workspace..'/.work/hd-rse-compat-latest/dex-artwork',receiptRoot)
  local f=assert(io.open(project..'/docs/evidence/rse/1025dex-real-manager-preparation.json','wb'));f:write(Json.encode(result));f:close()
 end
 local enabled={'hd-dynamic-battlefields'}
 local content=os.getenv('HDB_CONTENT_MODE')or'none'
 if content=='national'then
  for _,id in ipairs({'national_dex_gen3','g9-battle-sprites-gen3','gen3-hd-sprites'})do enabled[#enabled+1]=id end
 elseif content=='1025'then enabled[#enabled+1]='1025dex'
 else assert(content=='none','Unknown content setup')end
 if os.getenv('HDB_MENU_CUSTOMIZER')=='1'then enabled[#enabled+1]='gen3transparency'end
 if os.getenv('HDB_WILDFOLLOWERS')=='1'then enabled[#enabled+1]='wildfollowers'end
 local packRoot=os.getenv('HDB_PACK_FIXTURE')
 local packFixture=packRoot and Json.decode(assert(read(packRoot..'/fixture.json')))
 local hidden={}
 for _,path in ipairs(packFixture and packFixture.hidden_bundled_backgrounds or{})do hidden['mods/hd-dynamic-battlefields/'..path]=true end
 local function source(path)
  local packRelative=path:match('^mod_cache/hd%-dynamic%-battlefields/(.+)$')
  if packRoot and packRelative then return read(packRoot..'/mod_cache/hd-dynamic-battlefields/'..packRelative)end
  local receipt=path:match('^mod_cache/1025dex/(dex_assets/[^/]+)$')
  if receipt then return read(receiptRoot..'/'..receipt)end
  local asset=path:match('^mod_cache/1025dex/dex_assets/files/(.+)$')
  if asset then
   local assetRoot=os.getenv('HDB_DEX_ASSET_ROOT')or workspace..'/.work/hd-rse-compat-latest/dex-artwork'
   return read(assetRoot..'/'..asset)
  end
  local id,rel=path:match('^mods/([^/]+)/(.+)$')
  if id then
   local b=roots[id]and read(roots[id]..'/'..rel)
   if id=='hd-dynamic-battlefields'and rel=='manifest.json'and b then
    local m=Json.decode(b);local allowed=false
    for _,value in ipairs(m.games)do if value==game.session.version then allowed=true end end
    if os.getenv('HDB_REQUIRE_MANIFEST_GAME')=='1'then assert(allowed,'Actual manifest does not permit '..game.session.version);return b end
    if not allowed then m.games[#m.games+1]=game.session.version end
    return Json.encode(m)
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
  if hidden[path]then return nil end
  if path=='mods'or inventory[path]then return{type='directory'}end
  local b=fs.read(path);if b then return{type='file',size=#b}end
 end
 function fs.load(path)return assert(loadstring(assert(fs.read(path)),'@'..path))end
 local loader=require('src.mods.Loader').new{fs=fs,generation=3,version=game.session.version,dev=false}
 local dexAssetStatus
 if content=='1025'then
  local schemas=require('src.mods.Schemas')
  local original=schemas.gen3View.preindex
  local observed={}
  schemas.gen3View.preindex=function(registries)
   local failures=original(registries)
   for _,failure in ipairs(failures)do observed[#observed+1]=failure end
   local f=assert(io.open(project..'/docs/evidence/rse/1025dex-native-index-failures.json','wb'));f:write(Json.encode(observed));f:close()
   return failures
  end
 end
 if content=='1025'then
  local loadMod=loader._loadMod
  loader._loadMod=function(self,entry)
   local result=loadMod(self,entry)
   if entry.manifest.id=='1025dex'then
    local manager=self.exports['1025dex']and self.exports['1025dex'].assetManager
    dexAssetStatus={manager_present=manager~=nil,complete=manager and manager:isComplete()or false,
     label=manager and manager:statusLabel()or'missing',scope='Actual 1025Dex manager after entry execution, before native content validation/rollback.'}
   end
   return result
  end
 end
 loader.game=game;game.mods=loader;loader:load(game.data)
 if content=='1025'then
  local status=dexAssetStatus or{complete=false,scope='1025Dex entry did not finish'}
  local f=assert(io.open(project..'/docs/evidence/rse/1025dex-loaded-manager-readiness.json','wb'));f:write(Json.encode(status));f:close()
  assert(status.complete,'1025Dex asset manager does not recognize the installed pack')
 end
 for _,id in ipairs(enabled)do
  assert(loader.mods[id]and loader.mods[id].state=='loaded',id..': '..table.concat(loader.errors,'\n'))
 end
 -- Match native startup: apply merged views, reload cartridge species,
 -- then let dependent mods link their final providers and animation aliases.
 require('src.mods.Gen3Compat').applyMerged(game)
 require('src.core.game3.pokemon').install(require('src.core.game3.dataset').cache())
 loader.events:emit('game.ready',{game=game})
 assert(#loader.errors==0,table.concat(loader.errors,'\n'))
 local exports=loader.exports['hd-dynamic-battlefields']
 local species=exports.getSpeciesChoices()
 local found,listed=false,{}
 for _,row in ipairs(species)do listed[row.id]=true;if row.id=='TREECKO'then found=true end end
 assert(found,'Native Treecko missing from species position chooser')
 if content~='none'then
  assert(#species>=1025 and listed.PECHARUNT,'Expanded species missing from chooser')
  if content=='national'then
   assert(loader.exports['gen3-hd-sprites'].isActive(),'HD sprite provider inactive')
   for _,row in ipairs(loader.exports.national_dex_gen3.listSpecies())do assert(listed[row.id],'Missing species '..row.id)end
   for _,row in ipairs(loader.exports.national_dex_gen3.listForms())do assert(listed[row.id],'Missing form '..row.id)end
  else assert(listed.CHARIZARD_MEGA_X,'1025Dex form missing from chooser')end
  for id,record in loader.content.pokemon:each()do
   if record.gen3Species then assert(listed[id],'Registered species/form missing '..id)end
  end
 end
 local versions={};for _,id in ipairs(enabled)do versions[id]=loader.mods[id].manifest.version end
 return{exports=exports},loader,enabled,#species,versions
end
