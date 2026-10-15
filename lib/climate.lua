local M={}
local weather={clear=true,rain=true,snow=true,sandstorm=true,fog=true,sun=true}
local aliases={sunny='sun',sunlight='sun',harsh_sunlight='sun',sand='sandstorm',mist='fog',hail='snow'}
local function normalized(value)
 if type(value)~='string'then return nil end
 value=aliases[value]or value;return weather[value]and value or nil
end
function M.new(policy,wallTime,localHour)
 local self={cache={},hourAt=nil,hour=nil}
 function self:resolve(environment,timeMode,weatherMode,animation,context)
  context=context or{}
  local outdoor=policy[environment]and policy[environment].outdoor==true
  local source,period='manual',timeMode
  if period~='day'and period~='night'then
   period=nil
   if timeMode~='system'and(context.timeOfDay=='day'or context.timeOfDay=='night')then
    period,source=context.timeOfDay,'game'
   else
    local now=wallTime()
    if not self.hourAt or now<self.hourAt or now-self.hourAt>=60 then self.hour,self.hourAt=localHour(),now end
    period=(self.hour>=6 and self.hour<18)and'day'or'night';source='system'
   end
  end
  if not outdoor then period,source='day','interior'end
  local actual=weatherMode=='auto'and(normalized(context.battleWeather)or normalized(context.mapWeather)or'clear')or normalized(weatherMode)or'clear'
  if not outdoor then actual='clear'end
  local level=({off=0,low=1,medium=2,high=3})[animation]or 0
  local key=period..':'..source..':'..actual..':'..level
  if not self.cache[key]then
   -- Day/night is selected artwork, never a lighting tint.
   local tint={1,1,1,1}
   local multiplier=({rain={.76,.82,.92},snow={.87,.91,.98},sandstorm={.91,.81,.63},fog={.88,.92,.94},sun={1,.96,.82}})[actual]
   if multiplier then for i=1,3 do tint[i]=tint[i]*multiplier[i]end end
   self.cache[key]={period=period,timeSource=source,weather=actual,level=level,tint=tint}
  end
  return self.cache[key]
 end
 return self
end
return M
