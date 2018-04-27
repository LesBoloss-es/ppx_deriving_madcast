
let () =
  let (a, b) = [%madcast: (string * int) -> (int * string)] ("1", 2) in
  Format.printf "(%d,%s)@." a b

