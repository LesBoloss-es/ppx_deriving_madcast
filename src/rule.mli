
open Parsetree

type t

val make : name:string -> ?priority:int ->
           matcher:((core_type * core_type) -> (core_type * core_type) list option) ->
           builder:(expression list -> expression) ->
           unit -> t

val get_name : t -> string
val match_ : t -> (core_type * core_type) -> (core_type * core_type) list option
val build : t -> expression list -> expression

val register : t -> unit

val fold : (t -> 'a -> 'a) -> 'a -> 'a
