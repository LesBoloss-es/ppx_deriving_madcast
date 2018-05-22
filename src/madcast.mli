open Parsetree

exception NoCastFound
(** Exception raised when no cast can be derived for two types *)

exception SeveralCastFound
(** Exception raised when more than cast can be derived for two types *)


val derive : core_type -> core_type -> expression
(** Given an input type [itype] and an output type [otype], returns a
    casting function of type [itype -> otype].
    Raise [NoCastFound] if no casting function can be derived
    Raise [SeveralCastFound] more than one casting function can be derived *)

val split_arrow : core_type -> (core_type * core_type)
(** [split_arrow ty] returns the domain and co-domain of an arrow type.
    Raise [Invalid_argument "split_arrow"] if [ty] is not an arrow type *)

val annotate : expression -> core_type -> expression
(** [annotate expr ty] returns a let expression of the form
    [let (e : ty) = expr in e] *)

val madcast : core_type -> expression
(** [madcast ty] returns an annotated casting function of type [ty].
    [ty] must be an arrow type. *)
