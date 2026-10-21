-- Release-index refresh with owner pinning and checksummed offline slots.
return function(mod,backend,packSchema,seed)
 local self={index=seed,status='idle',error=nil,handle=nil}
 local repository=seed.repository
 local function valid(index)
  if type(index)~='table'or index.schema_version~=1 or type(index.packs)~='table'or #index.packs>512 then return nil,'Invalid release index'end
  if not repository and #index.packs>0 then return nil,'No trusted release repository configured'end
  if repository and index.repository~=repository then return nil,'Release index repository mismatch'end
  if seed.version and backend.compareVersions then
   local order=backend.compareVersions(index.version,seed.version)
   if not order or order<0 then return nil,'Release index is older than the bundled catalog'end
  end
  local ids={}
  for _,pack in ipairs(index.packs)do
   local ok,err=packSchema.validate(pack);if not ok then return nil,err end
   ok,err=backend.compatible(pack);if not ok then return nil,err end
   if ids[pack.id]then return nil,'Duplicate release pack ID'end;ids[pack.id]=true
   if repository then
    for _,file in ipairs(pack.files)do if not packSchema.assetUrl(file.url,repository) then return nil,'Pack URL repository mismatch'end end
   end
  end
  return true
 end
 local function cached(slot)
  local bytes=backend.read('asset-index-'..slot..'.json');if not bytes then return end
  local ok,envelope=pcall(backend.decode,bytes)
  if not ok or type(envelope)~='table'or type(envelope.body)~='string'or backend.hash(envelope.body)~=envelope.sha256 then return end
  local decoded,index=pcall(backend.decode,envelope.body)
  if decoded and valid(index)and type(envelope.sequence)=='number'and envelope.sequence>=1 and envelope.sequence%1==0 then return index,envelope.sequence end
 end
 local first,a=cached(1);local second,b=cached(2)
 local newer=first and second and backend.compareVersions and backend.compareVersions(first.version,second.version)
 if first and(not second or newer and newer>0 or (not newer or newer==0)and a>b)then self.index,self.sequence=first,a
 elseif second then self.index,self.sequence=second,b else self.sequence=0 end
 function self:check()
  if self.handle then return nil,'An index update is already running'end
  if type(repository)~='string'or not repository:match('^[%w_.-]+/[%w_.-]+$')then return nil,'No published repository configured'end
  local url='https://github.com/'..repository..'/releases/latest/download/asset-index.json'
  local handle,err=backend.get(url)
  if not handle then self.error=tostring(err);return nil,self.error end
  self.handle,self.status,self.error=handle,'checking',nil;return true
 end
 function self:update()
  if not self.handle then return end
  local result=backend.poll(self.handle);if result.status=='pending'then return end
  backend.release(self.handle);self.handle=nil
  local function fail(message)self.status,self.error='error',tostring(message)end
  if result.status~='ok'then return fail(result.err or result.status)end
  if type(result.body)~='string'or #result.body>4*1024*1024 then return fail('Release index exceeds size limit')end
  local ok,index=pcall(backend.decode,result.body)
  if not ok then return fail('Release index is not valid JSON')end
  local accepted,err=valid(index);if not accepted then return fail(err)end
  if self.index.version and backend.compareVersions then
   local order=backend.compareVersions(index.version,self.index.version)
   if not order or order<0 then return fail('Release index would downgrade the current catalog')end
  end
  local sequence=self.sequence+1;local slot=sequence%2+1
  local envelope={body=result.body,sha256=backend.hash(result.body),sequence=sequence}
  local written,why=backend.write('asset-index-'..slot..'.json',backend.encode(envelope))
  if not written then return fail(why)end
  local readback,number=cached(slot)
  if not readback or number~=sequence then return fail('Release index cache could not be verified')end
  self.index,self.sequence,self.status,self.error=readback,sequence,'updated',nil
 end
 function self:cancel()
  if self.handle then backend.cancel(self.handle);backend.release(self.handle);self.handle=nil end
  self.status='cancelled'
 end
 return self
end
