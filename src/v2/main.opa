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
import hh.cairo
/*
 * Type of line (from, to, color, size)
 */
type line = (Dom.Dimension.t, Dom.Dimension.t, Color.color, int)
     
/*
 * Size of the board
 */
@both_implem
canvas_width = 600.
@both_implem
canvas_height = 450.

@server
surface = Cairo.create_surface(Int.of_float(canvas_width),Int.of_float(canvas_height)) 
context = Cairo.create(surface)

/*
 * Initialisation of chat component
 */
@server
default_chat = CChat.init(CChat.default_config(Random.string(10)))

/*
 * Main
 */
resources = @static_include_directory("resources")

urls = parser
  | "/" ->
    Resource.full_page(
      "Play with Canvas", main(),
      <link rel="stylesheet" href="style.css" type="text/css" />,{success}, [])
  | "/img.png" -> Resource.dyn_image(Cairo.to_png(surface))
  | "/style.css" -> Resource.source(@static_content("resources/style.css")(),"text/css")
  | "/" r=Rule.of_map(resources) -> r


server = Server.simple_server(urls)

@server @publish
lines_network : Network.network(list(line)) = Network.empty()
 
do Scheduler.timer(300,->
  Buffer.flush(server_flow,(l->
    if not(List.is_empty(l))
    then Network.broadcast(l,lines_network))
  ))     

@server_private
treat_msg(size,color,x1,y1,x2,y2) =
  dx = (x1-x2)
  dy = (y1-y2)
  d = Math.sqrt_f(Float.of_int(dx*dx + dy*dy))
  do Session.send(dist,{add=Int.of_float(d)})
  fl=Float.of_int
  size=Float.of_int(size)
  do Cairo.set_stroke_line(context,color)
  do Cairo.set_line_width(context,size)
  do Cairo.draw(context,fl(x1),fl(y1),fl(x2),fl(y2))
  void

@server
server_flow : Buffer.t(line) = Buffer.make()

@server @publish @async
drawing(actions) =
  List.iter((from,to,co,size) as line ->
    do Buffer.add(server_flow,line)
    treat_msg(size,co,from.x_px,from.y_px,to.x_px,to.y_px),
    actions)

@server @publish
register_to_server(info)=
  _ = Session.on_remove(info, ->
    do println("client disconnected")
    Session.send(dist,{rem}))
  _ = Session.send(dist,{new})
  _ = Network.add(info, metric_network)
  void

  @server @publish
sendit_server(email,img)=
      img = String.drop_left(22,img) //in order to drop "data:image/png;base64,"
      content =
        "Here is your masterpiece\n\nThanks"
      Email.try_send_with_files_async(
        Email.of_string("canvas@opalang.org"),
        email,
        "Piece of art",
        {text=content},
        [{filename="masterpiece.png" content=img encoding="base64" mime_type="image/png"}],
        (_ -> void) )

@server @publish
metric_network : Network.network((int,int)) = Network.empty()
@server @publish
dist = Session.make((0,0,false), ((nb,d,updt),msg ->
  match msg with
   | {new} ->
     {set=(nb+1,d,true)}
   | {dump} -> do if updt
                  then Network.broadcast((nb,d),metric_network)
               {set=(nb,d,false)}
   | {~add} -> {set=(nb,d+add,true)}
   | {rem} -> {set=(nb-1,d,false)}))

do Scheduler.timer(500,-> Session.send(dist,{dump}))
