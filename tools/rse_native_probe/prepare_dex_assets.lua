-- Run the real manager's catalog-verified local migration in isolated storage.
return function(workspace,core,assetRoot,receiptRoot)
 local function read(p)local f=io.open(p,'rb');if not f then return end;local s=f:read('*a');f:close();return s end
 local config=assert(loadstring(assert(read(core..'/compat/asset_config.lua'))))()
 local catalog=assert(loadstring(assert(read(core..'/compat/asset_catalog.lua'))))()
 config.legacyFiles=catalog;config.expectedFiles=catalog;config.embedded=true
 local dirs={}
 for path in pairs(catalog)do
  local parent,name=path:match('^(.*)/([^/]+)$')
  while parent do dirs[parent]=dirs[parent]or{};dirs[parent][name]=true;parent,name=parent:match('^(.*)/([^/]+)$')end
 end
 local function cachePath(key)
  local relative=key:match('^dex_assets/files/(assets/.+)$')
  return relative and assetRoot..'/'..relative or receiptRoot..'/'..key
 end
 local mod={generation=3,cache={},log={info=function()end,error=function(_,fmt,...)error(string.format(fmt,...))end}}
 function mod:read(path)return read(assetRoot..'/'..path)end
 function mod:info(path)
  if dirs[path]then return{type='directory'}end
  local row=catalog[path];if row and read(assetRoot..'/'..path)then return{type='file',size=row.size}end
 end
 function mod:list(path)local out={};for name in pairs(dirs[path]or{})do out[#out+1]=name end;table.sort(out);return out end
 function mod.cache:read(key)return read(cachePath(key))end
 function mod.cache:info(key)local s=read(cachePath(key));if s then return{type='file',size=#s}end end
 function mod.cache:write(key,bytes)
  local path=cachePath(key)
  if key:match('^dex_assets/files/')then
   assert(read(path)==bytes,'Migration tried to replace verified source artwork');return true
  end
  local f=assert(io.open(path,'wb'));f:write(bytes);f:close();return true
 end
 function mod.cache:delete(key)os.remove(cachePath(key));return true end
 local manager=assert(loadstring(assert(read(core..'/compat/asset_download_manager.lua'))))()(mod,config)
 if not manager:isComplete()then
  assert(manager:beginLegacyMigration(),'Manager did not detect complete local asset set')
  for _=1,100000 do manager:update();if manager.state~='migrating'then break end end
 end
 assert(manager:isComplete(),'Real asset-manager migration failed: '..tostring(manager.error))
 assert(mod.cache:read('dex_assets/complete.txt')=='zip:1.1.0','Unexpected manager completion receipt')
 return {complete=true,method='Real asset-manager catalog-verified legacy migration of downloaded pack',
  files=manager.legacyCount,marker=mod.cache:read('dex_assets/complete.txt'),receipt_root=receiptRoot,
  scope='Isolated fixture only; no user cache writes, no network/UI download claim.'}
end
