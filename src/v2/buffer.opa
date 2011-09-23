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

type Buffer.msg('a) = {add:'a} / {flush:(list('a) -> void)}

type Buffer.t('a) = Session.channel(Buffer.msg('a)) 

Buffer = {{
  make()=Session.make([],(lst,msg:Buffer.msg->
    match msg with
      | {~add} -> {set=[add|lst]}
      | {~flush} ->
        do flush(List.rev(lst))
        {set=[]}
    )
  )

  add(c,x) = Session.send(c,{add=x})

  flush(c,k) =
    Session.send(c,{flush=k})

}}
