
open Parsetree

type t =
  { name : string ;
    priority : int ;
    matcher : (core_type * core_type) -> (core_type * core_type) list option ;
    builder : expression list -> expression }

let make ~name ?(priority=0) ~matcher ~builder () =
  { name ; priority ; matcher ; builder }

let get_name rule = rule.name
let match_ rule = rule.matcher
let build rule = rule.builder

let rules = Hashtbl.create 8

let register rule =
  Hashtbl.add rules rule.name rule

let fold f =
  Hashtbl.fold (fun _ rule x -> f rule x) rules
