let compile () =
  Format.printf "madcast %% @?" ;
  let line = input_line stdin in
  try
    let itype, otype =
      Lexing.from_string line
      |> Parse.core_type
      |> Madcast.split_arrow
    in
    let cast = Madcast.derive itype otype in
    Format.printf "%a@." Pprintast.expression cast
  with
  | Madcast.NoCastFound -> Format.printf "no cast found!@."
  | Madcast.SeveralCastFound -> Format.printf "Several casts found!@."
  | Invalid_argument msg when msg = "split_arrow" ->
    Format.printf "expected an arrow type!@."
  | exn -> Location.report_exception Format.std_formatter exn


let rec loop () =
  compile () ;
  loop ()


let () =
  try loop ()
  with End_of_file ->
    Format.printf "@." ;
    exit 0
