

##extern-type Canvas.surface = Cairo.image_surface
##extern-type Canvas.ctx = Cairo.t

##register create_surface : int, int -> Canvas.surface
let create_surface width height =
  Cairo.image_surface_create Cairo.FORMAT_ARGB32 ~width ~height
  

##register create : Canvas.surface -> Canvas.ctx
let create surface =
  let ctx = Cairo.create surface in
  Cairo.set_line_width ctx 4. ;
  Cairo.set_line_join ctx Cairo.LINE_JOIN_ROUND ;
  Cairo.set_line_cap ctx Cairo.LINE_CAP_ROUND ;
  ctx 

##register save : Canvas.ctx -> void
let save ctx = Cairo.save(ctx)
  
##register restore : Canvas.ctx -> void
let restore ctx = Cairo.save(ctx)

##register to_data : Canvas.surface -> string
let to_data surface =
  let b = Buffer.create 10000 in
  Cairo_png.surface_write_to_stream surface (Buffer.add_string b);
  Buffer.contents b

##register draw : Canvas.ctx, float, float, float, float -> void
let draw ctx x1 y1 x2 y2=
  Cairo.move_to ctx x1 y1;
  Cairo.line_to ctx x2 y2;
  Cairo.close_path ctx ;
  Cairo.stroke ctx
      
(* Tranformations (default transform is the identity matrix) *)

##register scale: Canvas.ctx, float, float -> void
let scale c sx sy = Cairo.scale c ~sx ~sy

##register rotate: Canvas.ctx, float -> void
let rotate c angle = Cairo.rotate c ~angle

##register translate: Canvas.ctx, float, float -> void
let translate c tx ty = Cairo.translate c ~tx ~ty

(* ##register transform: Canvas.ctx, int, int, int, int, int, int -> void *)
(* let transform c xx xy yx yy x0 x0 = Cairo.transform c m *)

(* ##register set_transform: Canvas.ctx, int, int, int, int, int, int -> void *)

(* // compositing *)
(* ##register set_global_alpha: Canvas.ctx, float -> void *)

(* ##register get_global_alpha: Canvas.ctx -> float *)

(* colors and styles *)

  ##register set_stroke_style_color: Canvas.ctx, float, float, float -> void
let set_stroke_style_color c red green blue =
  Cairo.set_source_rgb c ~red ~green ~blue
  

(* ##register set_stroke_style_gradient: Canvas.ctx, Canvas.gradient -> void *)

(* ##register set_stroke_style_pattern: Canvas.ctx, Canvas.pattern -> void *)

(* ##register set_fill_style_color: Canvas.ctx, string -> void *)

(* ##register set_fill_style_gradient: Canvas.ctx, Canvas.gradient -> void *)

(* ##register set_fill_style_pattern: Canvas.ctx, Canvas.pattern -> void *)

(* ##register get_stroke_style: Canvas.ctx -> opa[Canvas.style] *)

(* ##register get_fill_style: Canvas.ctx -> opa[Canvas.style] *)

(* //Gradient *)

(* ##register add_color_stop: Canvas.gradient, float, string -> void *)

(* ##register create_linear_gradient: Canvas.ctx, int, int, int, int -> Canvas.gradient *)

(* ##register create_radial_gradient : Canvas.ctx, int, int, int, int, int, int -> Canvas.gradient *)

(* //pattern *)

(* ##register create_pattern_i \ bslcanvas_create_pattern : Canvas.ctx, Image.image, string -> Canvas.pattern *)
(* ##register create_pattern_v \ bslcanvas_create_pattern : Canvas.ctx, Video.video, string -> Canvas.pattern *)
(* ##register create_pattern_c \ bslcanvas_create_pattern : Canvas.ctx, Canvas.canvas, string -> Canvas.pattern *)
(* function bslcanvas_create_pattern(ctx, image, repeat) *)
(* { *)
(*     ctx.createPattern(image, repeat) *)
(* } *)

(* // line caps/joins *)
(* ##register get_line_width: Canvas.ctx -> float *)
(* ##args(ctx) *)
(* { *)
(*     return ctx.lineWidth *)
(* } *)

##register set_line_width \ `Cairo.set_line_width` : Canvas.ctx, float -> void

(*     ctx.lineWidth = size *)
(* } *)

(* ##register set_line_cap: Canvas.ctx, string -> void *)
(* ##args(ctx, cap) *)
(* { *)
(*     ctx.lineCap = cap *)
(* } *)

(* ##register get_line_cap: Canvas.ctx -> string *)
(* ##args(ctx) *)
(* { *)
(*     return ctx.lineCap *)
(* } *)

(* ##register set_line_join: Canvas.ctx, string -> void *)
(* ##args(ctx, join) *)
(* { *)
(*     ctx.lineJoin = join *)
(* } *)

(* ##register get_line_join: Canvas.ctx -> string *)
(* ##args(ctx) *)
(* { *)
(*     return ctx.lineJoin *)
(* } *)

(* ##register set_miter_limit: Canvas.ctx, float -> void *)
(* ##args(ctx, limit) *)
(* { *)
(*     ctx.miterLimit = limit *)
(* } *)

(* ##register get_miter_limit: Canvas.ctx -> float *)
(* ##args(ctx) *)
(* { *)
(*     return ctx.miterLimit *)
(* } *)
(* // shadows *)

(* ##register set_shadow_color: Canvas.ctx, string -> void *)
(* ##args(ctx,color) *)
(* { *)
(*     ctx.shadowColor=color *)
(* } *)

(* ##register get_shadow_color: Canvas.ctx ->  string *)
(* ##args(ctx) *)
(* { *)
(*     return ctx.shadowColor *)
(* } *)

(* ##register set_shadow_offset_x: Canvas.ctx, int -> void *)
(* ##args(ctx,offset) *)
(* { *)
(*     ctx.shadowOffsetX=offset *)
(* } *)

(* ##register get_shadow_offset_x: Canvas.ctx ->  int *)
(* ##args(ctx) *)
(* { *)
(*     return ctx.shadowOffsetX *)
(* } *)

(* ##register set_shadow_offset_y: Canvas.ctx, int -> void *)
(* ##args(ctx,offset) *)
(* { *)
(*     ctx.shadowOffsetY=offset *)
(* } *)

(* ##register get_shadow_offset_y: Canvas.ctx ->  int *)
(* ##args(ctx) *)
(* { *)
(*     return ctx.shadowOffsetY *)
(* } *)

(* ##register set_shadow_blur: Canvas.ctx, int -> void *)
(* ##args(ctx,blur) *)
(* { *)
(*     ctx.shadowBlur=blur *)
(* } *)

(* ##register get_shadow_blur: Canvas.ctx ->  int *)
(* ##args(ctx) *)
(* { *)
(*     return ctx.shadowBlur *)
(* } *)

(* // rects *)
(* ##register clear_rect: Canvas.ctx, int ,int, int, int -> void *)
(* ##args(ctx,x,y,w,h) *)
(* { *)
(*     ctx.clearRect(x, y, w, h) *)
(* } *)

(* ##register fill_rect: Canvas.ctx, int ,int, int, int -> void *)
(* ##args(ctx,x,y,w,h) *)
(* { *)
(*     ctx.fillRect(x, y, w, h) *)
(* } *)

(* ##register stroke_rect: Canvas.ctx, int ,int, int, int -> void *)
(* ##args(ctx,x,y,w,h) *)
(* { *)
(*     ctx.strokeRect(x, y, w, h) *)
(* } *)

(* // path API *)
(* ##register begin_path: Canvas.ctx -> void *)
(* ##args(ctx) *)
(* { *)
(*     ctx.beginPath() *)
(* } *)


(* ##register close_path: Canvas.ctx -> void *)
(* ##args(ctx) *)
(* { *)
(*     ctx.closePath() *)
(* } *)

(* ##register move_to: Canvas.ctx, int, int -> void *)
(* ##args(ctx, x, y) *)
(* { *)
(*     ctx.moveTo(x, y) *)
(* } *)

(* ##register line_to: Canvas.ctx, int, int -> void *)
(* ##args(ctx, x, y) *)
(* { *)
(*     ctx.lineTo(x, y) *)
(* } *)

(* ##register quadratic_curve_to: Canvas.ctx, int, int, int, int -> void *)
(* ##args(ctx, cpx, cpy, x, y) *)
(* { *)
(*     ctx.quadraticCurveTo(cpx, cpy, x, y) *)
(* } *)

(* ##register bezier_curve_to: Canvas.ctx, int, int, int, int, int, int -> void *)
(* ##args(ctx, cp1x, cp1y, cp2x, cp2y, x, y) *)
(* { *)
(*     ctx.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, x, y) *)
(* } *)

(* ##register arc_to: Canvas.ctx, int, int, int, int, int -> void *)
(* ##args(ctx, x1, y1, x2, y2, radius) *)
(* { *)
(*     ctx.arcTo( x1, y1, x2, y2, radius) *)
(* } *)

(* ##register rect: Canvas.ctx, int, int, int, int -> void *)
(* ##args(ctx, x, y, w, h) *)
(* { *)
(*     ctx.rect( x, y, w, h) *)
(* } *)

(* // ##register arc: Canvas.ctx, int, int, int, int -> void *)
(* // ##args(ctx, x, y, w, h) *)
(* // { *)
(* //     ctx.rect( x, y, w, h) *)
(* // } *)

(* ##register fill: Canvas.ctx -> void *)
(* ##args(ctx) *)
(* { *)
(*     ctx.fill() *)
(* } *)

(* ##register stroke: Canvas.ctx -> void *)
(* ##args(ctx) *)
(* { *)
(*     ctx.stroke() *)
(* } *)

(* ##register clip: Canvas.ctx -> void *)
(* ##args(ctx) *)
(* { *)
(*     ctx.clip() *)
(* } *)

(* ##register is_point_in_path : Canvas.ctx, int, int -> bool *)
(* ##args(ctx, x, y) *)
(* { *)
(*     return ctx.isPointInPath(x, y) *)
(* } *)

(* // focus management *)
(* //todo *)

(* // text *)
(* //todo *)

(* // drawing images *)

(* ##register create_image : string -> Image.image *)
(* ##args(data) *)
(* { *)
(*   var img = new Image(); *)
(*   img.src = data; *)
(*   return img *)
(* } *)

(* ##register draw_image_i \ bslcanvas_draw_image: Canvas.ctx, Image.image, int, int -> void *)
(* ##register draw_image_c \ bslcanvas_draw_image: Canvas.ctx, Canvas.canvas, int, int -> void *)
(* ##register draw_image_v \ bslcanvas_draw_image: Canvas.ctx, Video.video, int, int -> void *)
(* function bslcanvas_draw_image(ctx, image, x, y) *)
(* { *)
(*     return ctx.drawImage(image, x ,y) *)
(* } *)

(* ##register draw_image_di \ bslcanvas_draw_image_d: Canvas.ctx, Image.image, int, int, int, int -> void *)
(* ##register draw_image_dc \ bslcanvas_draw_image_d: Canvas.ctx, Canvas.canvas, int, int, int, int -> void *)
(* ##register draw_image_dv \ bslcanvas_draw_image_d: Canvas.ctx, Video.video, int, int, int, int -> void *)
(* function bslcanvas_draw_image_d(ctx, image, x, y, w, h) *)
(* { *)
(*     return ctx.drawImage(image, x ,y, w ,h) *)
(* } *)

(* ##register draw_image_fi \ bslcanvas_draw_image_f: Canvas.ctx, Image.image, int, int, int, int, int, int, int, int -> void *)
(* ##register draw_image_fc \ bslcanvas_draw_image_f: Canvas.ctx, Canvas.canvas, int, int, int, int, int, int, int, int -> void *)
(* ##register draw_image_fv \ bslcanvas_draw_image_f: Canvas.ctx, Video.video, int, int, int, int, int, int, int, int -> void *)
(* function bslcanvas_draw_image_f(ctx, image, sx, sy, sw, sh, dx, dy, dw, dh) *)
(* { *)
(*     return ctx.drawImage(image, sx, sy, sw, sh, dx, dy, dw, dh) *)
(* } *)

(* // pixel manipulation *)

(* ##register put_image_data: Canvas.ctx, Image.data, int, int -> void *)
(* ##args(ctx, data, x, y) *)
(* { *)
(*     ctx.putImageData(data, x ,y) *)
(* } *)

(* //other *)


(* ##register get_image : Dom.private.element -> opa[option(Image.image)] *)
(* ##args(dom) *)
(* { *)
(*     if (dom && dom[0] && (dom[0].tagName.toLowerCase() == "img") && dom[0].complete){ *)
(*         return js_some(dom[0]) *)
(*     } *)
(*     return js_none *)
(* } *)
