
open Parsetree
open Asttypes
open Longident
open Ast_helper
open Location

open Parsetree_utils

module List = struct
  include List

  let mapi2 f al bl =
    let rec mapi2 f i al bl =
      match al , bl with
      | [] , [] -> []
      | a :: al' , b :: bl' -> (f i a b) :: mapi2 f (i+1) al' bl'
      | _ -> assert false
    in
    mapi2 f 0 al bl
end

exception CannotCast of core_type * core_type * string

let rec madcast itype otype =
  match itype , otype with

  (* Identity *)
  | _ , _ when equal_core_type itype otype -> [%expr fun x -> x]

  (* Base types: bool, char, float, int, string *)
  | [%type: bool]   , [%type: char]   -> raise (CannotCast (itype, otype, ""))
  | [%type: bool]   , [%type: float]  -> [%expr function false -> 0. | true -> 1.]
  | [%type: bool]   , [%type: int]    -> [%expr function false -> 0 | true -> 1]
  | [%type: bool]   , [%type: string] -> [%expr string_of_bool]
  | [%type: char]   , [%type: bool]   -> raise (CannotCast (itype, otype, ""))
  | [%type: char]   , [%type: float]  -> raise (CannotCast (itype, otype, ""))
  | [%type: char]   , [%type: int]    -> [%expr int_of_char]
  | [%type: char]   , [%type: string] -> [%expr String.make 1]
  | [%type: float]  , [%type: bool]   -> raise (CannotCast (itype, otype, ""))
  | [%type: float]  , [%type: char]   -> raise (CannotCast (itype, otype, ""))
  | [%type: float]  , [%type: int]    -> raise (CannotCast (itype, otype, ""))
  | [%type: float]  , [%type: string] -> [%expr string_of_float]
  | [%type: int]    , [%type: bool]   -> [%expr function 0 -> false | 1 -> true | _ -> failwith "madcast: int -> bool"]
  | [%type: int]    , [%type: char]   -> [%expr fun i -> try char_of_int i with Failure _ -> failwith "madcast: int -> char"]
  | [%type: int]    , [%type: float]  -> [%expr float_of_int]
  | [%type: int]    , [%type: string] -> [%expr string_of_int]
  | [%type: string] , [%type: bool]   -> [%expr fun s -> try bool_of_string s with Failure _ -> failwith "madcast: string -> bool"]
  | [%type: string] , [%type: char]   -> [%expr fun s -> if String.length s = 1 then s.[0] else failwith "madcast: string -> char"]
  | [%type: string] , [%type: float]  -> [%expr fun s -> try float_of_string s with Failure _ -> failwith "madcast: string -> float"]
  | [%type: string] , [%type: int]    -> [%expr fun s -> try int_of_string s with Failure _ -> failwith "madcast: string -> int"]

  (* Array, list *)
  | [%type: [%t? isubtype] array] , [%type: [%t? osubtype] array] -> [%expr Array.map [%e madcast isubtype osubtype]]
  | [%type: [%t? isubtype] array] , [%type: [%t? osubtype] list]  -> [%expr fun a -> Array.to_list a |> List.map [%e madcast isubtype osubtype]]
  | [%type: [%t? isubtype] list]  , [%type: [%t? osubtype] array] -> [%expr fun l -> List.map [%e madcast isubtype osubtype] l |> Array.of_list]
  | [%type: [%t? isubtype] list]  , [%type: [%t? osubtype] list]  -> [%expr List.map [%e madcast isubtype osubtype]]

  (* tuple to tuple

     check that they are of the same size and that we can cast each
     components. example:

         [%madcast: (string * int) -> (int * string)]

     gives

         (fun (c1,c2) -> (int_of_string c1, string_of_int c2)) *)

  | {ptyp_desc=Ptyp_tuple itypes} , {ptyp_desc=Ptyp_tuple otypes} ->
     (
       if List.length itypes = List.length otypes then
         Exp.fun_
           Nolabel None
           (Pat.tuple
              (List.mapi
                 (fun i _ ->
                   Pat.var
                     (mknoloc ("c"^(string_of_int i))))
                 itypes))
           (Exp.tuple
              (List.mapi2
                 (fun i isubtype osubtype ->
                   Exp.apply
                     (madcast isubtype osubtype)
                     [Nolabel, Exp.ident (mknoloc (Lident ("c"^(string_of_int i))))])
                 itypes otypes))
       else
         raise (CannotCast (itype, otype, "cannot cast tuples of different sizes"))
     )

  | _ -> raise (CannotCast (itype, otype, ""))

(** When reading [\[%madcast: t\]], we call [core_type] on the type
   [t], and it returns an OCaml expression that will replace it. *)
let core_type ptype =
  match ptype.ptyp_desc with
  | Ptyp_arrow (Asttypes.Nolabel, itype, otype) ->
     (
       try
         madcast itype otype
       with
         CannotCast (itype, otype, reason) ->
         Ppx_deriving.(raise_errorf "Cannot cast %s to %s: %s"
                         (string_of_core_type itype)
                         (string_of_core_type otype)
                         reason)
     )
  | _ ->
     failwith "madcast's type must be an arrow from the input type to the output type"

(* Register the deriver "madcast" that only works on "core_type", that
   is on inline statements [%madcast:] *)
let () = Ppx_deriving.(register (create "madcast" ~core_type ()))
