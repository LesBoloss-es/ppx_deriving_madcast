
open Parsetree

(* seriously, this is so dumb *)
let () = Rules.init ()

let rec reverse_possibles = function
  (* changes a list of possibilities in possibilities of lists *)
  | [] -> [[]]
  | possible_heads :: tail_of_possibles ->
     List.map
       (fun possible_tail ->
         List.map
           (fun possible_head ->
             possible_head :: possible_tail)
           possible_heads)
       (reverse_possibles tail_of_possibles)
     |> List.flatten

let rec derive (itype, otype) : expression list =
  Rule.fold_by_priority
    (fun rules -> function
      | [] ->
         (* Empty means that the stronger priorities have found
            nothing. We go through all the rules at our priority,
            apply them and see which ones did succeed. *)
         List.fold_left
           (fun casts rule ->
             match Rule.match_ rule (itype, otype) with
             | None -> (* the rule found nothing *) casts
             | Some premises ->
                (
                  List.map derive premises
                  |> reverse_possibles
                  |> List.map
                       (fun premises ->
                         Rule.build_ rule premises)
                ) @ casts)
           []
           rules
      | _ as casts ->
         (* Non-empty means that the previous priorities have found
            something already, so we let that and do nothing. *)
         casts)
    []

let derive itype otype =
  derive (itype, otype)
  |> List.map
       (fun expr ->
         [%expr ([%e expr] : [%t itype] -> [%t otype])])
