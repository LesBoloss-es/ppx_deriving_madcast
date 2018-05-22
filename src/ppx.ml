
let core_type t = Madcast.madcast t

let () = Ppx_deriving.(register (create "madcast" ~core_type ()))
