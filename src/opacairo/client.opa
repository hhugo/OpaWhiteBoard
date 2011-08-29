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

import stdlib.widgets.core
import stdlib.components.chat
import stdlib.web.mail

/*
 * Create a client session to send new line to the server
 * Special session implem to decrease the amount of request
 * This will send messages to the server a most every 250 ms
 */
@client
atoms_sess : channel(list(line))=SessionBuffer.make_send_to(Session.make_callback(l -> NetworkBuffer.broadcast(l,atoms_network)),250)

/*
 * Send a line to the server
 */
@client
send_line(p1, p2, color : Color.color, size : int) : void =
  Session.send(atoms_sess,[(p1, p2, color, size)])

@client
_ = Session.send(dist,{new})

@client
info = 
  Session.make_callback((nb : int,dist: int) -> Dom.transform([
   #nb_user <- nb,
   #distance <- dist]))
@client
_ = Network.add(info, count_client_distance)
@client
_ =  Scheduler.push(-> remove(info))

@server @publish
remove(x)=Session.on_remove(x, -> Session.send(dist,{rem}))


/*
 * Draw a line into the canvas
 */
@client
draw_line(ctx, p1, p2, color : Color.color, size : int) : void =
  do Canvas.begin_path(ctx);
  do Canvas.set_line_width(ctx, Int.to_float(size))
  do Canvas.set_stroke_style(ctx, {~color})
  do Canvas.move_to(ctx,p1.x_px,p1.y_px)
  do Canvas.line_to(ctx,p2.x_px,p2.y_px)
  do Canvas.stroke(ctx)
  Canvas.close_path(ctx)

/*
 * Initialize the client when ready
 */
@client
initialize_client(atoms) =
  id = Random.string(10)
  //get canvas
  match Canvas.get(#canvas) with
    | {some=canvas} ->
      //get context
      match Canvas.get_context_2d(canvas) with
        | {some=ctx} ->
          //set canvas style
          do Canvas.set_line_cap(ctx, {round})

          //Session store canvas state
          dispatch((pos,color,size), msg ) =
            match msg with
                 | {~set_size} -> {set=(pos,color,set_size)}  //change cursor size
                 | {~set_color} -> {set=(pos,set_color,size)} //change color
                 | {~set_pos} -> {set=(set_pos,color,size)}   //change positon
                 | {~move} ->                                 //move to the new positon
                   do Log.info("change_size","{size}")
                   do draw_line(ctx, pos,move,color,size)
                   do send_line(pos,move,color,size)
                   {set=(move,color,size)}
                 | {line=(p1,p2,color,size)} ->               //draw a line
                   do draw_line(ctx, p1, p2, color, size)
                   {unchanged}
            end
          slider_size = 5
          treat_msg   = Session.make(({x_px=0 y_px=0},Color.black,slider_size), dispatch)
          treat_atoms =  Session.make_callback( atoms -> List.iter(atom -> Session.send(treat_msg,{line=atom}),List.rev(atoms)))
          // add drawing tools
          // color picker
          style_colorpick ={ thumb = WStyler.make_class(["cp_thumb"])
                           thumb_dragged = WStyler.make_class(["cp_thumb_dragged"])
                           thumb_over = WStyler.make_class(["cp_thumb_over"])
                           gauge = WStyler.make_class(["cp_gauge"])
                           cursor = WStyler.make_class(["cp_cursor"])
                           preview = WStyler.make_class(["cp_preview"])
                         }
          config_colorpicker = {WColorpicker.default_config with style=style_colorpick size = (256,256) on_select= c -> Session.send(treat_msg, {set_color=c}) display = {full}}
          colorpicker = WColorpicker.html("{id}_color", config_colorpicker)

          //slider
          style_slider = { thumb = WStyler.make_class(["thumb"])
                           thumb_dragged = WStyler.make_class(["thumb_dragged"])
                           thumb_over = WStyler.make_class(["thumb_over"])
                           gauge = WStyler.make_class(["gauge"])
                         }
          change_size(set_size) = do Log.info("change_size","{set_size}") Session.send(treat_msg, {~set_size})
          config_slider = { style=style_slider on_change=change_size on_release=change_size range=(1,50) init=5 step=2}
          slider = WSlider.html(config_slider, "{id}_size")

          //insert drawing tools to the page
          drawing_tools = <><h4>Cursor size</h4>{slider}<h4>Color</h4>{colorpicker}</>
          _ = Dom.put_inside(#drawing_tools,Dom.of_xhtml(drawing_tools))

          //load the initial image if any
          do match Canvas.get_image(#initial_image) with
            | {some=img} -> do Canvas.draw_image(ctx, img, 0, 0)
                            Dom.hide(#initial_image)
            | {none} ->  Log.debug("draw image","empty")
          //apply patches if any
          do Session.send(treat_atoms, atoms)
          //register session to reveive updates
          do NetworkBuffer.add(treat_atoms,atoms_network)
          //Initial state
          do Session.send(treat_msg, {set_size=slider_size})
          do Session.send(treat_msg, {set_color=Color.darkblue})

          //function call when drawing
          start_drawing(ev)=
            set_pos = Dom.Dimension.sub(ev.mouse_position_on_page,Dom.get_offset(#canvas))
            do Session.send(treat_msg, {~set_pos})
            do Session.send(treat_msg, {move=Dom.Dimension.add(set_pos,{x_px=1;y_px=0})}) // this is a hack to draw point with some browser
            do Session.send(treat_msg, {~set_pos})
            draw(ev) =
              move = Dom.Dimension.sub(ev.mouse_position_on_page,Dom.get_offset(#canvas))
              Session.send(treat_msg,{~move})
            _ = Dom.bind(#canvas,{mousemove}, draw)
            void
          _ = Dom.bind(Dom.select_all(),{mouseup}, ( _ -> Dom.unbind_event(#canvas,{mousemove})))
          _ = Dom.bind(#canvas,{mousedown},start_drawing)
          void
        | {none} -> Log.debug("context","error")
      end
    | {none} -> Log.debug("canvas","error")
  end

/*
 * Main page
 */

main() =
  atoms=[]
  //chat creation
  chat=
    id = Random.string(8)
    config = CChat.default_config(id)
    initial_content = default_chat.requester({ range = (0, config.history_limit) })
    initial_display = {CChat.default_display(id, Random.string(8)) with reverse=false}
    CChat.create(config, default_chat, id, initial_display, initial_content, (_,_ -> void ) )

  //main content
  <>
    <div id="container">
      <div id="header">
        <div id="logo">
	   <p>This is a demo application of the open source Opa technology.
           <br />
Head to <a href="http://opalang.org">http://opalang.org</a> to learn how to program real-time, distributed, web applications.</p>
	</div>
      </div>
      <div id="content">
        <div id="canvas_wrapper" width="{canvas_width}" height="{canvas_height}" >
          <canvas id="canvas"  width="{canvas_width}" height="{canvas_height}"></canvas>
          <img id="initial_image" width="{canvas_width}" height="{canvas_height}" onready={_ -> Scheduler.sleep(1000,->initialize_client(atoms))} src="img.png" />
        </div>
        <div id="drawing_tools" />
      </div>
      <div id="chat">
        <h4>Chat</h4>
        {chat}
      </div>
      <div id="sendit">
        Send this masterpiece at
        <input type="text" id="myemail" placeholder="your email here" />
        <input type="button" onclick={sendit} value="send it"/>
        <span id="sent"></span>
      </div>
      <div id="stats">
        <p> users: <span id=#nb_user /></p>
        <p> distance: <span id=#distance /></p>
      </div>
      <div class="source">Get the sources and fork on <a href="https://github.com/hhugo/OpaWhiteBoard">Github</a></div>
    </div>
  </>


/*
 * Send image by email
 */

@client
sendit(_)=
  match Canvas.get(#canvas) with
    | {some=canvas} ->
      email = Dom.get_value(#myemail)
      img = Canvas.to_data_url_png(canvas)
      match Email.of_string_opt(email) with
      | {some=email} ->
        match img with
          | {some=img} ->
            _ = Dom.put_inside(#sent,Dom.of_xhtml(<>Sending Email... !</>))
            do Dom.set_value(#myemail,"")
            do Scheduler.sleep(2000,(-> _ = Dom.put_inside(#sent,Dom.of_xhtml(<></>)) void))
            sendit_server(email,img)
          | _ ->
            _ = Dom.put_inside(#sent,Dom.of_xhtml(<>Your browser seams too old !</>))
            _ = Scheduler.sleep(2000,(-> _ = Dom.put_inside(#sent,Dom.of_xhtml(<></>)) void))
            void
        end
      | {none} ->
        _ = Dom.put_inside(#sent,Dom.of_xhtml(<>Bad email address !</>))
        _ = Scheduler.sleep(2000,(-> _ = Dom.put_inside(#sent,Dom.of_xhtml(<></>)) void))
        void
      end
    | _ -> void
  end


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
