-- Transactional, resumable file packs. Backend owns HTTP, hashing and storage.
-- Two checksummed commit slots preserve the previous installation on torn writes.
local M = {schema = 1}
local function token(s)
 return type(s) == 'string' and #s > 0 and #s <= 100 and s:match('^[%w_-][%w_.-]*$') and not s:find('..', 1, true)
end
local function path(s)
 if type(s) ~= 'string' or #s == 0 or #s > 240 or s:find('[^%w_./-]') or s:sub(1,1) == '/' then return false end
 for part in (s..'/'):gmatch('(.-)/') do if not token(part) then return false end end
 return true
end
local function digest(s) return type(s) == 'string' and #s == 64 and s:match('^[a-f0-9]+$') end
-- New catalogs pin source downloads to an immutable Git commit. Keep release
-- URLs readable so installations from older catalogs remain repairable.
function M.assetUrl(url,repository)
 if type(url)~='string' then return false end
 local owner,repo=url:match('^https://github%.com/([%w_.-]+)/([%w_.-]+)/releases/download/[^/]+/[^/]+$')
 if not owner then
  local commit,relative
  owner,repo,commit,relative=url:match('^https://raw%.githubusercontent%.com/([%w_.-]+)/([%w_.-]+)/([a-f0-9]+)/(.+)$')
  if not owner or #commit~=40 or not path(relative) then return false end
 end
 return not repository or owner..'/'..repo==repository
end
function M.validate(pack)
 if type(pack) ~= 'table' or pack.schema_version ~= 1 or pack.metadata_schema ~= 1 then return nil, 'Unsupported pack or perspective schema' end
 if not token(pack.id) or not token(pack.version) then return nil, 'Invalid pack identity' end
 if type(pack.files) ~= 'table' or #pack.files == 0 or #pack.files > 4096 then return nil, 'Invalid file count' end
 if type(pack.aspects) ~= 'table' or #pack.aspects == 0 or type(pack.environments) ~= 'table' or #pack.environments == 0 then return nil, 'Missing pack coverage' end
 if pack.quality ~= 'Mobile' and pack.quality ~= 'HD' and pack.quality ~= 'Ultra-HD' then return nil, 'Invalid quality tier' end
 local seen, total = {}, 0
 for _, f in ipairs(pack.files) do
  if type(f) ~= 'table' then return nil, 'Invalid file entry' end
  if not path(f.path) or seen[f.path] or not digest(f.sha256) then return nil, 'Invalid or duplicate asset path/checksum' end
  if type(f.size) ~= 'number' or f.size < 1 or f.size % 1 ~= 0 or f.size > 64*1024*1024 then return nil, 'Asset exceeds cache file limit' end
  if not M.assetUrl(f.url) then return nil, 'Asset URL must name an immutable GitHub source file or release download' end
  seen[f.path], total = true, total + f.size
 end
 if pack.installed_size ~= total then return nil, 'Installed size does not match file manifest' end
 return true
end
function M.new(b)
 local self = {status = 'idle', progress = 0}
 local function decode(bytes)
  if type(bytes) ~= 'string' then return nil end
  local ok, value = pcall(b.decode, bytes); if ok and type(value) == 'table' then return value end
 end
 local function slot(id, n) return 'packs/'..id..'/commit-'..n..'.json' end
 local function object(pack, f) return 'packs/'..pack.id..'/'..pack.version..'/'..f.sha256..'/'..f.path end
 local function record(id, n)
  local envelope = decode(b.read(slot(id,n)))
  if not envelope or type(envelope.body) ~= 'string' or b.hash(envelope.body) ~= envelope.sha256 then return nil end
  local r = decode(envelope.body)
  if not r or type(r.sequence) ~= 'number' or r.sequence < 1 or r.sequence % 1 ~= 0 then return nil end
  if r.pack and (not M.validate(r.pack) or r.pack.id ~= id) then return nil end
  if r.pack and not b.compatible(r.pack)then return nil end
  return r
 end
 local function latest(id)
  local a, c = record(id,1), record(id,2)
  if a and (not c or a.sequence > c.sequence) then return a end
  return c
 end
 local function commit(id, pack)
  local old = latest(id); local seq = (old and old.sequence or 0) + 1
  local body = b.encode({sequence=seq, pack=pack})
  local envelope = b.encode({body=body,sha256=b.hash(body)})
  local n = seq % 2 + 1
  local ok, err = b.write(slot(id,n), envelope)
  if not ok then return nil, err end
  local check = record(id,n)
  if not check or check.sequence ~= seq then return nil, 'Pack commit could not be read back' end
  return true
 end
 function self:installed(id)
  if not token(id) then return nil, 'Invalid pack ID' end
  local r = latest(id); return r and r.pack
 end
 function self:read(pack, relative)
  for _,f in ipairs(pack.files) do if f.path == relative then return b.read(object(pack,f)) end end
  return nil, 'Asset is not declared by this pack'
 end
 function self:imagePath(pack, relative)
  for _,f in ipairs(pack.files) do if f.path == relative then return b.imagePath(object(pack,f)) end end
  return nil, 'Asset is not declared by this pack'
 end
 function self:verify(pack)
  local ok, err = M.validate(pack); if not ok then return nil, err end
  ok,err=b.compatible(pack);if not ok then return nil,err end
  for _,f in ipairs(pack.files) do
   local bytes = b.read(object(pack,f))
   if not bytes or #bytes ~= f.size or b.hash(bytes) ~= f.sha256 then return nil, 'Missing or corrupt asset: '..f.path end
  end
  return b.validate(pack, function(p) return self:read(pack,p) end)
 end
 local function fail(err)
  self.status, self.error = 'error', tostring(err)
  if self.handle then b.cancel(self.handle); b.release(self.handle); self.handle = nil end
  return nil, self.error
 end
 function self:start(pack)
  if self.status == 'downloading' then return nil, 'A pack is already downloading' end
  local ok, err = M.validate(pack); if not ok then return fail(err) end
  ok, err = b.compatible(pack); if not ok then return fail(err) end
  -- Copy at the boundary so callers cannot change what is being verified.
  self.pack = b.decode(b.encode(pack)); self.index, self.completed = 1, 0
  self.status, self.error, self.progress = 'downloading', nil, 0
  return true
 end
 function self:cancel()
  if self.handle then b.cancel(self.handle); b.release(self.handle); self.handle = nil end
  self.status = 'cancelled' -- verified staged objects remain resumable
 end
 function self:update()
  if self.status ~= 'downloading' then return end
  local pack, f = self.pack, self.pack.files[self.index]
  if not f then
   local ok, err = self:verify(pack); if not ok then return fail(err) end
   ok, err = commit(pack.id,pack); if not ok then return fail(err) end
   self.status, self.progress = 'installed', 1; return
  end
  if not self.handle then
   local bytes = b.read(object(pack,f))
   if bytes and #bytes == f.size and b.hash(bytes) == f.sha256 then
    self.completed, self.index = self.completed + f.size, self.index + 1
    self.progress = self.completed / pack.installed_size; return
   end
   local handle, err = b.get(f.url); if not handle then return fail(err) end
   self.handle = handle; return
  end
  local state = b.poll(self.handle)
  if state.status == 'pending' then return end
  b.release(self.handle); self.handle = nil
  if state.status ~= 'ok' then return fail(state.err or state.status) end
  local bytes = state.body
  if type(bytes) ~= 'string' or #bytes ~= f.size or b.hash(bytes) ~= f.sha256 then return fail('Download checksum/size mismatch: '..f.path) end
  local ok, err = b.write(object(pack,f),bytes); if not ok then return fail(err) end
  local saved = b.read(object(pack,f))
  if not saved or #saved ~= f.size or b.hash(saved) ~= f.sha256 then return fail('Asset write could not be verified: '..f.path) end
  self.completed, self.index = self.completed + f.size, self.index + 1
  self.progress = self.completed / pack.installed_size
 end
 function self:remove(id)
  if self.status == 'downloading' then return nil, 'Finish or cancel the download first' end
  local pack = self:installed(id); if not pack then return nil, 'Pack is not installed' end
  local ok, err = commit(id,nil); if not ok then return nil, err end
  for _,f in ipairs(pack.files) do b.delete(object(pack,f)) end
  return true
 end
 return self
end
return M
