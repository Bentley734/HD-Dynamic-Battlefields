-- Trusted standalone test-host helper, never loaded by the mod or exported
-- through its API. Resize the fixture's existing SDL window without resetting
-- the graphics mode (which clears cached canvases on this host).
return function()
 local ffi=require('ffi')
 ffi.cdef[[typedef struct SDL_Window SDL_Window;
 SDL_Window *SDL_GL_GetCurrentWindow(void);
 void SDL_SetWindowSize(SDL_Window *, int, int);]]
 local sdl=ffi.load('SDL2')
 local window=assert(sdl.SDL_GL_GetCurrentWindow(),'Missing fixture GL window')
 return function(w,h)
  sdl.SDL_SetWindowSize(window,w,h)
  love.event.pump()
  for name,a,b,c,d,e,f in love.event.poll()do
   if name~='quit'and love.handlers[name]then love.handlers[name](a,b,c,d,e,f)end
  end
 end
end
