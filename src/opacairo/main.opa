/*  Collaborative white board

    Copyright (C) 2010-2011  MLstate

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    @author Hugo Heuzard
*/


import stdlib.widgets.{slider,colorpicker}

/*
 * Type of line (from, to, color, size)
 */
type line = (Dom.Dimension.t, Dom.Dimension.t, Color.color, int)

type Canvas.surface = external
type Canvas.ctx = external

/*
 * Size of the board
 */
@both_implem
canvas_width = 600.
@both_implem
canvas_height = 450.

@server
surface = (%% Cairo.create_surface %%)(Int.of_float(canvas_width),Int.of_float(canvas_height)) 
context = (%% Cairo.create %%)(surface)



/*
 * Network to broadcast line.
 * Special Network Implem to decrease the among of request
 */
@server @publish
atoms_network : NetworkBuffer.network(line) = NetworkBuffer.empty(333)
@server @publish
count_client_distance : Network.network((int,int)) = Network.empty()
@server @publish
dist = Session.make((0,0), ((nb,dist),msg ->
  match msg with
    | {new} -> {set=(nb+1,dist)}
    | {dump} -> do Network.broadcast((nb,dist),count_client_distance) {unchanged}
    | {~add} -> {set=(nb,dist+add)}
    | {rem} -> {set=(nb-1,dist)}))

do Scheduler.timer(500,-> Session.send(dist,{dump}))

f(size,co,x1,y1,x2,y2) =
  dx = (x1-x2)
  dy = (y1-y2)
  d = Math.sqrt_f(Float.of_int(dx*dx + dy*dy))
  do Session.send(dist,{add=Int.of_float(d)})
  fl=Float.of_int
  flc(i)=fl(i) / 255.
  size=Float.of_int(size)
  do (%% Cairo.set_stroke_style_color %%)(context,flc(co.r),flc(co.g),flc(co.b))
  do (%% Cairo.set_line_width %%)(context,size)
  do (%% Cairo.draw %%)(context,fl(x1),fl(y1),fl(x2),fl(y2))
  void

ttt : channel(list(line)) = Session.make_callback(
    l ->
  List.iter((from,to,co,size) ->
    f(size,co,from.x_px,from.y_px,to.x_px,to.y_px),
    l))

do NetworkBuffer.add(ttt,atoms_network)

/*
 * Initialisation of chat component
 */
@server
default_chat = CChat.init(CChat.default_config(Random.string(10)))

/*
 * Main
 */
resources = @static_include_directory("resources")
rule_map = Rule.of_map(resources) : Parser.general_parser(resource)
urls = parser
  | "/" -> Resource.full_page("Play with Canvas",main(),<link rel="stylesheet" href="style.css" type="text/css"> </link>,{success}, [])
  | "/img.png" -> Resource.dyn_image({png=(%% Cairo.to_data %%)(surface)})
  | "/style.css" -> Resource.source(@static_content("resources/style.css")(),"text/css")
  | "/" r=rule_map -> r


server = Server.simple_server(urls)

@server
atoms_sess2 : channel(list(line)) = SessionBuffer.make_send_to(Session.make_callback(l -> NetworkBuffer.broadcast(l,atoms_network)),250)

// @server
// color_random()=
//   r()=Random.int(255)
//   {r=r() g=r() b=r() a=255}
// @server
// _ = Scheduler.timer(100, ->
//     rand(size) = Random.int(Int.of_float(size))
//     rand_dim() = {x_px=rand(canvas_width) y_px=rand(canvas_height)}
    
//     Session.send(atoms_sess2,[(rand_dim(), rand_dim(), color_random(), Random.int(50))]))
