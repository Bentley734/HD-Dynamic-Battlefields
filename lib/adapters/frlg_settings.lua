-- The Gen 3 OptionsMenu facade ignores custom rows. Adapt our descriptors to
-- FR/LG's own page stack and renderer instead of opening the Gen 1 screen.
return function()
 local Menu=require('src.ui.game3.option_menu')
 local Rows=require('src.ui.game3.option_rows')
 local function gameFor(ctx)
  local game=assert(ctx.game,'Missing native options context')
  return setmetatable({stack={pop=function()Menu.back()end}},
   {__index=game,__newindex=function(_,key,value)game[key]=value end})
 end
 local function convert(rows)
  local out={}
  for _,row in ipairs(rows)do
   local item={id=row.id,label=row.label,group=row.group}
   if row.value then item.value=function(ctx)return row.value(gameFor(ctx))end end
   if row.activate then item.activate=function(ctx)return row.activate(gameFor(ctx))end end
   if row.step then item.step=function(ctx,dir)return row.step(gameFor(ctx),dir)end end
   out[#out+1]=item
  end
  return out
 end
 local self={}
 function self.open(game,rows,title)
  assert(Menu.isOpen()and Menu._pages,'Open native OPTIONS before a battlefield page')
  Menu._pages[#Menu._pages+1]={title=title or'HD BATTLEFIELDS',rows=convert(rows),index=1,scroll=0}
  Menu.cursor=1
 end
 function self.mount(row)
  local build=Rows.build
  Rows.build=function(...)
   local rows=build(...);rows[#rows+1]=convert({row})[1];return rows
  end
 end
 return self
end
