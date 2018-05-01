
open Parsetree
open Asttypes
open Longident
open Ast_helper
open Location

open Parsetree_utils


module Rule = struct
  type t =
    { name : string ;
      matcher : (core_type * core_type) -> (core_type * core_type) list option ;
      builder : expression list -> expression }

  let rules = Hashtbl.create 8

  let register rule =
    Hashtbl.add rules rule.name rule

  let lookup =
    Hashtbl.find rules

  let fold f =
    Hashtbl.fold (fun _ rule x -> f rule x) rules
end

(* ============================== [ Identity ] ============================== *)

let () =
  let name = "'a -> 'a" in
  let matcher (itype, otype) =
    if equal_core_type itype otype
    then Some []
    else None
  in
  let builder l =
    assert (l = []);
    [%expr fun x -> x]
  in
  Rule.(register { name ; matcher ; builder })

(* ============================= [ Base types ] ============================= *)

let () =
  [ ( "bool -> float",
      [%type: bool], [%type: float],
      [%expr function
          | false -> 0.
          | true -> 1.] );

    ( "bool -> int",
      [%type: bool], [%type: int],
      [%expr function
          | false -> 0
          | true -> 1] );

    ( "bool -> string",
      [%type: bool], [%type: string],
      [%expr string_of_bool] );

    ( "char -> int",
      [%type: char], [%type: int],
      [%expr int_of_char] );

    ( "char -> string" ,
      [%type: char], [%type: string],
      [%expr String.make 1] );

    ( "float -> string",
      [%type: float], [%type: string],
      [%expr string_of_float] );

    ( "int -> bool",
      [%type: int], [%type: bool],
      [%expr function
          | 0 -> false
          | 1 -> true
          | _ -> failwith "madcast: int -> bool"] );

    ( "int -> char",
      [%type: int], [%type: char],
      [%expr fun i ->
          try
            char_of_int i
          with
            Failure _ -> failwith "madcast: int -> char"] );

    ( "int -> float",
      [%type: int], [%type: float],
      [%expr float_of_int] );

    ( "int -> string ",
      [%type: int], [%type: string],
      [%expr string_of_int] );

    ( "string -> bool",
      [%type: string], [%type: bool],
      [%expr fun s ->
          try
            bool_of_string s
          with
            Failure _ -> failwith "madcast: string -> bool"] );

    ( "string -> char",
      [%type: string], [%type: char],
      [%expr fun s ->
          if String.length s = 1 then
            s.[0]
          else
            failwith "madcast: string -> char"] );

    ( "string -> float",
      [%type: string], [%type: float],
      [%expr fun s ->
          try
            float_of_string s
          with
            Failure _ -> failwith "madcast: string -> float"] );

    ( "string -> int",
      [%type: string], [%type: int],
      [%expr fun s ->
          try
            int_of_string s
          with
            Failure _ -> failwith "madcast: string -> int"] ) ]
  |>
    List.iter
      (fun (name, itype, otype, expr) ->
        let matcher (itype', otype') =
          if equal_core_type itype itype' && equal_core_type otype otype'
          then Some []
          else None
        in
        let builder l =
          assert (l = []);
          expr
        in
        Rule.register { name ; matcher ; builder })

(* =========================== [ Array and list ] =========================== *)

let () =
  let name = "'a array -> 'b array" in
  let matcher = function
    | [%type: [%t? itype] array], [%type: [%t? otype] array] -> Some [(itype, otype)]
    | _ -> None
  in
  let builder premises =
    assert (List.length premises = 1);
    [%expr Array.map [%e List.hd premises]]
  in
  Rule.register { name ; matcher ; builder }

let () =
  let name = "'a array -> 'b list" in
  let matcher = function
    | [%type: [%t? itype] array], [%type: [%t? otype] list]  -> Some [(itype, otype)]
    | _ -> None
  in
  let builder premises =
    assert (List.length premises = 1);
    [%expr fun a -> Array.to_list a |> List.map [%e List.hd premises]]
  in
  Rule.register { name ; matcher ; builder }

let () =
  let name = "'a list -> 'b array" in
  let matcher = function
    | [%type: [%t? itype] list], [%type: [%t? otype] array] -> Some [(itype, otype)]
    | _ -> None
  in
  let builder premises =
    assert (List.length premises = 1);
    [%expr fun l -> List.map [%e List.hd premises] |> Array.of_list]
  in
  Rule.register { name ; matcher ; builder }

let () =
  let name = "'a list -> 'b list" in
  let matcher = function
    | [%type: [%t? itype] list], [%type: [%t? otype] list]  -> Some [(itype, otype)]
    | _ -> None
  in
  let builder premises =
    assert (List.length premises = 1);
    [%expr List.map [%e List.hd premises]]
  in
  Rule.register { name ; matcher ; builder }

(* =============================== [ Tuples ] =============================== *)

let () =
  let name = "<tuple> -> <tuple>" in
  let matcher = function
    | {ptyp_desc=Ptyp_tuple itypes} , {ptyp_desc=Ptyp_tuple otypes}
         when List.length itypes = List.length otypes ->
       Some (List.combine itypes otypes)
    | _ -> None
  in
  let builder casters =
    Exp.fun_
      Nolabel None
      (Pat.tuple
         (List.mapi
            (fun i _ ->
              Pat.var
                (mknoloc ("c"^(string_of_int i))))
            casters))
      (Exp.tuple
         (List.mapi
            (fun i caster ->
              Exp.apply
                caster
                [Nolabel, Exp.ident (mknoloc (Lident ("c"^(string_of_int i))))])
            casters))
  in
  Rule.register { name ; matcher ; builder }

(* ================================ [ Main ] ================================ *)

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
