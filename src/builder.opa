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


/*
 * A builder is a client that cannot draw
 * it build the image by applying other client patches
 * it send the result to the server
 */


/*
 * Set the new state
 */
@server
set_state(url : string) = ignore(state.set(([],url)))


@client
initialize_builder(atoms) =
  match Canvas.get(#canvas) with
    | {some=canvas} ->
  match Canvas.get_context_2d(canvas) with
    | {some=ctx} ->
      do Canvas.set_line_cap(ctx, {round})
      // Session to apply patches
      dispatch(msg) =
        match msg with
          | {line=(p1,p2,color,size)} -> draw_line(ctx, p1, p2, color, size)
          | {dump} -> void
        end
      //load image if any
      do match Canvas.get_image(#initial_image) with
        | {some=img} -> Canvas.draw_image(ctx, img, 0, 0)
        | {none} ->  Log.debug("draw image","empty")
      treat_msg   = Session.make_callback(dispatch)
      treat_atoms = Session.make_callback(List.iter(line -> send(treat_msg,{~line}),_))
      do Session.send(treat_atoms, atoms)
      //schedule state sending
      do Scheduler.timer(1000, -> Option.iter(s -> do Log.debug("CB","set_state") set_state(s) ,Canvas.to_data_url_png(canvas)))
      NetworkBuffer.add(treat_atoms,atoms_network)
    | {none} -> Log.debug("context","error")
  end
    | {none} -> Log.debug("canvas","error")
  end



build() =
  (atoms,image) = get_state()
  cur_image =
    if image == ""
    then <div onready={_ -> initialize_builder(atoms)} style="display:none;"/>
    else <img id="initial_image" onready={_ -> initialize_builder(atoms)} style="display:none;" src="{image}"  />;
  <>
    <h1>Canvas builder</h1>
    <canvas id="canvas" width="{canvas_width}" height="{canvas_height}">
      <p>You cannot build this image since your browser is not compatible.</p>
      <p>Please change your browser</p>
    </canvas>
    {cur_image}
  </>
