-- Sequential batch downloads retain pack-level transactions and resume data.
return function(store)
 local self={packs={},position=0,status='idle',error=nil}
 function self:start(packs)
  if self.status=='downloading' or store.status=='downloading' then return nil,'A download is already running' end
  if type(packs)~='table' or #packs==0 then return nil,'No matching published packs' end
  self.packs={};local seen={}
  for _,pack in ipairs(packs)do
   if not seen[pack.id] then self.packs[#self.packs+1]=pack;seen[pack.id]=true end
  end
  self.position,self.status,self.error=1,'downloading',nil
  local ok,err=store:start(self.packs[1])
  if not ok then self.status,self.error='error',err end
  return ok,err
 end
 -- Call after the owning integration has recorded the completed pack.
 function self:update()
  if self.status~='downloading' then return end
  if store.status=='error' or store.status=='cancelled' then
   self.status,self.error=store.status,store.error;return
  end
  if store.status~='installed' then return end
  self.position=self.position+1
  if self.position>#self.packs then self.status='installed';return end
  local ok,err=store:start(self.packs[self.position])
  if not ok then self.status,self.error='error',err end
 end
 function self:cancel()
  self.status='cancelled';store:cancel()
 end
 function self:progress()
  if self.status=='installed' then return 1 end
  if #self.packs==0 then return 0 end
  return math.min(1,((self.position-1)+(store.progress or 0))/#self.packs)
 end
 return self
end
