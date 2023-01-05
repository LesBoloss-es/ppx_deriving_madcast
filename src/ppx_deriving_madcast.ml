let () = Ppx_deriving.(register (create "madcast" ~core_type:Madcast.derive ()))
