
open Parsetree

type t =
  { name : string ;
    (* priority : int ; *)
    matcher : (core_type * core_type) -> (core_type * core_type) list option ;
    builder : expression list -> expression }

let rules = Hashtbl.create 8

let register rule =
  Hashtbl.add rules rule.name rule

let lookup =
  Hashtbl.find rules

let fold f =
  Hashtbl.fold (fun _ rule x -> f rule x) rules
