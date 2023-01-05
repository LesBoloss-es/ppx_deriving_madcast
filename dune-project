(lang dune 2.5)

(generate_opam_files true)

(package
 (name ppx_deriving_madcast)
 (version 0.1)

 (tags (syntax))
 (synopsis "Library deriving cast functions based on their types")
 (description
  "\| This package provides a PPX that allows to derive cast functions based
  "\| on their types.
  "\|
  "\| For instance, `[%madcast: ('a * string) -> ('a * int)]` would be replaced by:
  "\|
  "\|     fun (x, y) ->
  "\|       (x,
  "\|        try int_of_string y
  "\|        with Failure _ -> failwith \"madcast: string -> int\")
  )

 (source (github LesBoloss-es/ppx_deriving_madcast))

 (license LGPL-3.0-or-later)
 (authors "Kerl <kerl@wkerl.me>" "Niols <niols@niols.fr>")
 (maintainers "Niols <niols@niols.fr>")

 (depends
   ppx_deriving
   ppxlib
  (dune  :build)
  (ocaml :build))
)
