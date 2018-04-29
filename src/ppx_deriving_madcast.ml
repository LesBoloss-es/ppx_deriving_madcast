open Parsetree
open Asttypes
open Longident
let mknoloc = Location.mknoloc

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
            
exception CantCast of core_type * core_type * string

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

  | {ptyp_desc=Ptyp_tuple itypes; _} , {ptyp_desc=Ptyp_tuple otypes; _} ->
     (
       if List.length itypes = List.length otypes then
         { pexp_desc =
             Pexp_fun (
                 Nolabel ,
                 None ,
                 (* function that matches a tuple (c1,c2,...,cn) as
                    argument *)
                 { ppat_desc = Ppat_tuple (
                     List.mapi (fun i _ ->
                       { ppat_desc =
                           Ppat_var (mknoloc ("c"^(string_of_int i))) ;
                         ppat_loc = Location.none ;
                         ppat_attributes = [] })
                       itypes
                     ) ;
                   ppat_loc = Location.none ;
                   ppat_attributes = [] } ,
                 (* and that return a tuple of the same size... *)
                 { pexp_desc = Pexp_tuple (
                     List.mapi2 (fun i isubtype osubtype ->
                       { pexp_desc =
                           (* ...and each component of the tuple is
                              the madcast for the subtypes applied to
                              the right argument *)
                           Pexp_apply (
                               madcast isubtype osubtype,
                               [(Nolabel, { pexp_desc = Pexp_ident (mknoloc (Lident ("c"^(string_of_int i)))) ;
                                            pexp_loc = Location.none ;
                                            pexp_attributes = [] })]
                             ) ;
                         pexp_loc = Location.none ;
                         pexp_attributes = [] })
                       itypes otypes) ;
                   pexp_loc = Location.none ;
                   pexp_attributes = [] }
               ) ;
           pexp_loc = Location.none ;
           pexp_attributes = [] }
       else
         raise (CantCast (itype, otype, "cannot cast tuples of different sizes"))
     )
    
  | _ -> raise (CantCast (itype, otype, ""))

(** When reading [\[%madcast: t\]], we call [core_type] on the type
   [t], and it returns an OCaml expression that will replace it. *)
let core_type ptype =
  match ptype.ptyp_desc with
  | Ptyp_arrow (Asttypes.Nolabel, itype, otype) ->
     (
       try
         madcast itype otype
       with
       | CantCast (itype, otype, reason) ->
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
