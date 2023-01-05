[%madcast:]
===========

_Madcast_ is a library deriving cast functions based on their types.

## Examples

### Base types

For base types, _Madcast_ uses the functions defined in the standard library:

``` ocaml
[%madcast: int -> string]
```
will simply be replaced by `string_of_int`.

### Parsing positions

Say you have to parse a line of coordinates _x1_, _y1_, _x2_, _y2_, etc. and you want an array of pairs of integers:

```ocaml
let points =
  read_line ()
  |> String.split_on_char ' '
  |> [%madcast: string list -> (int * int) array]
```

### MySQL API

_Madcast_ is primarily meant to be used in conjunction with low level API.
Here is an example with MySQL:

```ocaml
let () =
  let result = Mysql.exec conn "SELECT id, name, surname FROM person WHERE username='johndoe'" in
  let row = Mysql.fetch result
            |> [%madcast: string option array option -> (int * string * string option) option]
  in match row with
  | None -> Format.eprintf "Could not find user `johndoe`@."
  | Some (id, name, None) -> Format.eprintf "%s (%d) has no surname.@." name id
  | Some (id, name, Some surname) -> Format.eprintf "%s (%d) has %s for surname.@." name id surname
```

## Try it yourself!

You can see by yourself the code generated for a given type with `test/show.exe`:

```ocaml
$ dune exec test/show.exe 'string array -> (int * int) array'
fun a  ->
  if ((Array.length a) mod 2) <> 0
  then failwith "madcast: 'a array -> <tuple> array"
  else
    Array.init ((Array.length a) / 2)
      (fun i  ->
         (((fun s  ->
              try int_of_string s
              with | Failure _ -> failwith "madcast: string -> int")
             (a.(0 + (i * 2)))),
           ((fun s  ->
               try int_of_string s
               with | Failure _ -> failwith "madcast: string -> int")
              (a.(1 + (i * 2))))))
```

Actually, if you feel fancy, we recommend adding `ocamlformat` and `bat` to the lot and running:

```
$ dune exec test/show.exe 'string list -> (int * int * float) array' \
      | ocamlformat - --impl --enable-outside-detected-project \
      | bat --language ocaml
```

And if you don't feel like cloning but you love Nix, you can also go for:

```
$ nix run github:LesBoloss-es/ppx_deriving_madcast#show -- 'string array -> (int * int) array'
```

## Installation

### Using OPAM

`ppx_deriving_madcast` is available on OPAM:

``` console
$ opam install ppx_deriving_madcast
```

## API

_Madcast_ also provides an API.
This API is in the package `ppx_deriving_madcast.api`.
Its documentation can be built with `make doc`.

## License

_Madcast_ is distributed under the LGPL License, version 3.
