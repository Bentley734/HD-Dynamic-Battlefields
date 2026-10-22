-- Reuse the native release bootstrap through an isolated test-only substitution.
local workspace=assert(os.getenv('HDB_WORKSPACE')):gsub('\\','/')
local project=workspace..'/HD-Dynamic-Battlefields'
local function read(path)local f=assert(io.open(path,'rb'));local b=f:read('*a');f:close();return b end
local source=read(project..'/tools/rse_native_probe/main.lua')
local a=assert(source:find("local output=project..'/docs/evidence/rse'",1,true))
local z=assert(source:find('local function read(path)',a,true))
source=source:sub(1,a-1).."local output=assert(os.getenv('HDB_FOOTING_OUTPUT')):gsub('\\\\','/')\n"..source:sub(z)
local old="assert(loadfile(project..'/tools/rse_native_probe/render.lua'))()"
local s=assert(source:find(old,1,true))
source=source:sub(1,s-1).."assert(loadfile(project..'/tools/dex_footing_probe/render.lua'))()"..source:sub(s+#old)
local rootSeam="local roots=assert(loadfile(project..'/tools/rse_native_probe/sources.lua'))()(workspace,project)"
local rootAt=assert(source:find(rootSeam,1,true))
source=source:sub(1,rootAt-1)..rootSeam.."\n  roots['1025dex-bw-sprites']=assert(os.getenv('HDB_BW_ROOT')):gsub('\\\\','/')\n  roots.kim1025=assert(os.getenv('HDB_KIM_ROOT')):gsub('\\\\','/')"..source:sub(rootAt+#rootSeam)
assert(loadstring(source,'@dex-footing-native-bootstrap'))()
