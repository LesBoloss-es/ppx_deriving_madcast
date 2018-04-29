
open Parsetree
open Asttypes
open Longident
open Ast_helper
open Location
   
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
  | [%type: string] , [%type: int] -> [%expr int_of_string]
  | [%type: int] , [%type: string] -> [%expr string_of_int]

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
       | CannotCast (itype, otype, reason) ->
          Ppx_deriving.(
           raise_errorf
             "Cannot cast %s to %s: %s"
             (string_of_core_type itype)
             (string_of_core_type otype)
             reason
          )
     )
  | _ ->
     failwith "madcast's type must be an arrow from the input type to the output type"

(* Register the deriver "madcast" that only works on "core_type", that
   is on inline statements [%madcast:] *)
let () = Ppx_deriving.(register (create "madcast" ~core_type ()))
