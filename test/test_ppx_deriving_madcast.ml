
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
  let arr = [|1; 2|] in
  arr
  |> [%madcast: int array -> int array]
  |> Testing.assert_array_eq arr

let () =
  [|1; 2|]
  |> [%madcast: int array -> string array]
  |> Testing.assert_array_eq [|"1"; "2"|]

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

let () =
  Some 1
  |> [%madcast: int option -> int]
  |> Testing.assert_eq 1

let () =
  Some "2"
  |> [%madcast: string option -> int]
  |> Testing.assert_eq 2

let () =
  [| "1"; "Pierre"; "7" |]
  |> [%madcast: string array -> (int * string * int)]
  |> Testing.assert_eq (1, "Pierre", 7)

let () =
  [| Some "3"; Some "Paul"; Some "7" |]
  |> [%madcast: string option array -> (int * string * string option)]
  |> Testing.assert_eq (3, "Paul", Some "7")

let () =
  [| Some [| Some "1" ; Some "Pierre" ; Some "7" |] ;
     Some [| Some "3" ; Some "Paul" ; None |] ;
     None |]
  |> [%madcast: string option array option array -> (int * string * string option) option list]
  |> Testing.assert_eq [ Some (1, "Pierre", Some "7") ;
                         Some (3, "Paul", None) ;
                         None ]

let () =
  [| "1"; "2"; "3"; "4"; "5"; "6" |]
  |> [%madcast: string array -> (int * int) list]
  |> Testing.assert_eq [ (1,2); (3,4); (5,6) ]

let () = Testing.finish ()
