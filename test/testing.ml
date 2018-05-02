type stats = {
  mutable successes : int ;
  mutable fails : int ;
  mutable errors : int
}


let stats = { successes = 0 ; fails = 0 ; errors = 0}

let exceptions = ref []
let add_exn e = exceptions := e :: !exceptions

let fail () =
  Format.eprintf "F@?" ;
  stats.fails <- stats.fails + 1
let success () =
  Format.eprintf ".@?" ;
  stats.successes <- stats.successes + 1
let error () =
  Format.eprintf "E@?" ;
  stats.errors <- stats.errors + 1


let assert_eq expected actual =
  try
    assert (expected = actual) ;
    success ()
  with
  | Assert_failure _ as e ->
    add_exn e ;
    fail ()
  | e ->
    add_exn e ;
    error ()


let finish () =
  stats.fails + stats.errors + stats.successes
  |> Format.eprintf "@\nRan %d tests@." ;
  let all_good = (stats.fails = 0 && stats.errors = 0) in
  if not all_good then begin
    let print e = Format.eprintf "%s@." (Printexc.to_string e) in
    List.iter print !exceptions ;
    Format.eprintf
      "Some tests did not pass: %d fails, %d errors@."
      stats.fails stats.errors ;
    exit 1
  end else begin
    Format.eprintf "All tests successfully passed!@." ;
    exit 0
  end
