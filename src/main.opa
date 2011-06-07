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


import widgets.{slider,colorpicker}

/*
 * Type of line (from, to, color, size)
 */
type line = (Dom.Dimension.t, Dom.Dimension.t, Color.color, int)

/*
 * Network to broadcast line.
 * Special Network Implem to decrease the among of request
 */
@server @publish
atoms_network : NetworkBuffer.network(line) = NetworkBuffer.empty(333)

/*
 * Internal state (list of line + image)
 * The image is build by applying patch to the previous image
 */
@server @publish
state = Mutable.make_server(([] : list(line) ,""))
@server
get_state() = state.get()

/*
 * Initialisation of chat component
 */
@server
default_chat = CChat.init(CChat.default_config(Random.string(10)))

/*
 * Size of the board
 */
@both_implem
canvas_width = 600
@both_implem
canvas_height = 450

/*
 * Main
 */
resources = @static_include_directory("resources")
rule_map = Rule.of_map(resources) : Parser.general_parser(resource)
urls = parser
  | "/" -> Resource.full_page("Play with Canvas",main(),<link rel="stylesheet" href="style.css" type="text/css"> </link>,{success}, [])
  | "/i_m_a_builder" -> html("Canvas builder", build())
  | "/style.css" -> Resource.source(@static_content("resources/style.css")(),"text/css")
  | "/" r=rule_map -> r


server = Server.simple_server(urls)


