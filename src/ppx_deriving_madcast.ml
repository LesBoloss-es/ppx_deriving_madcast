
open Parsetree

(* import rules *)
open Rules

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
  Rule.fold
    (fun rule casts ->
      match Rule.match_ rule (itype, otype) with
      | None -> casts
      | Some premises ->
         (
           List.map derive premises
           |> reverse_possibles
           |> List.map
                (fun premises ->
                  Rule.build rule premises)
         ) @ casts)
    []

let core_type = function
  | [%type: [%t? itype] -> [%t? otype]] ->
     (
       match derive (itype, otype) with
       | [cast] -> cast
       | [] ->
          Ppx_deriving.(raise_errorf "No cast found for %s -> %s"
                          (string_of_core_type itype)
                          (string_of_core_type otype))
       | _ ->
          Ppx_deriving.(raise_errorf "Several casts found for %s -> %s"
                          (string_of_core_type itype)
                          (string_of_core_type otype))
     )
  | _ as t ->
     Ppx_deriving.(raise_errorf "Expected an arrow type, got %s"
                     (string_of_core_type t))

let () = Ppx_deriving.(register (create "madcast" ~core_type ()))
