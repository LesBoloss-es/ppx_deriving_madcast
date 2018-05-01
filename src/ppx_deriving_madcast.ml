
open Parsetree

(* import rules *)
open Rules

exception CannotCast

let rec derive (itype, otype) : expression =
  (* apply all rules to these types *)
  Rule.fold
    (fun rule casters ->
      match rule.Rule.matcher (itype, otype) with
      | None -> casters
      | Some premises ->
         try
           rule.Rule.builder (List.map derive premises) :: casters
         with
           CannotCast -> casters)
    []
  |>
    function (* check that only caster has been found *)
    | [caster] -> caster
    | _ -> raise CannotCast

let core_type = function
  | [%type: [%t? itype] -> [%t? otype]] ->
     (
       try
         derive (itype, otype)
       with
         CannotCast ->
         Ppx_deriving.(raise_errorf "Cannot cast %s to %s"
                         (string_of_core_type itype)
                         (string_of_core_type otype))
     )
  | _ as t ->
     Ppx_deriving.(raise_errorf "Expected an arrow type, got %s"
                     (string_of_core_type t))

let () = Ppx_deriving.(register (create "madcast" ~core_type ()))
