
let core_type = function
  | [%type: [%t? itype] -> [%t? otype]] ->
     (
       match Madcast.derive itype otype with
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
