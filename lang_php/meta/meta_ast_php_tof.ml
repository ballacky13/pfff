(* Yoann Padioleau
 *
 * Copyright (C) 2010 Facebook
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

open Ast_php

let tof_either =
  Ocaml.add_new_type "either"
    (Ocaml.Sum
       [ ("Left", [ Ocaml.Poly "a" ]); ("Right", [ Ocaml.Poly "b" ]) ])

(* pad: mostly auto generated. Had to tweak a few things because
 * parse_info is in another module, and ocamltarzan does not like that.
 * 
 * C-s pad
 *)
let tof_parse_info =
  Ocaml.add_new_type "parse_info"
    (Ocaml.Dict
       [ ("str", `RO, Ocaml.String); ("charpos", `RO, Ocaml.Int);
         ("line", `RO, Ocaml.Int); ("column", `RO, Ocaml.Int);
         ("file", `RO, (Ocaml.Var "filename")) ])

(* generated by ocamltarzan with: camlp4o -o /tmp/yyy.ml -I pa/ pa_type_conv.cmo pa_tof.cmo  pr_o.cmo /tmp/xxx.ml  *)

let tof_pinfo = Ocaml.add_new_type "pinfo" (Ocaml.TTODO "")
  
let tof_comma_list =
  Ocaml.add_new_type "comma_list" (Ocaml.List (Ocaml.TTODO ""))
and tof_bracket =
  Ocaml.add_new_type "bracket"
    (Ocaml.Tuple [ Ocaml.Var "tok"; Ocaml.Poly "a"; Ocaml.Var "tok" ])
and tof_brace =
  Ocaml.add_new_type "brace"
    (Ocaml.Tuple [ Ocaml.Var "tok"; Ocaml.Poly "a"; Ocaml.Var "tok" ])
and tof_paren =
  Ocaml.add_new_type "paren"
    (Ocaml.Tuple [ Ocaml.Var "tok"; Ocaml.Poly "a"; Ocaml.Var "tok" ])
and tof_wrap =
  Ocaml.add_new_type "wrap"
    (Ocaml.Tuple [ Ocaml.Poly "a"; Ocaml.Var "info" ])
and tof_tok = Ocaml.add_new_type "tok" (Ocaml.Var "info")
and tof_info = Ocaml.add_new_type "info" (Ocaml.TTODO "")
  
let tof_fully_qualified_class_name =
  Ocaml.add_new_type "fully_qualified_class_name" (Ocaml.Var "name")
and tof_class_name_or_selfparent =
  Ocaml.add_new_type "class_name_or_selfparent"
    (Ocaml.Sum
       [ ("ClassName", [ Ocaml.Var "fully_qualified_class_name" ]);
         ("Self", [ Ocaml.Var "tok" ]); ("Parent", [ Ocaml.Var "tok" ]) ])
and tof_qualifier =
  Ocaml.add_new_type "qualifier"
    (Ocaml.Tuple [ Ocaml.Var "class_name_or_selfparent"; Ocaml.Var "tok" ])
and tof_dname =
  Ocaml.add_new_type "dname"
    (Ocaml.Sum [ ("DName", [ Ocaml.Apply (("wrap", Ocaml.String)) ]) ])
and tof_xhp_tag = Ocaml.add_new_type "xhp_tag" (Ocaml.List Ocaml.String)
and tof_name =
  Ocaml.add_new_type "name"
    (Ocaml.Sum
       [ ("Name", [ Ocaml.Apply (("wrap", Ocaml.String)) ]);
         ("XhpName", [ Ocaml.Apply (("wrap", (Ocaml.Var "xhp_tag"))) ]) ])
  
let tof_ptype =
  Ocaml.add_new_type "ptype"
    (Ocaml.Sum
       [ ("BoolTy", []); ("IntTy", []); ("DoubleTy", []); ("StringTy", []);
         ("ArrayTy", []); ("ObjectTy", []) ])
  
let tof_program =
  Ocaml.add_new_type "program" (Ocaml.List (Ocaml.Var "toplevel"))
and tof_toplevel =
  Ocaml.add_new_type "toplevel"
    (Ocaml.Sum
       [ ("StmtList", [ Ocaml.List (Ocaml.Var "stmt") ]);
         ("FuncDef", [ Ocaml.Var "func_def" ]);
         ("ClassDef", [ Ocaml.Var "class_def" ]);
         ("InterfaceDef", [ Ocaml.Var "interface_def" ]);
         ("Halt",
          [ Ocaml.Var "tok"; Ocaml.Apply (("paren", Ocaml.Unit));
            Ocaml.Var "tok" ]);
         ("NotParsedCorrectly", [ Ocaml.List (Ocaml.Var "info") ]);
         ("FinalDef", [ Ocaml.Var "info" ]) ])
and tof_stmt_and_def =
  Ocaml.add_new_type "stmt_and_def"
    (Ocaml.Sum
       [ ("Stmt", [ Ocaml.Var "stmt" ]);
         ("FuncDefNested", [ Ocaml.Var "func_def" ]);
         ("ClassDefNested", [ Ocaml.Var "class_def" ]);
         ("InterfaceDefNested", [ Ocaml.Var "interface_def" ]) ])
and tof_static_array_pair =
  Ocaml.add_new_type "static_array_pair"
    (Ocaml.Sum
       [ ("StaticArraySingle", [ Ocaml.Var "static_scalar" ]);
         ("StaticArrayArrow",
          [ Ocaml.Var "static_scalar"; Ocaml.Var "tok";
            Ocaml.Var "static_scalar" ]) ])
and tof_static_scalar_affect =
  Ocaml.add_new_type "static_scalar_affect"
    (Ocaml.Tuple [ Ocaml.Var "tok"; Ocaml.Var "static_scalar" ])
and tof_static_scalar =
  Ocaml.add_new_type "static_scalar"
    (Ocaml.Sum
       [ ("StaticConstant", [ Ocaml.Var "constant" ]);
         ("StaticClassConstant",
          [ Ocaml.Var "qualifier"; Ocaml.Var "name" ]);
         ("StaticPlus", [ Ocaml.Var "tok"; Ocaml.Var "static_scalar" ]);
         ("StaticMinus", [ Ocaml.Var "tok"; Ocaml.Var "static_scalar" ]);
         ("StaticArray",
          [ Ocaml.Var "tok";
            Ocaml.Apply
              (("paren",
                (Ocaml.Apply
                   (("comma_list", (Ocaml.Var "static_array_pair")))))) ]);
         ("XdebugStaticDots", []) ])
and tof_static_var =
  Ocaml.add_new_type "static_var"
    (Ocaml.Tuple
       [ Ocaml.Var "dname"; Ocaml.Option (Ocaml.Var "static_scalar_affect") ])
and tof_global_var =
  Ocaml.add_new_type "global_var"
    (Ocaml.Sum
       [ ("GlobalVar", [ Ocaml.Var "dname" ]);
         ("GlobalDollar", [ Ocaml.Var "tok"; Ocaml.Var "r_variable" ]);
         ("GlobalDollarExpr",
          [ Ocaml.Var "tok"; Ocaml.Apply (("brace", (Ocaml.Var "expr"))) ]) ])
and tof_xhp_category_decl =
  Ocaml.add_new_type "xhp_category_decl"
    (Ocaml.Apply (("wrap", (Ocaml.Var "xhp_tag"))))
and tof_xhp_children_decl =
  Ocaml.add_new_type "xhp_children_decl"
    (Ocaml.Sum
       [ ("XhpChild", [ Ocaml.Apply (("wrap", (Ocaml.Var "xhp_tag"))) ]);
         ("XhpChildCategory",
          [ Ocaml.Apply (("wrap", (Ocaml.Var "xhp_tag"))) ]);
         ("XhpChildAny", [ Ocaml.Var "tok" ]);
         ("XhpChildEmpty", [ Ocaml.Var "tok" ]);
         ("XhpChildPcdata", [ Ocaml.Var "tok" ]);
         ("XhpChildSequence",
          [ Ocaml.Var "xhp_children_decl"; Ocaml.Var "tok";
            Ocaml.Var "xhp_children_decl" ]);
         ("XhpChildAlternative",
          [ Ocaml.Var "xhp_children_decl"; Ocaml.Var "tok";
            Ocaml.Var "xhp_children_decl" ]);
         ("XhpChildMul", [ Ocaml.Var "xhp_children_decl"; Ocaml.Var "tok" ]);
         ("XhpChildOption",
          [ Ocaml.Var "xhp_children_decl"; Ocaml.Var "tok" ]);
         ("XhpChildPlus", [ Ocaml.Var "xhp_children_decl"; Ocaml.Var "tok" ]);
         ("XhpChildParen",
          [ Ocaml.Apply (("paren", (Ocaml.Var "xhp_children_decl"))) ]) ])
and tof_xhp_value_affect =
  Ocaml.add_new_type "xhp_value_affect"
    (Ocaml.Tuple [ Ocaml.Var "tok"; Ocaml.Var "constant" ])
and tof_xhp_attribute_type =
  Ocaml.add_new_type "xhp_attribute_type"
    (Ocaml.Sum
       [ ("XhpAttrType", [ Ocaml.Var "name" ]);
         ("XhpAttrEnum",
          [ Ocaml.Var "tok";
            Ocaml.Apply
              (("brace",
                (Ocaml.Apply (("comma_list", (Ocaml.Var "constant")))))) ]) ])
and tof_xhp_attribute_decl =
  Ocaml.add_new_type "xhp_attribute_decl"
    (Ocaml.Sum
       [ ("XhpAttrInherit",
          [ Ocaml.Apply (("wrap", (Ocaml.Var "xhp_tag"))) ]);
         ("XhpAttrDecl",
          [ Ocaml.Var "xhp_attribute_type"; Ocaml.Var "xhp_attr_name";
            Ocaml.Option (Ocaml.Var "xhp_value_affect");
            Ocaml.Option (Ocaml.Var "tok") ]) ])
and tof_xhp_decl =
  Ocaml.add_new_type "xhp_decl"
    (Ocaml.Sum
       [ ("XhpAttributesDecl",
          [ Ocaml.Var "tok";
            Ocaml.Apply (("comma_list", (Ocaml.Var "xhp_attribute_decl")));
            Ocaml.Var "tok" ]);
         ("XhpChildrenDecl",
          [ Ocaml.Var "tok"; Ocaml.Var "xhp_children_decl"; Ocaml.Var "tok" ]);
         ("XhpCategoriesDecl",
          [ Ocaml.Var "tok";
            Ocaml.Apply (("comma_list", (Ocaml.Var "xhp_category_decl")));
            Ocaml.Var "tok" ]) ])
and tof_method_body =
  Ocaml.add_new_type "method_body"
    (Ocaml.Sum
       [ ("AbstractMethod", [ Ocaml.Var "tok" ]);
         ("MethodBody",
          [ Ocaml.Apply (("brace", (Ocaml.List (Ocaml.Var "stmt_and_def")))) ]) ])
and tof_modifier =
  Ocaml.add_new_type "modifier"
    (Ocaml.Sum
       [ ("Public", []); ("Private", []); ("Protected", []); ("Static", []);
         ("Abstract", []); ("Final", []) ])
and tof_method_def =
  Ocaml.add_new_type "method_def"
    (Ocaml.Dict
       [ ("m_modifiers", `RO,
          (Ocaml.List (Ocaml.Apply (("wrap", (Ocaml.Var "modifier"))))));
         ("m_tok", `RO, (Ocaml.Var "tok"));
         ("m_ref", `RO, (Ocaml.Var "is_ref"));
         ("m_name", `RO, (Ocaml.Var "name"));
         ("m_params", `RO,
          (Ocaml.Apply
             (("paren",
               (Ocaml.Apply (("comma_list", (Ocaml.Var "parameter"))))))));
         ("m_return_type", `RO, (Ocaml.Option (Ocaml.Var "hint_type")));
         ("m_body", `RO, (Ocaml.Var "method_body")) ])
and tof_class_var_modifier =
  Ocaml.add_new_type "class_var_modifier"
    (Ocaml.Sum
       [ ("NoModifiers", [ Ocaml.Var "tok" ]);
         ("VModifiers",
          [ Ocaml.List (Ocaml.Apply (("wrap", (Ocaml.Var "modifier")))) ]) ])
and tof_class_variable =
  Ocaml.add_new_type "class_variable"
    (Ocaml.Tuple
       [ Ocaml.Var "dname"; Ocaml.Option (Ocaml.Var "static_scalar_affect") ])
and tof_class_constant =
  Ocaml.add_new_type "class_constant"
    (Ocaml.Tuple [ Ocaml.Var "name"; Ocaml.Var "static_scalar_affect" ])
and tof_class_stmt =
  Ocaml.add_new_type "class_stmt"
    (Ocaml.Sum
       [ ("ClassConstants",
          [ Ocaml.Var "tok";
            Ocaml.Apply (("comma_list", (Ocaml.Var "class_constant")));
            Ocaml.Var "tok" ]);
         ("ClassVariables",
          [ Ocaml.Var "class_var_modifier";
            Ocaml.Option (Ocaml.Var "hint_type");
            Ocaml.Apply (("comma_list", (Ocaml.Var "class_variable")));
            Ocaml.Var "tok" ]);
         ("Method", [ Ocaml.Var "method_def" ]);
         ("XhpDecl", [ Ocaml.Var "xhp_decl" ]) ])
and tof_interface_def =
  Ocaml.add_new_type "interface_def"
    (Ocaml.Dict
       [ ("i_tok", `RO, (Ocaml.Var "tok"));
         ("i_name", `RO, (Ocaml.Var "name"));
         ("i_extends", `RO, (Ocaml.Option (Ocaml.Var "interface")));
         ("i_body", `RO,
          (Ocaml.Apply (("brace", (Ocaml.List (Ocaml.Var "class_stmt")))))) ])
and tof_interface =
  Ocaml.add_new_type "interface"
    (Ocaml.Tuple
       [ Ocaml.Var "tok";
         Ocaml.Apply
           (("comma_list", (Ocaml.Var "fully_qualified_class_name"))) ])
and tof_extend =
  Ocaml.add_new_type "extend"
    (Ocaml.Tuple [ Ocaml.Var "tok"; Ocaml.Var "fully_qualified_class_name" ])
and tof_class_type =
  Ocaml.add_new_type "class_type"
    (Ocaml.Sum
       [ ("ClassRegular", [ Ocaml.Var "tok" ]);
         ("ClassFinal", [ Ocaml.Var "tok"; Ocaml.Var "tok" ]);
         ("ClassAbstract", [ Ocaml.Var "tok"; Ocaml.Var "tok" ]) ])
and tof_class_def =
  Ocaml.add_new_type "class_def"
    (Ocaml.Dict
       [ ("c_type", `RO, (Ocaml.Var "class_type"));
         ("c_name", `RO, (Ocaml.Var "name"));
         ("c_extends", `RO, (Ocaml.Option (Ocaml.Var "extend")));
         ("c_implements", `RO, (Ocaml.Option (Ocaml.Var "interface")));
         ("c_body", `RO,
          (Ocaml.Apply (("brace", (Ocaml.List (Ocaml.Var "class_stmt")))))) ])
and tof_lexical_var =
  Ocaml.add_new_type "lexical_var"
    (Ocaml.Sum [ ("LexicalVar", [ Ocaml.Var "is_ref"; Ocaml.Var "dname" ]) ])
and tof_lexical_vars =
  Ocaml.add_new_type "lexical_vars"
    (Ocaml.Tuple
       [ Ocaml.Var "tok";
         Ocaml.Apply
           (("paren",
             (Ocaml.Apply (("comma_list", (Ocaml.Var "lexical_var")))))) ])
and tof_lambda_def =
  Ocaml.add_new_type "lambda_def"
    (Ocaml.Dict
       [ ("l_tok", `RO, (Ocaml.Var "tok"));
         ("l_ref", `RO, (Ocaml.Var "is_ref"));
         ("l_params", `RO,
          (Ocaml.Apply
             (("paren",
               (Ocaml.Apply (("comma_list", (Ocaml.Var "parameter"))))))));
         ("l_use", `RO, (Ocaml.Option (Ocaml.Var "lexical_vars")));
         ("l_body", `RO,
          (Ocaml.Apply (("brace", (Ocaml.List (Ocaml.Var "stmt_and_def")))))) ])
and tof_is_ref = Ocaml.add_new_type "is_ref" (Ocaml.Option (Ocaml.Var "tok"))
and tof_hint_type =
  Ocaml.add_new_type "hint_type"
    (Ocaml.Sum
       [ ("Hint", [ Ocaml.Var "class_name_or_selfparent" ]);
         ("HintArray", [ Ocaml.Var "tok" ]) ])
and tof_parameter =
  Ocaml.add_new_type "parameter"
    (Ocaml.Dict
       [ ("p_type", `RO, (Ocaml.Option (Ocaml.Var "hint_type")));
         ("p_ref", `RO, (Ocaml.Var "is_ref"));
         ("p_name", `RO, (Ocaml.Var "dname"));
         ("p_default", `RO,
          (Ocaml.Option (Ocaml.Var "static_scalar_affect"))) ])
and tof_func_def =
  Ocaml.add_new_type "func_def"
    (Ocaml.Dict
       [ ("f_tok", `RO, (Ocaml.Var "tok"));
         ("f_ref", `RO, (Ocaml.Var "is_ref"));
         ("f_name", `RO, (Ocaml.Var "name"));
         ("f_params", `RO,
          (Ocaml.Apply
             (("paren",
               (Ocaml.Apply (("comma_list", (Ocaml.Var "parameter"))))))));
         ("f_return_type", `RO, (Ocaml.Option (Ocaml.Var "hint_type")));
         ("f_body", `RO,
          (Ocaml.Apply (("brace", (Ocaml.List (Ocaml.Var "stmt_and_def"))))));
(* pad *)
         ("f_type", `RW, (Ocaml.Var "TODO")) ])
and tof_new_else =
  Ocaml.add_new_type "new_else"
    (Ocaml.Tuple
       [ Ocaml.Var "tok"; Ocaml.Var "tok";
         Ocaml.List (Ocaml.Var "stmt_and_def") ])
and tof_new_elseif =
  Ocaml.add_new_type "new_elseif"
    (Ocaml.Tuple
       [ Ocaml.Var "tok"; Ocaml.Apply (("paren", (Ocaml.Var "expr")));
         Ocaml.Var "tok"; Ocaml.List (Ocaml.Var "stmt_and_def") ])
and tof_colon_stmt =
  Ocaml.add_new_type "colon_stmt"
    (Ocaml.Sum
       [ ("SingleStmt", [ Ocaml.Var "stmt" ]);
         ("ColonStmt",
          [ Ocaml.Var "tok"; Ocaml.List (Ocaml.Var "stmt_and_def");
            Ocaml.Var "tok"; Ocaml.Var "tok" ]) ])
and tof_declare =
  Ocaml.add_new_type "declare"
    (Ocaml.Tuple [ Ocaml.Var "name"; Ocaml.Var "static_scalar_affect" ])
and tof_use_filename =
  Ocaml.add_new_type "use_filename"
    (Ocaml.Sum
       [ ("UseDirect", [ Ocaml.Apply (("wrap", Ocaml.String)) ]);
         ("UseParen",
          [ Ocaml.Apply (("paren", (Ocaml.Apply (("wrap", Ocaml.String))))) ]) ])
and tof_catch =
  Ocaml.add_new_type "catch"
    (Ocaml.Tuple
       [ Ocaml.Var "tok";
         Ocaml.Apply
           (("paren",
             (Ocaml.Tuple
                [ Ocaml.Var "fully_qualified_class_name"; Ocaml.Var "dname" ])));
         Ocaml.Apply (("brace", (Ocaml.List (Ocaml.Var "stmt_and_def")))) ])
and tof_foreach_var_either =
  Ocaml.add_new_type "foreach_var_either" (Ocaml.TTODO "")
and tof_foreach_variable =
  Ocaml.add_new_type "foreach_variable"
    (Ocaml.Tuple [ Ocaml.Var "is_ref"; Ocaml.Var "lvalue" ])
and tof_foreach_arrow =
  Ocaml.add_new_type "foreach_arrow"
    (Ocaml.Tuple [ Ocaml.Var "tok"; Ocaml.Var "foreach_variable" ])
and tof_for_expr =
  Ocaml.add_new_type "for_expr"
    (Ocaml.Apply (("comma_list", (Ocaml.Var "expr"))))
and tof_if_else =
  Ocaml.add_new_type "if_else"
    (Ocaml.Tuple [ Ocaml.Var "tok"; Ocaml.Var "stmt" ])
and tof_if_elseif =
  Ocaml.add_new_type "if_elseif"
    (Ocaml.Tuple
       [ Ocaml.Var "tok"; Ocaml.Apply (("paren", (Ocaml.Var "expr")));
         Ocaml.Var "stmt" ])
and tof_case =
  Ocaml.add_new_type "case"
    (Ocaml.Sum
       [ ("Case",
          [ Ocaml.Var "tok"; Ocaml.Var "expr"; Ocaml.Var "tok";
            Ocaml.List (Ocaml.Var "stmt_and_def") ]);
         ("Default",
          [ Ocaml.Var "tok"; Ocaml.Var "tok";
            Ocaml.List (Ocaml.Var "stmt_and_def") ]) ])
and tof_switch_case_list =
  Ocaml.add_new_type "switch_case_list"
    (Ocaml.Sum
       [ ("CaseList",
          [ Ocaml.Var "tok"; Ocaml.Option (Ocaml.Var "tok");
            Ocaml.List (Ocaml.Var "case"); Ocaml.Var "tok" ]);
         ("CaseColonList",
          [ Ocaml.Var "tok"; Ocaml.Option (Ocaml.Var "tok");
            Ocaml.List (Ocaml.Var "case"); Ocaml.Var "tok"; Ocaml.Var "tok" ]) ])
and tof_stmt =
  Ocaml.add_new_type "stmt"
    (Ocaml.Sum
       [ ("ExprStmt", [ Ocaml.Var "expr"; Ocaml.Var "tok" ]);
         ("EmptyStmt", [ Ocaml.Var "tok" ]);
         ("Block",
          [ Ocaml.Apply (("brace", (Ocaml.List (Ocaml.Var "stmt_and_def")))) ]);
         ("If",
          [ Ocaml.Var "tok"; Ocaml.Apply (("paren", (Ocaml.Var "expr")));
            Ocaml.Var "stmt"; Ocaml.List (Ocaml.Var "if_elseif");
            Ocaml.Option (Ocaml.Var "if_else") ]);
         ("IfColon",
          [ Ocaml.Var "tok"; Ocaml.Apply (("paren", (Ocaml.Var "expr")));
            Ocaml.Var "tok"; Ocaml.List (Ocaml.Var "stmt_and_def");
            Ocaml.List (Ocaml.Var "new_elseif");
            Ocaml.Option (Ocaml.Var "new_else"); Ocaml.Var "tok";
            Ocaml.Var "tok" ]);
         ("While",
          [ Ocaml.Var "tok"; Ocaml.Apply (("paren", (Ocaml.Var "expr")));
            Ocaml.Var "colon_stmt" ]);
         ("Do",
          [ Ocaml.Var "tok"; Ocaml.Var "stmt"; Ocaml.Var "tok";
            Ocaml.Apply (("paren", (Ocaml.Var "expr"))); Ocaml.Var "tok" ]);
         ("For",
          [ Ocaml.Var "tok"; Ocaml.Var "tok"; Ocaml.Var "for_expr";
            Ocaml.Var "tok"; Ocaml.Var "for_expr"; Ocaml.Var "tok";
            Ocaml.Var "for_expr"; Ocaml.Var "tok"; Ocaml.Var "colon_stmt" ]);
         ("Switch",
          [ Ocaml.Var "tok"; Ocaml.Apply (("paren", (Ocaml.Var "expr")));
            Ocaml.Var "switch_case_list" ]);
         ("Foreach",
          [ Ocaml.Var "tok"; Ocaml.Var "tok"; Ocaml.Var "expr";
            Ocaml.Var "tok"; Ocaml.Var "foreach_var_either";
            Ocaml.Option (Ocaml.Var "foreach_arrow"); Ocaml.Var "tok";
            Ocaml.Var "colon_stmt" ]);
         ("Break",
          [ Ocaml.Var "tok"; Ocaml.Option (Ocaml.Var "expr"); Ocaml.Var "tok" ]);
         ("Continue",
          [ Ocaml.Var "tok"; Ocaml.Option (Ocaml.Var "expr"); Ocaml.Var "tok" ]);
         ("Return",
          [ Ocaml.Var "tok"; Ocaml.Option (Ocaml.Var "expr"); Ocaml.Var "tok" ]);
         ("Throw", [ Ocaml.Var "tok"; Ocaml.Var "expr"; Ocaml.Var "tok" ]);
         ("Try",
          [ Ocaml.Var "tok";
            Ocaml.Apply (("brace", (Ocaml.List (Ocaml.Var "stmt_and_def"))));
            Ocaml.Var "catch"; Ocaml.List (Ocaml.Var "catch") ]);
         ("Echo",
          [ Ocaml.Var "tok";
            Ocaml.Apply (("comma_list", (Ocaml.Var "expr"))); Ocaml.Var "tok" ]);
         ("Globals",
          [ Ocaml.Var "tok";
            Ocaml.Apply (("comma_list", (Ocaml.Var "global_var")));
            Ocaml.Var "tok" ]);
         ("StaticVars",
          [ Ocaml.Var "tok";
            Ocaml.Apply (("comma_list", (Ocaml.Var "static_var")));
            Ocaml.Var "tok" ]);
         ("InlineHtml", [ Ocaml.Apply (("wrap", Ocaml.String)) ]);
         ("Use",
          [ Ocaml.Var "tok"; Ocaml.Var "use_filename"; Ocaml.Var "tok" ]);
         ("Unset",
          [ Ocaml.Var "tok";
            Ocaml.Apply
              (("paren",
                (Ocaml.Apply (("comma_list", (Ocaml.Var "lvalue"))))));
            Ocaml.Var "tok" ]);
         ("Declare",
          [ Ocaml.Var "tok";
            Ocaml.Apply
              (("paren",
                (Ocaml.Apply (("comma_list", (Ocaml.Var "declare"))))));
            Ocaml.Var "colon_stmt" ]);
         ("TypedDeclaration",
          [ Ocaml.Var "hint_type"; Ocaml.Var "lvalue";
            Ocaml.Option (Ocaml.Tuple [ Ocaml.Var "tok"; Ocaml.Var "expr" ]);
            Ocaml.Var "tok" ]) ])
and tof_w_variable = Ocaml.add_new_type "w_variable" (Ocaml.Var "lvalue")
and tof_r_variable = Ocaml.add_new_type "r_variable" (Ocaml.Var "lvalue")
and tof_rw_variable = Ocaml.add_new_type "rw_variable" (Ocaml.Var "lvalue")
and tof_obj_dim =
  Ocaml.add_new_type "obj_dim"
    (Ocaml.Sum
       [ ("OName", [ Ocaml.Var "name" ]);
         ("OBrace", [ Ocaml.Apply (("brace", (Ocaml.Var "expr"))) ]);
         ("OArrayAccess",
          [ Ocaml.Var "obj_dim";
            Ocaml.Apply (("bracket", (Ocaml.Option (Ocaml.Var "expr")))) ]);
         ("OBraceAccess",
          [ Ocaml.Var "obj_dim"; Ocaml.Apply (("brace", (Ocaml.Var "expr"))) ]) ])
and tof_obj_property =
  Ocaml.add_new_type "obj_property"
    (Ocaml.Sum
       [ ("ObjProp", [ Ocaml.Var "obj_dim" ]);
         ("ObjPropVar", [ Ocaml.Var "lvalue" ]) ])
and tof_obj_access =
  Ocaml.add_new_type "obj_access"
    (Ocaml.Tuple
       [ Ocaml.Var "tok"; Ocaml.Var "obj_property";
         Ocaml.Option
           (Ocaml.Apply
              (("paren",
                (Ocaml.Apply (("comma_list", (Ocaml.Var "argument"))))))) ])
and tof_argument =
  Ocaml.add_new_type "argument"
    (Ocaml.Sum
       [ ("Arg", [ Ocaml.Var "expr" ]);
         ("ArgRef", [ Ocaml.Var "tok"; Ocaml.Var "w_variable" ]) ])
and tof_indirect =
  Ocaml.add_new_type "indirect"
    (Ocaml.Sum [ ("Dollar", [ Ocaml.Var "tok" ]) ])
and tof_lvaluebis =
  Ocaml.add_new_type "lvaluebis"
    (Ocaml.Sum
       [ ("Var",
          [ Ocaml.Var "dname"; Ocaml.Apply (("ref", (Ocaml.TTODO ""))) ]);
         ("This", [ Ocaml.Var "tok" ]);
         ("VArrayAccess",
          [ Ocaml.Var "lvalue";
            Ocaml.Apply (("bracket", (Ocaml.Option (Ocaml.Var "expr")))) ]);
         ("VArrayAccessXhp",
          [ Ocaml.Var "expr";
            Ocaml.Apply (("bracket", (Ocaml.Option (Ocaml.Var "expr")))) ]);
         ("VBrace",
          [ Ocaml.Var "tok"; Ocaml.Apply (("brace", (Ocaml.Var "expr"))) ]);
         ("VBraceAccess",
          [ Ocaml.Var "lvalue"; Ocaml.Apply (("brace", (Ocaml.Var "expr"))) ]);
         ("Indirect", [ Ocaml.Var "lvalue"; Ocaml.Var "indirect" ]);
         ("VQualifier", [ Ocaml.Var "qualifier"; Ocaml.Var "lvalue" ]);
         ("ClassVar", [ Ocaml.Var "qualifier"; Ocaml.Var "dname" ]);
         ("FunCallSimple",
          [ Ocaml.Var "name";
            Ocaml.Apply
              (("paren",
                (Ocaml.Apply (("comma_list", (Ocaml.Var "argument")))))) ]);
         ("FunCallVar",
          [ Ocaml.Option (Ocaml.Var "qualifier"); Ocaml.Var "lvalue";
            Ocaml.Apply
              (("paren",
                (Ocaml.Apply (("comma_list", (Ocaml.Var "argument")))))) ]);
         ("StaticMethodCallSimple",
          [ Ocaml.Var "qualifier"; Ocaml.Var "name";
            Ocaml.Apply
              (("paren",
                (Ocaml.Apply (("comma_list", (Ocaml.Var "argument")))))) ]);
         ("MethodCallSimple",
          [ Ocaml.Var "lvalue"; Ocaml.Var "tok"; Ocaml.Var "name";
            Ocaml.Apply
              (("paren",
                (Ocaml.Apply (("comma_list", (Ocaml.Var "argument")))))) ]);
         ("StaticMethodCallVar",
          [ Ocaml.Var "lvalue"; Ocaml.Var "tok"; Ocaml.Var "name";
            Ocaml.Apply
              (("paren",
                (Ocaml.Apply (("comma_list", (Ocaml.Var "argument")))))) ]);
         ("StaticObjCallVar",
          [ Ocaml.Var "lvalue"; Ocaml.Var "tok"; Ocaml.Var "lvalue";
            Ocaml.Apply
              (("paren",
                (Ocaml.Apply (("comma_list", (Ocaml.Var "argument")))))) ]);
         ("LateStaticCall",
          [ Ocaml.Var "tok"; Ocaml.Var "tok"; Ocaml.Var "name";
            Ocaml.Apply
              (("paren",
                (Ocaml.Apply (("comma_list", (Ocaml.Var "argument")))))) ]);
         ("ObjAccessSimple",
          [ Ocaml.Var "lvalue"; Ocaml.Var "tok"; Ocaml.Var "name" ]);
         ("ObjAccess", [ Ocaml.Var "lvalue"; Ocaml.Var "obj_access" ]) ])
and tof_lvalue_info =
  Ocaml.add_new_type "lvalue_info"
    (Ocaml.Dict [ ("tlval", `RW, (Ocaml.TTODO "")) ])
and tof_lvalue =
  Ocaml.add_new_type "lvalue"
    (Ocaml.Tuple [ Ocaml.Var "lvaluebis"; Ocaml.Var "lvalue_info" ])
and tof_xhp_body =
  Ocaml.add_new_type "xhp_body"
    (Ocaml.Sum
       [ ("XhpText", [ Ocaml.Apply (("wrap", Ocaml.String)) ]);
         ("XhpExpr", [ Ocaml.Apply (("brace", (Ocaml.Var "expr"))) ]);
         ("XhpNested", [ Ocaml.Var "xhp_html" ]) ])
and tof_xhp_attr_value =
  Ocaml.add_new_type "xhp_attr_value"
    (Ocaml.Sum
       [ ("XhpAttrString",
          [ Ocaml.Var "tok"; Ocaml.List (Ocaml.Var "encaps"); Ocaml.Var "tok" ]);
         ("XhpAttrExpr", [ Ocaml.Apply (("brace", (Ocaml.Var "expr"))) ]);
         ("SgrepXhpAttrValueMvar", [ Ocaml.Apply (("wrap", Ocaml.String)) ]) ])
and tof_xhp_attr_name =
  Ocaml.add_new_type "xhp_attr_name" (Ocaml.Apply (("wrap", Ocaml.String)))
and tof_xhp_attribute =
  Ocaml.add_new_type "xhp_attribute"
    (Ocaml.Tuple
       [ Ocaml.Var "xhp_attr_name"; Ocaml.Var "tok";
         Ocaml.Var "xhp_attr_value" ])
and tof_xhp_html =
  Ocaml.add_new_type "xhp_html"
    (Ocaml.Sum
       [ ("Xhp",
          [ Ocaml.Apply (("wrap", (Ocaml.Var "xhp_tag")));
            Ocaml.List (Ocaml.Var "xhp_attribute"); Ocaml.Var "tok";
            Ocaml.List (Ocaml.Var "xhp_body");
            Ocaml.Apply (("wrap", (Ocaml.Option (Ocaml.Var "xhp_tag")))) ]);
         ("XhpSingleton",
          [ Ocaml.Apply (("wrap", (Ocaml.Var "xhp_tag")));
            Ocaml.List (Ocaml.Var "xhp_attribute"); Ocaml.Var "tok" ]) ])
and tof_obj_prop_access =
  Ocaml.add_new_type "obj_prop_access"
    (Ocaml.Tuple [ Ocaml.Var "tok"; Ocaml.Var "obj_property" ])
and tof_class_name_reference =
  Ocaml.add_new_type "class_name_reference"
    (Ocaml.Sum
       [ ("ClassNameRefStatic", [ Ocaml.Var "class_name_or_selfparent" ]);
         ("ClassNameRefDynamic",
          [ Ocaml.Var "lvalue"; Ocaml.List (Ocaml.Var "obj_prop_access") ]);
         ("ClassNameRefLateStatic", [ Ocaml.Var "tok" ]) ])
and tof_array_pair =
  Ocaml.add_new_type "array_pair"
    (Ocaml.Sum
       [ ("ArrayExpr", [ Ocaml.Var "expr" ]);
         ("ArrayRef", [ Ocaml.Var "tok"; Ocaml.Var "lvalue" ]);
         ("ArrayArrowExpr",
          [ Ocaml.Var "expr"; Ocaml.Var "tok"; Ocaml.Var "expr" ]);
         ("ArrayArrowRef",
          [ Ocaml.Var "expr"; Ocaml.Var "tok"; Ocaml.Var "tok";
            Ocaml.Var "lvalue" ]) ])
and tof_list_assign =
  Ocaml.add_new_type "list_assign"
    (Ocaml.Sum
       [ ("ListVar", [ Ocaml.Var "lvalue" ]);
         ("ListList",
          [ Ocaml.Var "tok";
            Ocaml.Apply
              (("paren",
                (Ocaml.Apply (("comma_list", (Ocaml.Var "list_assign")))))) ]);
         ("ListEmpty", []) ])
and tof_castOp = Ocaml.add_new_type "castOp" (Ocaml.Var "ptype")
and tof_unaryOp =
  Ocaml.add_new_type "unaryOp"
    (Ocaml.Sum
       [ ("UnPlus", []); ("UnMinus", []); ("UnBang", []); ("UnTilde", []) ])
and tof_assignOp =
  Ocaml.add_new_type "assignOp"
    (Ocaml.Sum
       [ ("AssignOpArith", [ Ocaml.Var "arithOp" ]); ("AssignConcat", []) ])
and tof_logicalOp =
  Ocaml.add_new_type "logicalOp"
    (Ocaml.Sum
       [ ("Inf", []); ("Sup", []); ("InfEq", []); ("SupEq", []); ("Eq", []);
         ("NotEq", []); ("Identical", []); ("NotIdentical", []);
         ("AndLog", []); ("OrLog", []); ("XorLog", []); ("AndBool", []);
         ("OrBool", []) ])
and tof_arithOp =
  Ocaml.add_new_type "arithOp"
    (Ocaml.Sum
       [ ("Plus", []); ("Minus", []); ("Mul", []); ("Div", []); ("Mod", []);
         ("DecLeft", []); ("DecRight", []); ("And", []); ("Or", []);
         ("Xor", []) ])
and tof_binaryOp =
  Ocaml.add_new_type "binaryOp"
    (Ocaml.Sum
       [ ("Arith", [ Ocaml.Var "arithOp" ]);
         ("Logical", [ Ocaml.Var "logicalOp" ]); ("BinaryConcat", []) ])
and tof_fixOp =
  Ocaml.add_new_type "fixOp" (Ocaml.Sum [ ("Dec", []); ("Inc", []) ])
and tof_encaps =
  Ocaml.add_new_type "encaps"
    (Ocaml.Sum
       [ ("EncapsString", [ Ocaml.Apply (("wrap", Ocaml.String)) ]);
         ("EncapsVar", [ Ocaml.Var "lvalue" ]);
         ("EncapsCurly",
          [ Ocaml.Var "tok"; Ocaml.Var "lvalue"; Ocaml.Var "tok" ]);
         ("EncapsDollarCurly",
          [ Ocaml.Var "tok"; Ocaml.Var "lvalue"; Ocaml.Var "tok" ]);
         ("EncapsExpr",
          [ Ocaml.Var "tok"; Ocaml.Var "expr"; Ocaml.Var "tok" ]) ])
and tof_cpp_directive =
  Ocaml.add_new_type "cpp_directive"
    (Ocaml.Sum
       [ ("Line", []); ("File", []); ("ClassC", []); ("MethodC", []);
         ("FunctionC", []) ])
and tof_constant =
  Ocaml.add_new_type "constant"
    (Ocaml.Sum
       [ ("Int", [ Ocaml.Apply (("wrap", Ocaml.String)) ]);
         ("Double", [ Ocaml.Apply (("wrap", Ocaml.String)) ]);
         ("String", [ Ocaml.Apply (("wrap", Ocaml.String)) ]);
         ("CName", [ Ocaml.Var "name" ]);
         ("PreProcess",
          [ Ocaml.Apply (("wrap", (Ocaml.Var "cpp_directive"))) ]);
         ("XdebugClass",
          [ Ocaml.Var "name"; Ocaml.List (Ocaml.Var "class_stmt") ]);
         ("XdebugResource", []) ])
and tof_scalar =
  Ocaml.add_new_type "scalar"
    (Ocaml.Sum
       [ ("C", [ Ocaml.Var "constant" ]);
         ("ClassConstant", [ Ocaml.Var "qualifier"; Ocaml.Var "name" ]);
         ("Guil", [ Ocaml.Var "tok" ]);
         ("HereDoc",
          [ Ocaml.Var "tok"; Ocaml.List (Ocaml.Var "encaps"); Ocaml.Var "tok" ]) ])
and tof_exprbis =
  Ocaml.add_new_type "exprbis"
    (Ocaml.Sum
       [ ("Lv", [ Ocaml.Var "lvalue" ]); ("Sc", [ Ocaml.Var "scalar" ]);
         ("Binary",
          [ Ocaml.Var "expr"; Ocaml.Apply (("wrap", (Ocaml.Var "binaryOp")));
            Ocaml.Var "expr" ]);
         ("Unary",
          [ Ocaml.Apply (("wrap", (Ocaml.Var "unaryOp"))); Ocaml.Var "expr" ]);
         ("Assign",
          [ Ocaml.Var "lvalue"; Ocaml.Var "tok"; Ocaml.Var "expr" ]);
         ("AssignOp",
          [ Ocaml.Var "lvalue";
            Ocaml.Apply (("wrap", (Ocaml.Var "assignOp"))); Ocaml.Var "expr" ]);
         ("Postfix",
          [ Ocaml.Var "rw_variable";
            Ocaml.Apply (("wrap", (Ocaml.Var "fixOp"))) ]);
         ("Infix",
          [ Ocaml.Apply (("wrap", (Ocaml.Var "fixOp")));
            Ocaml.Var "rw_variable" ]);
         ("CondExpr",
          [ Ocaml.Var "expr"; Ocaml.Var "tok";
            Ocaml.Option (Ocaml.Var "expr"); Ocaml.Var "tok";
            Ocaml.Var "expr" ]);
         ("AssignList",
          [ Ocaml.Var "tok";
            Ocaml.Apply
              (("paren",
                (Ocaml.Apply (("comma_list", (Ocaml.Var "list_assign"))))));
            Ocaml.Var "tok"; Ocaml.Var "expr" ]);
         ("ConsArray",
          [ Ocaml.Var "tok";
            Ocaml.Apply
              (("paren",
                (Ocaml.Apply (("comma_list", (Ocaml.Var "array_pair")))))) ]);
         ("New",
          [ Ocaml.Var "tok"; Ocaml.Var "class_name_reference";
            Ocaml.Option
              (Ocaml.Apply
                 (("paren",
                   (Ocaml.Apply (("comma_list", (Ocaml.Var "argument"))))))) ]);
         ("Clone", [ Ocaml.Var "tok"; Ocaml.Var "expr" ]);
         ("AssignRef",
          [ Ocaml.Var "lvalue"; Ocaml.Var "tok"; Ocaml.Var "tok";
            Ocaml.Var "lvalue" ]);
         ("AssignNew",
          [ Ocaml.Var "lvalue"; Ocaml.Var "tok"; Ocaml.Var "tok";
            Ocaml.Var "tok"; Ocaml.Var "class_name_reference";
            Ocaml.Option
              (Ocaml.Apply
                 (("paren",
                   (Ocaml.Apply (("comma_list", (Ocaml.Var "argument"))))))) ]);
         ("Cast",
          [ Ocaml.Apply (("wrap", (Ocaml.Var "castOp"))); Ocaml.Var "expr" ]);
         ("CastUnset", [ Ocaml.Var "tok"; Ocaml.Var "expr" ]);
         ("InstanceOf",
          [ Ocaml.Var "expr"; Ocaml.Var "tok";
            Ocaml.Var "class_name_reference" ]);
         ("Eval",
          [ Ocaml.Var "tok"; Ocaml.Apply (("paren", (Ocaml.Var "expr"))) ]);
         ("Lambda", [ Ocaml.Var "lambda_def" ]);
         ("Exit",
          [ Ocaml.Var "tok";
            Ocaml.Option
              (Ocaml.Apply (("paren", (Ocaml.Option (Ocaml.Var "expr"))))) ]);
         ("At", [ Ocaml.Var "tok"; Ocaml.Var "expr" ]);
         ("Print", [ Ocaml.Var "tok"; Ocaml.Var "expr" ]);
         ("BackQuote",
          [ Ocaml.Var "tok"; Ocaml.List (Ocaml.Var "encaps"); Ocaml.Var "tok" ]);
         ("Include", [ Ocaml.Var "tok"; Ocaml.Var "expr" ]);
         ("IncludeOnce", [ Ocaml.Var "tok"; Ocaml.Var "expr" ]);
         ("Require", [ Ocaml.Var "tok"; Ocaml.Var "expr" ]);
         ("RequireOnce", [ Ocaml.Var "tok"; Ocaml.Var "expr" ]);
         ("Empty",
          [ Ocaml.Var "tok"; Ocaml.Apply (("paren", (Ocaml.Var "lvalue"))) ]);
         ("Isset",
          [ Ocaml.Var "tok";
            Ocaml.Apply
              (("paren",
                (Ocaml.Apply (("comma_list", (Ocaml.Var "lvalue")))))) ]);
         ("XhpHtml", [ Ocaml.Var "xhp_html" ]);
         ("Yield", [ Ocaml.Var "tok"; Ocaml.Var "expr" ]);
         ("YieldBreak", [ Ocaml.Var "tok"; Ocaml.Var "tok" ]);
         ("SgrepExprDots", [ Ocaml.Var "info" ]);
         ("ParenExpr", [ Ocaml.Apply (("paren", (Ocaml.Var "expr"))) ]) ])
and tof_exp_info =
  Ocaml.add_new_type "exp_info" (Ocaml.Dict [ ("t", `RW, (Ocaml.TTODO "")) ])
and tof_expr =
  Ocaml.add_new_type "expr"
    (Ocaml.Tuple [ Ocaml.Var "exprbis"; Ocaml.Var "exp_info" ])
  
let tof_entity =
  Ocaml.add_new_type "entity"
    (Ocaml.Sum
       [ ("FunctionE", [ Ocaml.Var "func_def" ]);
         ("ClassE", [ Ocaml.Var "class_def" ]);
         ("InterfaceE", [ Ocaml.Var "interface_def" ]);
         ("StmtListE", [ Ocaml.List (Ocaml.Var "stmt") ]);
         ("MethodE", [ Ocaml.Var "method_def" ]);
         ("ClassConstantE", [ Ocaml.Var "class_constant" ]);
         ("ClassVariableE",
          [ Ocaml.Var "class_variable"; Ocaml.List (Ocaml.Var "modifier") ]);
         ("XhpDeclE", [ Ocaml.Var "xhp_decl" ]);
         ("MiscE", [ Ocaml.List (Ocaml.Var "info") ]) ])
  
let tof_any =
  Ocaml.add_new_type "any"
    (Ocaml.Sum
       [ ("Lvalue", [ Ocaml.Var "lvalue" ]); ("Expr", [ Ocaml.Var "expr" ]);
         ("Stmt2", [ Ocaml.Var "stmt" ]);
         ("StmtAndDef", [ Ocaml.Var "stmt_and_def" ]);
         ("StmtAndDefs", [ Ocaml.List (Ocaml.Var "stmt_and_def") ]);
         ("Toplevel", [ Ocaml.Var "toplevel" ]);
         ("Program", [ Ocaml.Var "program" ]);
         ("Entity", [ Ocaml.Var "entity" ]);
         ("Argument", [ Ocaml.Var "argument" ]);
         ("Parameter", [ Ocaml.Var "parameter" ]);
         ("Parameters",
          [ Ocaml.Apply
              (("paren",
                (Ocaml.Apply (("comma_list", (Ocaml.Var "parameter")))))) ]);
         ("Body",
          [ Ocaml.Apply (("brace", (Ocaml.List (Ocaml.Var "stmt_and_def")))) ]);
         ("ClassStmt", [ Ocaml.Var "class_stmt" ]);
         ("ClassConstant2", [ Ocaml.Var "class_constant" ]);
         ("ClassVariable", [ Ocaml.Var "class_variable" ]);
         ("ListAssign", [ Ocaml.Var "list_assign" ]);
         ("ColonStmt2", [ Ocaml.Var "colon_stmt" ]);
         ("Case2", [ Ocaml.Var "case" ]);
         ("XhpAttribute", [ Ocaml.Var "xhp_attribute" ]);
         ("XhpAttrValue", [ Ocaml.Var "xhp_attr_value" ]);
         ("XhpHtml2", [ Ocaml.Var "xhp_html" ]);
         ("StaticScalar", [ Ocaml.Var "static_scalar" ]);
         ("Info", [ Ocaml.Var "info" ]);
         ("InfoList", [ Ocaml.List (Ocaml.Var "info") ]);
         ("Name2", [ Ocaml.Var "name" ]) ])
  
