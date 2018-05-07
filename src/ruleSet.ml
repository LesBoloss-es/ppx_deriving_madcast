
open Parsetree

module IMap = Map.Make(struct type t = int let compare = compare end)
let rules : Rule.t list IMap.t ref = ref IMap.empty

let register rule =
  rules :=
    IMap.add (Rule.priority_ rule) (
      try rule :: IMap.find (Rule.priority_ rule) !rules
      with Not_found -> [rule]
    ) !rules

let fold f =
  IMap.fold
    (fun _ rules x ->
      List.fold_left
        (fun x rule ->
          f rule x)
        x
        rules)
    !rules

let fold_by_priority f =
  IMap.fold
    (fun _ rules x ->
      f rules x)
    !rules
