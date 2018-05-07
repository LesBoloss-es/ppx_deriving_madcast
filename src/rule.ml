
open Parsetree

type t =
  { name : string ;
    priority : int ;
    matcher : (core_type * core_type) -> (core_type * core_type) list option ;
    builder : expression list -> expression }

let make ~name ?(priority=0) ~matcher ~builder () =
  { name ; priority ; matcher ; builder }

let name_ rule = rule.name
let priority_ rule = rule.priority
let match_ rule = rule.matcher
let build_ rule = rule.builder
