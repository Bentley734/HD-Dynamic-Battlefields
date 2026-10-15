local G=assert(loadfile(root..'/lib/pixel_grid.lua'))()
for _,dpi in ipairs({1,1.5,2,2.75,3})do
 local physical,logical=G.zoom(2.16,dpi)
 assert(physical%1==0 and math.abs(logical*dpi-physical)<1e-9)
 local snapped=G.snap(37.123,dpi);assert(math.abs(snapped*dpi-math.floor(snapped*dpi+.5))<1e-9)
end
assert(not G.zoom(0,1));assert(not G.density({dpiY=0/0}))
print('PASS physical integer pixel scaling and alignment at densities 1/1.5/2/2.75/3')
