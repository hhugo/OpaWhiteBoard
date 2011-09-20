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
 * Ugly implem of buffered session/netork
 */

type SessionBuffer.channel('msg) = channel(list('msg))

SessionBuffer = {{

  make(state : 'state ,treat_msg : ('state,'msg -> Session.instruction('state))) : SessionBuffer.channel('msg)=
    ns = Session.make(state : 'state,treat_msg)
    Session.make_callback(l -> List.iter(Session.send(ns,_),l))

  make_send_to(session : SessionBuffer.channel('msg) ,timer : int) =
    sess = Session.make([],(l,s ->
      match s with
         | {~add} -> {set=add++l}
         | {dump} -> if l == [] then {unchanged} else do Session.send(session,l) {set=[]} ))
    do Scheduler.timer(timer, ( -> Session.send(sess,{dump})))
    Session.make_callback( add -> Session.send(sess,{~add}))
}}

type NetworkBuffer.network('a) = channel(NetworkBuffer.instruction('a))

type NetworkBuffer.instruction('a) = {add: SessionBuffer.channel('a)} / {remove: SessionBuffer.channel('a)} / {broadcast: list('a)} / {dump}
NetworkBuffer = {{
  @publish
  empty(timer : int): NetworkBuffer.network('a) =
    Set = Set_make(Channel.order)
    rec val own = Session.make((Set.empty,[]),
          ((chans,lst), msg ->
                   match msg with
                   | {~add}       ->
                     do Session.on_remove(add, (-> remove(add, own)))
                     {set = (Set.add(add,chans),lst)}
                   | {~remove}    -> {set = (Set.remove(remove, chans),lst)}
                   | {~broadcast} ->
                     {set=(chans,broadcast++lst)}
                   | {dump} ->
                     if lst == [] then {unchanged} else do sleep(0, -> Set.iter(chan -> send(chan, lst), chans)) {set=(chans,[])}
    ))
    do Scheduler.timer(timer, ( -> Session.send(own,{dump})))
    own

  broadcast(message: list('a), network: NetworkBuffer.network('a)): void        = send(network, {broadcast = message})
  remove(channel: SessionBuffer.channel('a), network: NetworkBuffer.network('a)): void  = send(network, {remove = channel})
  add(channel: SessionBuffer.channel('a), network: NetworkBuffer.network('a)):  void    = send(network, {add = channel})

}}
