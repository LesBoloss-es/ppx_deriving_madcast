
let () = Format.printf "%d@." ([%madcast: string -> int] "1")
let () = Format.printf "%s@." ([%madcast: int -> string] 2)

let () =
  let (a, b) = [%madcast: (string * int) -> (int * string)] ("1", 2) in
  Format.printf "(%d,%s)@." a b

let () =
  assert (
      ([%madcast: (string * int) -> (int * string)]
         ([%madcast: (int * string) -> (string * int)] (1, "2")))
      = (1, "2")
    )
