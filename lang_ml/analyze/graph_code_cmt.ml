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

open Cmt_format
open Typedtree

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)
(*
 * Graph of dependencies for OCaml typed AST files (.cmt). See graph_code.ml
 * and main_codegraph.ml for more information.
 * 
 * As opposed to lang_ml/analyze/graph_code_ml.ml, no need for:
 *  - module lookup (all names are resolved), but apparently
 *    have still to resolve module aliases :(
 *  - multiple parameters, everything is curried (fun x y --> fun x -> fun y)
 * 
 * schema:
 *  Root -> Dir -> Module -> Function
 *                        -> Type -> Constructor
 *                                -> Field
 *                        -> Exception (with .exn as prefix)
 *                        -> Constant
 *                        -> Global
 *                        -> SubModule
 *)

(*****************************************************************************)
(* Types *)
(*****************************************************************************)

type env = {
  g: Graph_code.graph;
  current: Graph_code.node;
  phase: phase;
  file: Common.filename;
  
  current_qualifier: string;
  current_module: string;
  mutable locals: string list;
}
 and phase = Defs | Uses

(*****************************************************************************)
(* Parsing *)
(*****************************************************************************)
let _hmemo = Hashtbl.create 101
let parse file =
  Common.memoized _hmemo file (fun () ->
    Cmt_format.read_cmt file
  )

let find_source_files_of_dir_or_files xs = 
  Common.files_of_dir_or_files_no_vcs_nofilter xs 
  +> List.filter (fun filename ->
    match File_type.file_type_of_file filename with
    | File_type.Obj "cmt" -> true
    | _ -> false
  ) +> Common.sort

(*****************************************************************************)
(* Add edges *)
(*****************************************************************************)

let add_use_edge env dst =
  let src = env.current in
  match () with
  (* maybe nested function, in which case we dont have the def *)
  | _ when not (G.has_node src env.g) ->
    pr2 (spf "LOOKUP SRC FAIL %s --> %s, src does not exist (nested func?)"
           (G.string_of_node src) (G.string_of_node dst));

  | _ when G.has_node dst env.g -> 
      G.add_edge (src, dst) G.Use env.g
  | _ -> 
      let (str, kind) = dst in
      (match kind with
      | _ ->
          let kind_original = kind in
          let dst = (str, kind_original) in
          
          G.add_node dst env.g;
          let parent_target = G.not_found in
          pr2 (spf "PB: lookup fail on %s (in %s)" 
                  (G.string_of_node dst) (G.string_of_node src));
          
          env.g +> G.add_edge (parent_target, dst) G.Has;
          env.g +> G.add_edge (src, dst) G.Use;
      )

let add_node_and_edge_if_defs_mode ?(dupe_ok=false) env node =
  let (full_ident, _kind) = node in
  if env.phase = Defs then begin
    if G.has_node node env.g && dupe_ok
    then () (* pr2 "already present entity" *)
    else begin
      env.g +> G.add_node node;
      env.g +> G.add_edge (env.current, node) G.Has;
    end
  end;
  { env with  current = node; current_qualifier = full_ident; }

(*****************************************************************************)
(* Kind of entity *)
(*****************************************************************************)
    
let rec kind_of_type_desc x =
  (* pr2 (Ocaml.string_of_v (Meta_ast_cmt.vof_type_desc x)); *)
  match x with
  | Types.Tarrow _ -> 
      E.Function
  | Types.Tconstr (path, xs, aref) 
      (* less: potentially anything with a mutable field *)
      when List.mem (Path.name path) ["Pervasives.ref";"Hashtbl.t"] ->
      E.Global
  | Types.Tconstr (path, xs, aref) -> E.Constant
  | Types.Tlink x -> kind_of_type_expr x
  | _ -> 
      pr2 (Ocaml.string_of_v (Meta_ast_cmt.vof_type_desc x));
      raise Todo
      
and kind_of_type_expr x =
  kind_of_type_desc x.Types.desc
    
(* used only for primitives *)
let rec kind_of_core_type x =
  match x.ctyp_desc with
  | Ttyp_any  | Ttyp_var _
      -> raise Todo
  | Ttyp_arrow _ -> E.Function
  | _ -> raise Todo
let kind_of_value_descr vd =
  kind_of_core_type vd.val_desc

let rec typename_of_texpr x =
  (* pr2 (Ocaml.string_of_v (Meta_ast_cmt.vof_type_expr_show_all x)); *)
  match x.Types.desc with
  | Types.Tconstr(path, xs, aref) -> Path.name path
  | Types.Tlink t -> typename_of_texpr t
  | _ ->
      pr2 (Ocaml.string_of_v (Meta_ast_cmt.vof_type_expr_show_all x));
      raise Todo

let last_in_qualified s =
  let xs = Common.split "\\." s in
  Common.list_last xs
  
let add_use_edge_lid env lid texpr kind =
 if env.phase = Uses then begin
  (* the typename already contains the qualifier *)
  let str = Path.name lid +> last_in_qualified in
  let str_typ = typename_of_texpr texpr in

  let candidates = 
    match str_typ, str with
    | "unit", "()" -> ["stdlib.unit.()", kind]
    | "bool", "true" -> ["stdlib.bool.true", kind]
    | "bool", "false" -> ["stdlib.bool.true", kind]
    | "list", "[]" -> ["stdlib.list.[]", kind]
    | "list", "::" -> ["stdlib.list.::", kind]
    | "option", "None" -> ["stdlib.option.None", kind]
    | "option", "Some" -> ["stdlib.option.Some", kind]
    | "exn", "Not_found" -> ["stdlib.exn.Not_found", kind]
    (* for exn, the typename does not contain the qualifier *)
    | "exn", _ -> 
        let xs = Common.split "\\." (Path.name lid) +> List.rev in
        let ys = (List.hd xs :: "exn" :: List.tl xs) +> List.rev in
        let str = Common.join "." ys in
        [
        (str, E.Exception);
        (env.current_module ^ "." ^ str, E.Exception);
      ]
    | _ -> [
        (str_typ ^ "." ^ str, kind);
        (env.current_module ^ "." ^ str_typ ^ "." ^ str, kind);
      ] 
  in
  let rec aux = function
    | [] ->
        if List.length candidates > 1
        then 
          pr2_gen candidates
    | x::xs ->
        if G.has_node x env.g
        then add_use_edge env x
        else aux xs
  in
  aux candidates
 end

let add_use_edge_lid_bis env lid kind =
 if env.phase = Uses then begin

  let str = Path.name lid in
  let candidates = 
    match str with
    | _ -> [
        (str, kind);
        (env.current_module ^ "." ^ str, kind);
      ] 
  in
  let rec aux = function
    | [] ->
        if List.length candidates > 1
        then 
          pr2_gen candidates
    | x::xs ->
        if G.has_node x env.g
        then add_use_edge env x
        else aux xs
  in
  aux candidates
 end

(*****************************************************************************)
(* Empty wrappers *)
(*****************************************************************************)

module Ident = struct
    let t env x =  ()
    let name = Ident.name
end
module Longident = struct
    let t env x = ()
end
let path_name = Path.name
module Path = struct
    let t env x = ()
end

module TypesOld = Types
module Types = struct
    let value_description env x = ()
    let class_declaration env x = ()
    let class_type env x = ()
    let class_signature env x = ()
    let module_type env x = ()
    let signature env x = ()
    let type_declaration env x = ()
    let exception_declaration env x = ()
    let class_type_declaration env x = ()
end

let v_option f xs = Common.do_option f xs

let v_string x = ()
let v_ref f x = ()

let meth env x = ()
let class_structure env x = ()

let module_type env x = ()
let module_coercion env x = ()
let module_type_constraint env x = ()

let constant env x = ()
let constructor_description env x = ()
let label env x = ()
let row_desc env x = ()
let label_description env x = ()
let partial env x =  ()
let optional env x = ()

(*****************************************************************************)
(* Defs/Uses *)
(*****************************************************************************)
let rec extract_defs_uses ~phase ~g ~ast ~readable =
  let env = {
    g; phase;
    current = (ast.cmt_modname, E.Module);
    current_qualifier = ast.cmt_modname;
    current_module = ast.cmt_modname;
    file = readable;
    locals = [];
  }
  in
  if phase = Defs then begin
    let dir = Common.dirname readable in
    G.create_intermediate_directories_if_not_present g dir;
    g +> G.add_node env.current;
    g +> G.add_edge ((dir, E.Dir), env.current) G.Has;
  end;
  if phase = Uses then begin
    ast.cmt_imports +> List.iter (fun (s, digest) ->
      let node = (s, E.Module) in
      add_use_edge env node
    );
  end;
  binary_annots env ast.cmt_annots

and binary_annots env = function
  | Implementation s -> 
      structure env s
  | Interface _
  | Packed _ 
  | Partial_implementation _ | Partial_interface _ ->
      pr2_gen env.current;
      raise Todo

and structure env 
 { str_items = v_str_items;  str_type = _v_str_type; str_final_env = _env } =
  List.iter (structure_item env) v_str_items
and structure_item env 
 { str_desc = v_str_desc; str_loc = _; str_env = _ } =
  structure_item_desc env v_str_desc
and  pattern env
  { pat_desc = v_pat_desc; pat_type = v_pat_type; 
    pat_loc = v_pat_loc; pat_extra = _v_pat_extra; pat_env = v_pat_env } =
  pattern_desc v_pat_type env v_pat_desc
and expression env
    { exp_desc = v_exp_desc; exp_loc = v_exp_loc;  exp_extra = __v_exp_extra;
      exp_type = __v_exp_type; exp_env = v_exp_env } =
  expression_desc env v_exp_desc
and module_expr env
    { mod_desc = v_mod_desc; mod_loc = v_mod_loc;
      mod_type = v_mod_type; mod_env = v_mod_env  } =
  module_expr_desc env v_mod_desc;
  Types.module_type env v_mod_type

(* ---------------------------------------------------------------------- *)
(* Structure *)
(* ---------------------------------------------------------------------- *)
and structure_item_desc env = function
  | Tstr_eval v1 -> 
      expression env v1
  | Tstr_value ((_rec_flag, xs)) ->
      List.iter (fun (v1, v2) ->
        match v1.pat_desc with
        | Tpat_var(id, _loc) ->
            let full_ident = env.current_qualifier ^ "." ^ Ident.name id in
            let node = (full_ident, kind_of_type_expr v2.exp_type) in
            let env = add_node_and_edge_if_defs_mode ~dupe_ok:true env node in
            expression env v2
        | _ ->
            let env = {env with locals = env.locals } in
            pattern env v1;
            expression env v2 
      ) xs
  | Tstr_primitive ((id, _loc, vd)) ->
      let full_ident = env.current_qualifier ^ "." ^ Ident.name id in
      let node = (full_ident, kind_of_value_descr vd) in
      let env = add_node_and_edge_if_defs_mode env node in
      value_description env vd
  | Tstr_type xs ->
      List.iter (fun (id, _loc, v3) ->
        let full_ident = env.current_qualifier ^ "." ^ Ident.name id in
        let node = (full_ident, E.Type) in
        let env = add_node_and_edge_if_defs_mode env node in
        type_declaration env v3
      ) xs
  | Tstr_exception ((id, _loc, v3)) ->
      let full_ident = env.current_qualifier ^ ".exn." ^ Ident.name id in
      let node = (full_ident, E.Exception) in
      let env = add_node_and_edge_if_defs_mode env node in
      exception_declaration env v3
  | Tstr_exn_rebind ((id, _loc, v3, _loc2)) ->
      let full_ident = env.current_qualifier ^ ".exn." ^ Ident.name id in
      let node = (full_ident, E.Exception) in
      let env = add_node_and_edge_if_defs_mode env node in
      Path.t env v3
  | Tstr_module ((id, _loc, v3)) ->
      let full_ident = env.current_qualifier ^ "." ^ Ident.name id in
      let node = (full_ident, E.Module) in
      let env = add_node_and_edge_if_defs_mode env node in
      module_expr env v3
  | Tstr_recmodule xs ->
      List.iter (fun (id, _loc, v3, v4) ->
        let full_ident = env.current_qualifier ^ "." ^ Ident.name id in
        let node = (full_ident, E.Module) in
        let env = add_node_and_edge_if_defs_mode env node in
        module_type env v3;
        module_expr env v4;
      ) xs
  | Tstr_modtype ((v1, _loc, v3)) ->
      let _ = Ident.t env v1
      and _ = module_type env v3
      in ()

  (* names are resolved, no need to handle that I think *)
  | Tstr_open ((v1, _loc)) ->
      Path.t env v1 
  | Tstr_include ((v1, v2)) ->
      let _ = module_expr env v1 and _ = List.iter (Ident.t env) v2 in ()

  | (Tstr_class _|Tstr_class_type _) -> 
    (*pr2_once (spf "TODO: str_class, %s" env.file) *)
    ()

and type_declaration env
    { typ_params = __v_typ_params; typ_type = v_typ_type;
      typ_cstrs = v_typ_cstrs; typ_kind = v_typ_kind;
      typ_private = _v_typ_private; typ_manifest = v_typ_manifest;
      typ_variance = v_typ_variance; typ_loc = v_typ_loc
    } =
  let _ = Types.type_declaration env v_typ_type in
  let _ =
    List.iter
      (fun (v1, v2, _loc) ->
         let _ = core_type env v1
         and _ = core_type env v2
         in ())
      v_typ_cstrs in
  let _ = type_kind env v_typ_kind in
  let _ = v_option (core_type env) v_typ_manifest in
  List.iter (fun (_bool, _bool2) -> ()) v_typ_variance;
  ()
and type_kind env = function
  | Ttype_abstract -> ()
  | Ttype_variant xs ->
      List.iter (fun (id, _loc, v3, _loc2) ->
        let full_ident = env.current_qualifier ^ "." ^ Ident.name id in
        let node = (full_ident, E.Constructor) in
        let env = add_node_and_edge_if_defs_mode env node in
        List.iter (core_type env) v3;
      ) xs
  | Ttype_record xs ->
      List.iter  (fun (id, _loc, _mutable_flag, v4, _loc2) ->
        let full_ident = env.current_qualifier ^ "." ^ Ident.name id in
        let node = (full_ident, E.Field) in
        let env = add_node_and_edge_if_defs_mode env node in
        core_type env v4;
      ) xs

and exception_declaration env 
 { exn_params = v_exn_params; exn_exn = v_exn_exn; exn_loc = _v_exn_loc } =
  let _ = List.iter (core_type env) v_exn_params in
  let _ = Types.exception_declaration env v_exn_exn in
  ()

(* ---------------------------------------------------------------------- *)
(* Pattern *)
(* ---------------------------------------------------------------------- *)
and pattern_desc t env = function
  | Tpat_any -> ()
  | Tpat_var ((id, _loc)) ->
      env.locals <- Ident.name id :: env.locals
  | Tpat_alias ((v1, id, _loc)) ->
      pattern env v1;
      env.locals <- Ident.name id :: env.locals
  | Tpat_constant v1 -> 
      constant env v1
  | Tpat_tuple xs -> 
      List.iter (pattern env) xs
  | Tpat_construct ((lid, _loc_longident, v3, v4, v5)) ->
      add_use_edge_lid env lid t E.Constructor;
      let _ = constructor_description env v3
      and _ = List.iter (pattern env) v4
      in ()
  | Tpat_variant ((v1, v2, v3)) ->
      let _ = label env v1
      and _ = v_option (pattern env) v2
      and _ = v_ref (row_desc env) v3
      in ()
  | Tpat_record ((xs, _closed_flag)) ->
      List.iter (fun (lid, _loc_longident, v3, v4) ->
        add_use_edge_lid env lid t E.Field;
        let _ = label_description env v3
        and _ = pattern env v4
        in ()
      ) xs
  | Tpat_array xs -> 
      List.iter (pattern env) xs
  | Tpat_or ((v1, v2, v3)) ->
      let _ = pattern env v1
      and _ = pattern env v2
      and _ = v_option (row_desc env) v3
      in ()
  | Tpat_lazy v1 -> 
      pattern env v1

(* ---------------------------------------------------------------------- *)
(* Expression *)
(* ---------------------------------------------------------------------- *)
and expression_desc env =
  function
  | Texp_ident ((lid, _loc_longident, vd)) ->
      let str = path_name lid in
      if List.mem str env.locals
      then ()
      else add_use_edge_lid_bis env lid (kind_of_type_expr vd.TypesOld.val_type)

  | Texp_constant v1 -> constant env v1
  | Texp_let ((_rec_flag, v2, v3)) ->
      let _ =
        List.iter
          (fun (v1, v2) ->
             let _ = pattern env v1 and _ = expression env v2 in ())
          v2
      and _ = expression env v3
      in ()
  | Texp_function ((v1, v2, v3)) ->
      let _ = label env v1
      and _ =
        List.iter
          (fun (v1, v2) ->
             let _ = pattern env v1 and _ = expression env v2 in ())
          v2
      and _ = partial env v3
      in ()
  | Texp_apply ((v1, v2)) ->
      let _ = expression env v1
      and _ =
        List.iter
          (fun (v1, v2, v3) ->
             let _ = label env v1
             and _ = v_option (expression env) v2
             and _ = optional env v3
             in ())
          v2
      in ()
  | Texp_match ((v1, v2, v3)) ->
      let _ = expression env v1
      and _ =
        List.iter
          (fun (v1, v2) ->
             let _ = pattern env v1 and _ = expression env v2 in ())
          v2
      and _ = partial env v3
      in ()
  | Texp_try ((v1, v2)) ->
      let _ = expression env v1
      and _ =
        List.iter
          (fun (v1, v2) ->
             let _ = pattern env v1 and _ = expression env v2 in ())
          v2
      in ()
  | Texp_tuple v1 -> let _ = List.iter (expression env) v1 in ()
  | Texp_construct ((v1, _loc_longident, v3, v4, _bool)) ->
      let _ = Path.t env v1
      and _ = constructor_description env v3
      and _ = List.iter (expression env) v4
      in ()
  | Texp_variant ((v1, v2)) ->
      let _ = label env v1 and _ = v_option (expression env) v2 in ()
  | Texp_record ((v1, v2)) ->
      let _ =
        List.iter
          (fun (v1, _loc_longident, v3, v4) ->
             let _ = Path.t env v1
             and _ = label_description env v3
             and _ = expression env v4
             in ())
          v1
      and _ = v_option (expression env) v2
      in ()
  | Texp_field ((v1, v2, _loc_longident, v4)) ->
      let _ = expression env v1
      and _ = Path.t env v2
      and _ = label_description env v4
      in ()
  | Texp_setfield ((v1, v2, _loc_longident, v4, v5)) ->
      let _ = expression env v1
      and _ = Path.t env v2
      and _ = label_description env v4
      and _ = expression env v5
      in ()
  | Texp_array v1 -> let _ = List.iter (expression env) v1 in ()
  | Texp_ifthenelse ((v1, v2, v3)) ->
      let _ = expression env v1
      and _ = expression env v2
      and _ = v_option (expression env) v3
      in ()
  | Texp_sequence ((v1, v2)) ->
      let _ = expression env v1 and _ = expression env v2 in ()
  | Texp_while ((v1, v2)) ->
      let _ = expression env v1 and _ = expression env v2 in ()
  | Texp_for ((v1, _loc_string, v3, v4, _direction_flag, v6)) ->
      let _ = Ident.t env v1
      and _ = expression env v3
      and _ = expression env v4
      and _ = expression env v6
      in ()
  | Texp_when ((v1, v2)) ->
      let _ = expression env v1 and _ = expression env v2 in ()
  | Texp_send ((v1, v2, v3)) ->
      let _ = expression env v1
      and _ = meth env v2
      and _ = v_option (expression env) v3
      in ()
  | Texp_new ((v1, _loc_longident, v3)) ->
      let _ = Path.t env v1
      and _ = Types.class_declaration env v3
      in ()
  | Texp_instvar ((v1, v2, _loc)) ->
      let _ = Path.t env v1
      and _ = Path.t env v2
      in ()
  | Texp_setinstvar ((v1, v2, _loc, v4)) ->
      let _ = Path.t env v1
      and _ = Path.t env v2
      and _ = expression env v4
      in ()
  | Texp_override ((v1, v2)) ->
      let _ = Path.t env v1
      and _ =
        List.iter
          (fun (v1, _loc, v3) ->
             let _ = Path.t env v1
             and _ = expression env v3
             in ())
          v2
      in ()
  | Texp_letmodule ((v1, _loc, v3, v4)) ->
      let _ = Ident.t env v1
      and _ = module_expr env v3
      and _ = expression env v4
      in ()
  | Texp_assert v1 -> let _ = expression env v1 in ()
  | Texp_assertfalse -> ()
  | Texp_lazy v1 -> let _ = expression env v1 in ()
  | Texp_object ((v1, v2)) ->
      let _ = class_structure env v1 and _ = List.iter v_string v2 in ()
  | Texp_pack v1 -> let _ = module_expr env v1 in ()

and exp_extra env = function
  | Texp_constraint ((v1, v2)) ->
      let _ = v_option (core_type env) v1
      and _ = v_option (core_type env) v2
      in ()
  | Texp_open ((v1, _loc_longident, _env)) ->
      Path.t env v1
  | Texp_poly v1 -> let _ = v_option (core_type env) v1 in ()
  | Texp_newtype v1 -> let _ = v_string v1 in ()

(* ---------------------------------------------------------------------- *)
(* Module *)
(* ---------------------------------------------------------------------- *)
and module_expr_desc env =
  function
  | Tmod_ident ((v1, _loc_longident)) ->
      Path.t env v1
  | Tmod_structure v1 -> let _ = structure env v1 in ()
  | Tmod_functor ((v1, _loc, v3, v4)) ->
      let _ = Ident.t env v1
      and _ = module_type env v3
      and _ = module_expr env v4
      in ()
  | Tmod_apply ((v1, v2, v3)) ->
      let _ = module_expr env v1
      and _ = module_expr env v2
      and _ = module_coercion env v3
      in ()
  | Tmod_constraint ((v1, v2, v3, v4)) ->
      let _ = module_expr env v1
      and _ = Types.module_type env v2
      and _ = module_type_constraint env v3
      and _ = module_coercion env v4
      in ()
  | Tmod_unpack ((v1, v2)) ->
      let _ = expression env v1 and _ = Types.module_type env v2 in ()
(* ---------------------------------------------------------------------- *)
(* Type *)
(* ---------------------------------------------------------------------- *)
and core_type env
    { ctyp_desc = v_ctyp_desc; ctyp_type = __v_ctyp_type;
      ctyp_env = v_ctyp_env; ctyp_loc = v_ctyp_loc } =
  core_type_desc env v_ctyp_desc
and core_type_desc env =
  function
  | Ttyp_any -> ()
  | Ttyp_var v1 -> let _ = v_string v1 in ()
  | Ttyp_arrow ((v1, v2, v3)) ->
      let _ = label env v1
      and _ = core_type env v2
      and _ = core_type env v3
      in ()
  | Ttyp_tuple v1 -> let _ = List.iter (core_type env) v1 in ()
  | Ttyp_constr ((v1, _loc_longident, v3)) ->
      let _ = Path.t env v1
      and _ = List.iter (core_type env) v3
      in ()
  | Ttyp_object v1 -> let _ = List.iter (core_field_type env) v1 in ()
  | Ttyp_class ((v1, _loc_longident, v3, v4)) ->
      let _ = Path.t env v1
      and _ = List.iter (core_type env) v3
      and _ = List.iter (label env) v4
      in ()
  | Ttyp_alias ((v1, v2)) ->
      let _ = core_type env v1 and _ = v_string v2 in ()
  | Ttyp_variant ((v1, _bool, v3)) ->
      let _ = List.iter (row_field env) v1
      and _ = v_option (List.iter (label env)) v3
      in ()
  | Ttyp_poly ((v1, v2)) ->
      let _ = List.iter v_string v1 and _ = core_type env v2 in ()
  | Ttyp_package v1 -> 
    pr2_once (spf "TODO: Ttyp_package, %s" env.file);
    ()

and core_field_type env { field_desc = v_field_desc; field_loc = v_field_loc }=
  let _ = core_field_desc env v_field_desc in ()
  
and core_field_desc env =
  function
  | Tcfield ((v1, v2)) -> let _ = v_string v1 and _ = core_type env v2 in ()
  | Tcfield_var -> ()
and row_field env =
  function
  | Ttag ((v1, _bool, v3)) ->
      let _ = label env v1
      and _ = List.iter (core_type env) v3
      in ()
  | Tinherit v1 -> let _ = core_type env v1 in ()
and
  value_description env
                    {
                      val_desc = v_val_desc;
                      val_val = v_val_val;
                      val_prim = v_val_prim;
                      val_loc = v_val_loc
                    } =
  let _ = core_type env v_val_desc in
  let _ = Types.value_description env v_val_val in
  let _ = List.iter v_string v_val_prim in
  ()

(*****************************************************************************)
(* Main entry point *)
(*****************************************************************************)

let build ?(verbose=true) dir_or_file skip_list =
  let root = Common.realpath dir_or_file in
  let all_files = 
    find_source_files_of_dir_or_files [root] in

  (* step0: filter noisy modules/files *)
  let files = Skip_code.filter_files ~verbose skip_list root all_files in

  let g = G.create () in
  G.create_initial_hierarchy g;

  (* step1: creating the nodes and 'Has' edges, the defs *)
  if verbose then pr2 "\nstep1: extract defs";
  files +> Common_extra.progress ~show:verbose (fun k -> 
    List.iter (fun file ->
      k();
      let ast = parse file in
      let readable = Common.filename_without_leading_path root file in
      extract_defs_uses ~g ~ast ~phase:Defs ~readable;
      ()
    ));

  (* step2: creating the 'Use' edges *)
  if verbose then pr2 "\nstep2: extract uses";
  files +> Common_extra.progress ~show:verbose (fun k -> 
    List.iter (fun file ->
      k();
      let ast = parse file in
      let readable = Common.filename_without_leading_path root file in
      if readable =~ "^external" || readable =~ "^EXTERNAL"
      then ()
      else extract_defs_uses ~g ~ast ~phase:Uses ~readable;
      ()
    ));

  g
