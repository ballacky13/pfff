(*s: unparse_php.ml *)
(*s: Facebook copyright *)
(* Yoann Padioleau
 * 
 * Copyright (C) 2009-2011 Facebook
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
(*e: Facebook copyright *)

open Common 

open Ast_php 
open Parser_php (* the tokens *)
open Parse_info

module V = Visitor_php
module Ast = Ast_php

module TH = Token_helpers_php

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)

(*
 * There are multiple ways to unparse PHP code:
 *  - one can iterate over the AST, and print its leaves, but 
 *    comments and spaces are not in the AST right now so you need
 *    some extra code that also visit the tokens and try to "sync" the
 *    visit of the AST with the tokens
 *  - one can iterate over the tokens, where comments and spaces are normal
 *    citizens, but this can be too low level.
 *  - one can use a real pretty printer with a boxing or backtracking model
 *    working on a AST extended with comments (see juline's ast_pretty_print/).
 *    
 * The token-based unparser handles transfo annotations (Add/Remove).
 * 
 * related: the sexp/json "exporters".
 * 
 * this module could be in analyze_php/ instead of parsing_php/, 
 * but it's maybe good to have the basic parser/unparser together.
 *)

(*****************************************************************************)
(* Helpers *)
(*****************************************************************************)

(* set of tokens that are not in the leaves of the AST *)
let is_not_in_ast = function
  | T_COMMENT _ | T_DOC_COMMENT _ 
  | TSpaces _ | TNewline _ 
      -> true
  | _ -> false
let is_in_ast tok = not (is_not_in_ast tok)

(* when transforming and unparsing we sometimes need to remove spaces,
 * but we usually want to keep the newlines and comments
 *)
let is_newline_or_comment = function
  | T_COMMENT _ | T_DOC_COMMENT _ | TNewline _ -> true
  | _ -> false


let is_in_between_some_remove prev_tok cur_tok = 
  match (TH.info_of_tok prev_tok).transfo, 
        (TH.info_of_tok cur_tok).transfo with
  | Remove, Remove -> true
  | _ -> false

let is_a_remove_or_replace tok = 
  match (TH.info_of_tok tok).transfo with
  | (Remove | Replace _) -> true
  | _ -> false

(*****************************************************************************)
(* Unparsing using AST visitor *)
(*****************************************************************************)

(* This will not preserve space and comments but it's useful
 * and good enough for printing small chunk of PHP code for debugging purpose.
 * We try to preserve the line number.
 *)
let string_of_program2 ast2 = 
  let ast = Parse_php.program_of_program2 ast2 in
  Common.with_open_stringbuf (fun (_pr_with_nl, buf) ->
    let pp s = Buffer.add_string buf s in
    let cur_line = ref 1 in

    pp "<?php";
    pp "\n"; 
    incr cur_line;

    let visitor = V.mk_visitor { V.default_visitor with
      V.kinfo = (fun (k, _) info ->
        match info.Parse_info.token with
        | Parse_info.OriginTok p ->
            let line = p.Parse_info.line in 
            if line > !cur_line
            then begin
              (line - !cur_line) +> Common.times (fun () -> pp "\n"); 
              cur_line := line;
            end;
            let s =  p.Parse_info.str in
            pp s; pp " ";
        | Parse_info.FakeTokStr (s, _opt) ->
            pp s; pp " ";
            if s = ";" 
            then begin
              pp "\n";
              incr cur_line;
            end
        | Parse_info.Ab ->
            ()
        | Parse_info.ExpandedTok _ ->
            raise Todo
      );
    }
    in
    visitor (Program ast);
  )

(*****************************************************************************)
(* Even simpler unparser using AST visitor *)
(*****************************************************************************)

let mk_unparser_visitor pp = 
  let hooks = { V.default_visitor with
    V.kinfo = (fun (k, _) info ->
      match info.Parse_info.token with
      | Parse_info.OriginTok p ->
          let s =  p.Parse_info.str in
          (match s with
          (* certain tokens need a space after because they can be 
           * followed by another identifier.
           * todo: need the pretty printer of julien ... not this hack
           *)
          | "new" ->
              pp s; pp " "
          | _ -> 
              pp s;
          )
      | Parse_info.FakeTokStr (s, _opt) ->
          pp s; pp " ";
          if s = ";" || s = "{" || s = "}"
          then begin
            pp "\n";
          end

      | Parse_info.Ab
        ->
          ()
      | Parse_info.ExpandedTok _ -> raise Todo
    );
  }
  in
  (V.mk_visitor hooks)
    

let string_of_infos ii = 
  (* todo: keep space, keep comments *)
  ii |> List.map (fun info -> Ast.str_of_info info) |> Common.join ""


let string_of_expr_old e = 
  let ii = Lib_parsing_php.ii_of_any (Expr e) in
  string_of_infos ii

let string_of_any any = 
  Common.with_open_stringbuf (fun (_pr_with_nl, buf) ->
    let pp s = Buffer.add_string buf s in
    (mk_unparser_visitor pp) any
  )

(* convenient shortcut *)
let string_of_expr x = string_of_any (Expr x)

(*****************************************************************************)
(* Transformation-aware unparser (using the tokens) *)
(*****************************************************************************)

(* 
 * The idea of the algorithm here is to iterate over all the tokens
 * and depending on the token transfo annotation to print or not
 * the token as well as the comments/spaces associated with the token.
 * The current token is not enough to take certain decisions so
 * the algorithm actually itererates on all the tokens with
 * the previous token as contextual information. For instance if
 * the previous token was also annotated with a Remove, then 
 * we want to also remove the spaces between the previous and current
 * token.
 *)
let string_of_program2_using_transfo ast2 =

   (* for some of the processing below, it is convenient to enclose
    * the list of tokens with some fake tokens so that the special
    * case on the edges do not have to be handled (aka sentinel trick).
    *)
   let fake_tok = Parser_php.T_ECHO (Ast.fakeInfo "fake_token") in

  Common.with_open_stringbuf (fun (_pr_with_nl, buf) ->
    let pp s = Buffer.add_string buf s in
    let pp_tok tok = 
      match TH.pinfo_of_tok tok with
      | Parse_info.OriginTok _ -> 
          pp (TH.str_of_tok tok);
      | Parse_info.ExpandedTok _ -> ()
      | Parse_info.FakeTokStr ("fake_token", _) -> ()
      | Parse_info.Ab | Parse_info.FakeTokStr _ -> raise Impossible
    in
    let pp_add toadd = 
      match toadd with
      | AddStr s -> pp s
      | AddNewlineAndIdent -> raise Todo
    in
    
    ast2 |> List.iter (fun (ast, (s, toks)) ->

      let toks = [fake_tok] ++ toks ++ [fake_tok] in
      
      let (toks_ast_with_previous_comments_attached, trailing_comments) = 
        Common.group_by_post (fun tok -> is_in_ast tok) toks
      in
      assert(null trailing_comments); (* there is a a trailing fake tok *)

      (* the goal here is to print tok and its preceding comments if
       * the transfo fields of the previous and current token respect
       * certain conditions
       *)
      toks_ast_with_previous_comments_attached |> Common.iter_with_previous 
          (fun (comments_prev, tok_prev) (comments, tok)  ->

            (if is_in_between_some_remove tok_prev tok 
             (* TODO: this is ok only for certain tokens, such as comma.
              * 
              * todo: this code is ugly. The proper way is probably to have a
              * classic code pretty-printer/indenter that we
              * run after the transformation. Trying to transform
              * and reindent (or adjust space) at the same time
              * is too complicated I think.
              *)
             then () (* don't print the comment *)
             else 
              if is_a_remove_or_replace tok_prev
              then 
                (match comments with
                | (TSpaces _ | TNewline _)::rest -> rest +> List.iter pp_tok
                | _ -> comments +> List.iter pp_tok
                )
              else
                comments +> List.iter pp_tok
            );

            let info = TH.info_of_tok tok in

            (match TH.pinfo_of_tok tok, info.transfo with
            | Parse_info.ExpandedTok _, NoTransfo -> () 
            | Parse_info.ExpandedTok _, 
                (Remove | Replace _ | AddAfter _ | AddBefore _) ->
                failwith "Can't do transformation on expanded Tok"

            | Parse_info.FakeTokStr ("fake_token", _), _ -> ()

            | Parse_info.Ab, _ -> raise Impossible
            | Parse_info.FakeTokStr _, _ -> raise Impossible

            | Parse_info.OriginTok _, _ -> 

                (match info.transfo with
                | NoTransfo -> 
                    pp_tok tok
                | Remove -> 
                    ()
                | Replace toadd ->
                    pp_add toadd
                      
                | AddAfter toadd ->
                    pp_tok tok;
                    pp_add toadd;
                | AddBefore toadd ->
                    pp_add toadd;
                    pp_tok tok;
                )
            )
          )
    );
  )
  
(*e: unparse_php.ml *)
