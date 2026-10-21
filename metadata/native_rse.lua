-- Native Hoenn presentation profiles, not background-specific coordinates.
-- Ruby/Sapphire's rs sprite layout omits the four-pixel FR/LG back offset.
-- Opponent mound centre sits six native pixels below the original pad centre.
-- This places the visible surface beneath the native front-sprite contact row;
-- Doubles raise the deeper shared pad two pixels for rear-slot footing.
-- sprites/HUD remain native. Expanded/hovering species still need review.
return {
 ruby={width=240,height=160,player={x=64,y=113,width=128,height=32},opponent={x=176,y=70,width=128,height=32},
  double={width=240,height=160,player={x=61,y=117,width=160,height=40},opponent={x=176,y=62,width=160,height=48}}},
 sapphire={width=240,height=160,player={x=64,y=113,width=128,height=32},opponent={x=176,y=70,width=128,height=32},
  double={width=240,height=160,player={x=61,y=117,width=160,height=40},opponent={x=176,y=62,width=160,height=48}}},
 emerald={width=240,height=160,player={x=64,y=117,width=128,height=32},opponent={x=176,y=70,width=128,height=32},
  double={width=240,height=160,player={x=61,y=121,width=160,height=40},opponent={x=176,y=62,width=160,height=48}}},
}
