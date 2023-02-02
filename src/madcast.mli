open Ppxlib
open Parsetree

(** {2 Main access point} *)

val derive : core_type -> expression
(** [madcast ty] returns an annotated casting function of type [ty].
    [ty] must be an arrow type.

    - Raise [Invalid_argument "split_arrow"] if [ty] is not an arrow
      type,

    - Raise {!NoCastFound} if no casting function can be derived,

    - Raise {!SeveralCastsFound} if more than one casting function can
      be derived and none of them has a stronger priority. *)

(** {2 Exceptions} *)

exception NoCastFound
(** Exception raised when no cast can be derived for two types *)

exception SeveralCastsFound
(** Exception raised when more than cast can be derived for two types *)

(** {2 Lower-level access points} *)

val find_caster : core_type -> core_type -> expression
(** Given an input type [itype] and an output type [otype], returns a
    casting function of type [itype -> otype].

    - Raise {!NoCastFound} if no casting function can be derived,

    - Raise {!SeveralCastsFound} if more than one casting function can
      be derived and none of them has a stronger priority. *)

val split_arrow : core_type -> (core_type * core_type)
(** [split_arrow ty] returns the domain and co-domain of an arrow
    type.

    - Raise [Invalid_argument "split_arrow"] if [ty] is not an arrow
      type *)

val annotate : expression -> core_type -> expression
(** [annotate expr ty] returns a let expression of the form [let (e :
    ty) = expr in e] *)
