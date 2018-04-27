
(** When reading [\[%madcast: t\]], we call [core_type] on the type
   [t], and it returns an OCaml expression that will replace it. *)
let core_type _ =
  Format.eprintf "core_type@.";
  assert false

(* Register the deriver "madcast" that only works on "core_type", that
   is on inline statements [%madcast:] *) let () =
   Ppx_deriving.(register (create "madcast" ~core_type ()))
