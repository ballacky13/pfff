(* Yoann Padioleau
 *
 * Copyright (C) 2012 Facebook
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2.1 as published by the Free Software Foundation, with the
 * special exception on linking described in file license.txt.
 * 
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the file
 * license.txt for more details.
 *)
open Common

module E = Database_code
module G = Graph_code

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)

(*****************************************************************************)
(* Types *)
(*****************************************************************************)
type graph = {
  name_to_i: (Graph_code.node, int) Hashtbl.t;
  i_to_name: Graph_code.node array;

  has_children: (int list) array;
  use: (int list) array;
}

(*****************************************************************************)
(* API *)
(*****************************************************************************)
let nb_nodes g = 
  Array.length g.i_to_name

(*****************************************************************************)
(* Converting *)
(*****************************************************************************)

let (convert2: Graph_code.graph -> graph) = fun g ->
  let n = G.nb_nodes g in

  let h = {
    name_to_i = Hashtbl.create (n / 2);
    i_to_name = Array.create n ("",E.Dir);
    has_children = Array.create n [];
    use = Array.create n [];
  }
  in
  let i = ref 0 in
  g +> G.iter_nodes (fun node ->
    Hashtbl.add h.name_to_i node !i;
    h.i_to_name.(!i) <- node;
    incr i;
  );
  g +> G.iter_nodes (fun node ->
    let i = Hashtbl.find h.name_to_i node in
    g +> G.succ node G.Has +> List.iter (fun node2 ->
      let j = Hashtbl.find h.name_to_i node2 in
      h.has_children.(i) <- j :: h.has_children.(i);
    );
    g +> G.succ node G.Use +> List.iter (fun node2 ->
      let j = Hashtbl.find h.name_to_i node2 in
      h.use.(i) <- j :: h.use.(i);
    );
  );
  h

let convert a = 
  Common.profile_code "Graph_code_opti.convert" (fun () -> convert2 a)
