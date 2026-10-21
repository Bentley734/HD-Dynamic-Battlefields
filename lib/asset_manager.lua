return function(mod,open,index,aspects)
 local api=mod.exports.assetPacks;local store=api.store
 local aspect='auto';local quality='HD';local variations='one'
 local function sizeLabel(bytes)
  if type(bytes)~='number'then return'--'end
  if bytes>=1000000000 then return string.format('%.2f GB',bytes/1000000000)end
  if bytes>=1000000 then return string.format('%.1f MB',bytes/1000000)end
  return string.format('%.1f KB',bytes/1000)
 end
 -- Native Gen1/2 treats A on a row without an action as BACK.
 local function info(id,label,value)return{id='hd_assets_'..id,label=label,value=value,activate=function()end}end
 local function action(id,label,fn)
  local message=''
  return{id='hd_assets_'..id,label=label,value=function()return message end,activate=function(game)
   local ok,err=fn(game);message=ok and'DONE'or tostring(err or'FAILED')
  end}
 end
 local function page(id,label,fn)return{id='hd_assets_'..id,label=label,group=true,value=function()return'OPEN'end,activate=fn}end
 local function choose(id,label,values,get,set)
  return info(id,label,function()local v=get();return v=='auto'and'AUTOMATIC'or v end),function(game)
   local rows={};for _,value in ipairs(values)do local item=value
    rows[#rows+1]={id='hd_assets_pick_'..id..item,label=item,activate=function(ctx)set(item);ctx.stack:pop()end}
   end;open(game,rows,label)
  end
 end
 local function details(game,pack)
  local rows={info('pack_version','VERSION',function()return pack.version end),
   info('pack_quality','QUALITY',function()return pack.quality end),
   info('pack_variations','VARIATIONS',function()return pack.variation_profile=='one'and'ONE PER AREA'or'ALL VARIATIONS'end),
   info('pack_bytes','INSTALLED SIZE',function()return sizeLabel(pack.installed_size)end),
   info('pack_health','PACK HEALTH',function()local state=api.library.health[pack.id];return state and(state.valid and'VERIFIED'or state.error)or'NOT INSTALLED'end),
   action('download','DOWNLOAD / RESTORE',function()return store:start(pack)end),
   action('verify','VERIFY INSTALLED',function()local installed=store:installed(pack.id);if not installed then return nil,'NOT INSTALLED'end;local ok,err=store:verify(installed);api.library.health[pack.id]={valid=ok==true,error=err};if not ok then api.refresh()end;return ok,err end),
   action('remove','REMOVE PACK',function()return api.remove(pack.id)end)}
  open(game,rows,'PACK DETAILS')
 end
 local function browse(game,installedOnly)
  local rows={};local source=installedOnly and api.library.packs or api.updates.index.packs
  local wanted=aspect
  if wanted=='auto'then local v=mod.exports.diagnostics().viewport
   if not v and love and love.graphics then local w,h=love.graphics.getDimensions();v={width=w,height=h}end
   if v then wanted=aspects.aspect(v.width,v.height)end
  end
  for _,pack in ipairs(source)do
   local matches=wanted=='auto';for _,family in ipairs(pack.aspects)do if family==wanted then matches=true end end
   if installedOnly or matches and pack.quality==quality and(pack.variation_profile or'all')==variations then
    local selected=pack
    rows[#rows+1]={id='hd_assets_pack_'..pack.id,label=(pack.aspects[1]or'?')..' / '..(pack.variation_profile=='one'and'COMPACT'or'FULL'),value=function()
     local installed=store:installed(selected.id)
     local health=api.library.health[selected.id]
     if installed and health and not health.valid then return'REPAIR NEEDED'end
     return installed and(installed.version==selected.version and'INSTALLED'or'UPDATE')or sizeLabel(selected.installed_size)
    end,activate=function(ctx)details(ctx,selected)end}
   end
  end
  if #rows==0 then rows[1]=info('none','NO MATCHING PACKS',function()return installedOnly and'NONE INSTALLED'or'NOT PUBLISHED YET'end)end
  open(game,rows,installedOnly and'INSTALLED PACKS'or'AVAILABLE DOWNLOADS');return true
 end
 local aspectValues={'auto'};for _,pair in ipairs(aspects.ratios)do aspectValues[#aspectValues+1]=pair[1]end
 local aspectRow,aspectActivate=choose('aspect','SCREEN SIZE',aspectValues,function()return aspect end,function(v)aspect=v end);aspectRow.activate=aspectActivate
 local qualities,seen={},{}
 for _,pack in ipairs(api.updates.index.packs)do if not seen[pack.quality]then qualities[#qualities+1]=pack.quality;seen[pack.quality]=true end end
 table.sort(qualities);if #qualities>0 and not seen[quality]then quality=qualities[1]end
 local qualityRow,qualityActivate=choose('quality','TEXTURE QUALITY',qualities,function()return quality end,function(v)quality=v end);qualityRow.activate=qualityActivate
 local variationRow,variationActivate=choose('variations','VARIATIONS',{'one','all'},function()return variations end,function(v)variations=v end);variationRow.activate=variationActivate
 variationRow.value=function()return variations=='one'and'ONE PER AREA'or'ALL VARIATIONS'end
 variationRow.activate=function(game)
  local rows={}
  for _,pair in ipairs({{'ONE VARIATION PER AREA','one'},{'ALL VARIATIONS','all'}})do
   local label,value=pair[1],pair[2]
   rows[#rows+1]={id='hd_assets_variations_'..value,label=label,activate=function(ctx)variations=value;ctx.stack:pop()end}
  end
  open(game,rows,'VARIATIONS')
 end
 local function downloadAll()
  local packs={}
  -- All screen sizes; honor the chosen quality and compact/full profile.
  for _,pack in ipairs(api.updates.index.packs)do
   if pack.quality==quality and (pack.variation_profile or'all')==variations then packs[#packs+1]=pack end
  end
  return api.queue:start(packs)
 end
 local progress=info('progress','DOWNLOAD STATUS',function()
  if api.queue and api.queue.status=='downloading'then return'PACK '..api.queue.position..'/'..#api.queue.packs..' '..math.floor(api.queue:progress()*100)..'%'end
  return store.status..' '..math.floor((store.progress or 0)*100)..'%'
 end)
 local errorRow=info('error','LAST ERROR',function()return api.queue and api.queue.error or store.error or api.library.error or'NONE'end)
 local tools={action('refresh','RESCAN INSTALLED PACKS',api.refresh)}
 if index.repository then
  tools[#tools+1]=action('updates','CHECK FOR UPDATES',function()return api.updates:check()end)
  tools[#tools+1]=info('update_status','UPDATE STATUS',function()return api.updates.error or api.updates.status end)
 end
 local rows={aspectRow,variationRow}
 -- Do not advertise empty quality tiers. They return when actually published.
 if #qualities>1 then rows[#rows+1]=qualityRow end
 rows[#rows+1]=page('browse','DOWNLOAD SELECTED SIZE',function(game)return browse(game,false)end)
 rows[#rows+1]=action('download_all','DOWNLOAD ALL SIZES',downloadAll)
 rows[#rows+1]=page('installed','MANAGE INSTALLED PACKS',function(game)return browse(game,true)end)
 progress.activate=function(game)
  open(game,{info('progress_detail','PROGRESS',progress.value),errorRow,
   action('cancel','CANCEL DOWNLOAD',function()if api.queue then api.queue:cancel()else store:cancel()end;return true end)},'DOWNLOAD STATUS')
 end
 rows[#rows+1]=progress
 rows[#rows+1]={id='hd_assets_tools',label='MAINTENANCE',group=true,value=function()return'OPEN'end,activate=function(game)open(game,tools,'MAINTENANCE')end}
 return{id='hd_group_assets',label='ASSET MANAGER',group=true,value=function()return'OPEN'end,activate=function(game)open(game,rows,'ASSET DOWNLOADER')end}
end
