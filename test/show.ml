(** Compile a type to a caster **********************************************)

let compile typ =
  try
    let itype, otype =
      Lexing.from_string typ
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


(** Parse command line arguments ********************************************)

let usage = Format.sprintf "usage: %s <ocaml arrow type>" Sys.argv.(0)

let parse_cmd_line () =
  let typ = ref None in
  let nb_args = ref 0 in
  let set s =
    incr nb_args ;
    match !nb_args with
    | 1 -> typ := Some s
    | _ -> raise (Arg.Bad "Too many arguments")
  in
  Arg.parse [] set usage ;
  match !typ with
  | None ->
    Arg.usage [] usage ;
    exit 1
  | Some typ -> typ



(** Run show.ml *************************************************************)

let () =
  parse_cmd_line () |> compile
