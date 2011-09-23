

type Canvas.surface = external
type Canvas.ctx = external

size=500.
@server
s = (%% Cairo.create_surface %%)(Int.of_float(size),Int.of_float(size)) 
c = (%% Cairo.create %%)(s)
f(size,co,x1,y1,x2,y2) =
  fl(i)=Float.of_int(i) / 255.
  do (%% Cairo.set_stroke_style_color %%)(c,fl(co.r),fl(co.g),fl(co.b))
  do (%% Cairo.set_line_width %%)(c,size)
  do (%% Cairo.draw %%)(c,x1,y1,x2,y2)
  void


r = parser
  | "/img.png" -> _-> Resource.dyn_image({png=(%% Cairo.to_data %%)(s)})
  | "/" -> _-> Resource.page("img",<img src="img.png" />)

server = Server.make(r)

color_random()=
  r()=Random.int(255)
  {r=r() g=r() b=r() a=255}

_ = Scheduler.timer(100, ->
    rand() = Random.float(size)
    
    f(Random.float(50.),color_random(),rand(),rand(),rand(),rand()))
