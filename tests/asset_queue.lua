local starts={}
local store={status='idle',progress=0,start=function(self,pack)
 starts[#starts+1]=pack.id;self.status='downloading';return true
end,cancel=function(self)self.status='cancelled'end}
local queue=assert(loadfile(root..'/lib/asset_queue.lua'))()(store)
assert(not queue:start({}))
assert(queue:start({{id='wide'},{id='phone'},{id='phone'}}))
assert(#starts==1 and #queue.packs==2)
store.progress=.5;assert(queue:progress()==.25)
assert(not queue:start({{id='other'}}))
store.status='installed';queue:update();assert(starts[2]=='phone'and queue.position==2)
store.status='error';store.error='Network lost';queue:update()
assert(queue.status=='error'and queue.error=='Network lost'and #starts==2)
store.status='idle';assert(queue:start({{id='wide'}}))
store.status='installed';queue:update();assert(queue.status=='installed'and queue:progress()==1)
store.status='idle';assert(queue:start({{id='phone'}}));queue:cancel()
assert(queue.status=='cancelled'and store.status=='cancelled')
print('PASS batch queue: all-aspect sequential downloads, deduplication, progress, failure stop, restart and cancellation')
