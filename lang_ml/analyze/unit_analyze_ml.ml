open Common

open Ast_ml

module Db = Database_light_ml

open OUnit

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)

(*****************************************************************************)
(* Helpers *)
(*****************************************************************************)

let verbose = false

(*****************************************************************************)
(* Unit tests *)
(*****************************************************************************)

(*---------------------------------------------------------------------------*)
(* Database building *)
(*---------------------------------------------------------------------------*)

let database_unittest =
  "database_ml" >::: [

    "building light database" >:: (fun () ->
      let data_dir = Config_pfff.path ^ "/tests/ml/db/" in
      let _db = Db.compute_database ~verbose [data_dir] in
      ()
    )
  ]

(*---------------------------------------------------------------------------*)
(* Final suite *)
(*---------------------------------------------------------------------------*)

let unittest =
  "analyze_ml" >::: [
    database_unittest;
  ]
