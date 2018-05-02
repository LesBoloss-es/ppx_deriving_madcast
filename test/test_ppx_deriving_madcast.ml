let () =
  let one = [%madcast: string -> int] "1" in
  Testing.assert_eq 1 one

let () =
  let two = [%madcast: int -> string] 2 in
  Testing.assert_eq "2" two

let () =
  let (a, b) = [%madcast: (string * int) -> (int * string)] ("1", 2) in
  Testing.assert_eq (1, "2") (a, b)

let () =
  let arr =
    [|1; 2|] |> [%madcast: int array -> int array]
  in
  (* TODO. add a Testing.array_eq function *)
  Testing.assert_eq 1 arr.(0) ;
  Testing.assert_eq 2 arr.(1)

let () =
  let arr =
    [|1; 2|] |> [%madcast: int array -> string array]
  in
  (* TODO. add a Testing.array_eq function *)
  Testing.assert_eq "1" arr.(0) ;
  Testing.assert_eq "2" arr.(1)

let () =
  [1; 2]
  |> [%madcast: int list -> (int * string)]
  |> Testing.assert_eq (1, "2")

let () =
  let value = (1, "2") in
  value
  |> [%madcast: (int * string) -> (string * int)]
  |> [%madcast: (string * int) -> (int * string)]
  |> Testing.assert_eq value

let () = Testing.finish ()
