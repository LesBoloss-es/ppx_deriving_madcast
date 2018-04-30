
open Parsetree

let rec equal_core_type t t' =
  equal_core_type_desc t.ptyp_desc t'.ptyp_desc

and equal_core_type_desc t t' =
  match (t, t') with
  | ( Ptyp_any               , Ptyp_any                  ) -> true
  | ( Ptyp_var v             , Ptyp_var v'               ) -> v = v'
  | ( Ptyp_arrow (l, t1, t2) , Ptyp_arrow (l', t1', t2') ) -> l = l' && equal_core_type t1 t1' && equal_core_type t2 t2'
  | ( Ptyp_tuple tl          , Ptyp_tuple tl'            ) -> List.for_all2 equal_core_type tl tl'
  | ( Ptyp_constr (i, tl)    , Ptyp_constr (i', tl')     ) -> i.txt = i'.txt && List.for_all2 equal_core_type tl tl'
     
  | ( Ptyp_object _          , Ptyp_object _             )
  | ( Ptyp_class _           , Ptyp_class _              )
  | ( Ptyp_alias _           , Ptyp_alias _              )
  | ( Ptyp_variant _         , Ptyp_variant _            )
  | ( Ptyp_poly _            , Ptyp_poly _               )
  | ( Ptyp_package _         , Ptyp_package _            )
  | ( Ptyp_extension _       , Ptyp_extension _          ) -> assert false

  | _ -> false
