
open Parsetree
open Asttypes
open Longident
open Ast_helper
open Location

open Parsetree_utils

let mkpatvar i = Pat.var (mknoloc ("c"^(string_of_int i)))
let mkident i = Exp.ident (mknoloc (Lident ("c"^(string_of_int i))))

(* ============================== [ Identity ] ============================== *)

let () =
  let name = "'a -> 'a" in
  let matcher (itype, otype) =
    if equal_core_type itype otype
    then Some []
    else None
  in
  let builder casts =
    assert (casts = []);
    [%expr fun x -> x]
  in
  Rule.(register (make ~name ~priority:min_int ~matcher ~builder ()))

(* ============================= [ Base types ] ============================= *)

let () =
  [ ( "bool -> float",
      [%type: bool], [%type: float],
      [%expr function
          | false -> 0.
          | true -> 1.] );

    ( "bool -> int",
      [%type: bool], [%type: int],
      [%expr function
          | false -> 0
          | true -> 1] );

    ( "bool -> string",
      [%type: bool], [%type: string],
      [%expr string_of_bool] );

    ( "char -> int",
      [%type: char], [%type: int],
      [%expr int_of_char] );

    ( "char -> string" ,
      [%type: char], [%type: string],
      [%expr String.make 1] );

    ( "float -> string",
      [%type: float], [%type: string],
      [%expr string_of_float] );

    ( "int -> bool",
      [%type: int], [%type: bool],
      [%expr function
          | 0 -> false
          | 1 -> true
          | _ -> failwith "madcast: int -> bool"] );

    ( "int -> char",
      [%type: int], [%type: char],
      [%expr fun i ->
          try
            char_of_int i
          with
            Failure _ -> failwith "madcast: int -> char"] );

    ( "int -> float",
      [%type: int], [%type: float],
      [%expr float_of_int] );

    ( "int -> string",
      [%type: int], [%type: string],
      [%expr string_of_int] );

    ( "string -> bool",
      [%type: string], [%type: bool],
      [%expr fun s ->
          try
            bool_of_string s
          with
            Failure _ -> failwith "madcast: string -> bool"] );

    ( "string -> char",
      [%type: string], [%type: char],
      [%expr fun s ->
          if String.length s = 1 then
            s.[0]
          else
            failwith "madcast: string -> char"] );

    ( "string -> float",
      [%type: string], [%type: float],
      [%expr fun s ->
          try
            float_of_string s
          with
            Failure _ -> failwith "madcast: string -> float"] );

    ( "string -> int",
      [%type: string], [%type: int],
      [%expr fun s ->
          try
            int_of_string s
          with
            Failure _ -> failwith "madcast: string -> int"] ) ]
  |>
    List.iter
      (fun (name, itype, otype, expr) ->
        let matcher (itype', otype') =
          if equal_core_type itype itype' && equal_core_type otype otype'
          then Some []
          else None
        in
        let builder casts =
          assert (casts = []);
          expr
        in
        Rule.(register (make ~name ~matcher ~builder ())))

(* ============================== [ Options ] =============================== *)

let () =
  let name = "'a option -> 'b option" in
  let matcher = function
    | [%type: [%t? itype] option], [%type: [%t? otype] option] ->
       Some [itype, otype]
    | _ -> None
  in
  let builder casts =
    assert (List.length casts = 1);
    [%expr function
        | None -> None
        | Some x -> Some ([%e List.hd casts] x)]
  in
  Rule.(register (make ~name ~matcher ~builder ()))

let () =
  let name = "'a -> 'b option" in
  let matcher = function
    | itype, [%type: [%t? otype] option] ->
       Some [itype, otype]
    | _ -> None
  in
  let builder casts =
    assert (List.length casts = 1);
    [%expr fun x -> Some ([%e List.hd casts] x)]
  in
  (* slightly lower priority that 'a option -> 'b option *)
  Rule.(register (make ~name ~priority:1 ~matcher ~builder ()))

let () =
  let name = "'a option -> 'b" in
  let matcher = function
    | [%type: [%t? itype] option], otype ->
       Some [itype, otype]
    | _ -> None
  in
  let builder casts =
    assert (List.length casts = 1);
    [%expr function
        | None -> failwith "madcast: 'a option -> 'b"
        | Some x -> [%e List.hd casts] x]
  in
  Rule.(register (make ~name ~priority:1 ~matcher ~builder ()))

(* =============================== [ Arrays ] =============================== *)

let () =
  let name = "'a array -> 'b array" in
  let matcher = function
    | [%type: [%t? itype] array], [%type: [%t? otype] array] ->
       Some [itype, otype]
    | _ -> None
  in
  let builder casts =
    assert (List.length casts = 1);
    [%expr Array.map [%e List.hd casts]]
  in
  Rule.(register (make ~name ~matcher ~builder ()))

let () =
  let name = "'a -> 'b array" in
  let matcher = function
    | itype, [%type: [%t? otype] array] ->
       Some [itype, otype]
    | _ -> None
  in
  let builder casts =
    assert (List.length casts = 1);
    [%expr fun x -> [|[%e List.hd casts] x|]]
  in
  Rule.(register (make ~name ~priority:200 ~matcher ~builder ())) (* low priority *)

let () =
  let name = "'a array -> 'b" in
  let matcher = function
    | [%type: [%t? itype] array], otype ->
       Some [itype, otype]
    | _ -> None
  in
  let builder casts =
    assert (List.length casts = 1);
    [%expr fun a ->
        if Array.length a = 1 then
          [%e List.hd casts] a.(0)
        else
          failwith "madcast: 'a array -> 'b"]
  in
  Rule.(register (make ~name ~priority:201 ~matcher ~builder ())) (* low priority *)

let () =
  let name = "<tuple> -> 'b array" in
  let matcher = function
    | {ptyp_desc=Ptyp_tuple itypes}, [%type: [%t? otype] array] ->
       Some (List.map (fun itype -> (itype, otype)) itypes)
    | _ -> None
  in
  let builder casts =
    (* fun (c0,...ck) -> [|cast0 c0; ... castk ck|] *)
    Exp.fun_
      Nolabel None
      (Pat.tuple (List.mapi (fun i _ -> mkpatvar i) casts))
      (Exp.array (List.mapi (fun i cast -> Exp.apply cast [Nolabel, mkident i]) casts))
  in
  Rule.(register (make ~name ~matcher ~builder ()))

let () =
  let name = "'a array -> <tuple>" in
  let matcher = function
    | [%type: [%t? itype] array], {ptyp_desc=Ptyp_tuple otypes} ->
       Some (List.map (fun otype -> (itype, otype)) otypes)
    | _ -> None
  in
  let builder casts =
    (* function
       | [|c0;...ck|] -> (cast0 c0, ... castk ck)
       | _ -> failwith ... *)
    Exp.function_
      [ Exp.case
          (Pat.array (List.mapi (fun i _ -> mkpatvar i) casts))
          (Exp.tuple (List.mapi (fun i cast -> Exp.apply cast [Nolabel, mkident i]) casts)) ;
        Exp.case
          (Pat.any ())
          [%expr failwith "madcast: 'a array -> <tuple>"] ]
  in
  Rule.(register (make ~name ~matcher ~builder ()))

let () =
  let name = "<tuple> array -> 'a array" in
  let matcher = function
    | [%type: [%t? {ptyp_desc=Ptyp_tuple itypes}] array], [%type: [%t? otype] array] ->
       Some [Typ.tuple itypes, [%type: [%t otype] array]]
    | _ -> None
  in
  let builder casts =
    assert (List.length casts = 1);
    [%expr fun a ->
        Array.map [%e List.hd casts] a
        |> Array.to_list
        |> Array.concat]
  in
  Rule.(register (make ~name ~priority:100 ~matcher ~builder ())) (* low priority *)

let () =
  let name = "'a array -> <tuple> array" in
  let matcher = function
    | [%type: [%t? itype] array], [%type: [%t? {ptyp_desc=Ptyp_tuple otypes}] array] ->
       Some (List.map (fun otype -> (itype, otype)) otypes)
    | _ -> None
  in
  let builder casts =
    let l = List.length casts in
    let exp_int n = Exp.constant (Const.int n) in
    [%expr fun a ->
        if Array.length a mod [%e exp_int l] <> 0 then
          failwith "madcast: 'a array -> <tuple> array"
        else
          Array.init (Array.length a / [%e exp_int l])
            (fun i ->
              [%e Exp.tuple
                  (List.mapi
                     (fun j cast ->
                       [%expr [%e cast] a.([%e exp_int j] + i * [%e exp_int l])])
                     casts)])]
  in
  Rule.(register (make ~name ~priority:101 ~matcher ~builder ())) (* low priority *)

(* =============================== [ Lists ] ================================ *)
(* using the rules for arrays *)

let () =
  let name = "'a list -> 'a array -> 'b" in
  let matcher = function
    | [%type: [%t? itype] list], otype ->
       Some [[%type: [%t itype] array], otype]
    | _ -> None
  in
  let builder casts =
    assert (List.length casts = 1);
    [%expr fun l -> Array.of_list l |> [%e List.hd casts]]
  in
  Rule.(register (make ~name ~priority:(-100) ~matcher ~builder ())) (* high priority *)

let () =
  let name = "'a -> 'b array -> 'b list" in
  let matcher = function
    | itype, [%type: [%t? otype] list] ->
       Some [itype, [%type: [%t otype] array]]
    | _ -> None
  in
  let builder casts =
    assert (List.length casts = 1);
    [%expr fun x -> [%e List.hd casts] x |> Array.to_list]
  in
  Rule.(register (make ~name ~priority:(-101) ~matcher ~builder ())) (* high priority *)

(* =============================== [ Tuples ] =============================== *)

let () =
  let name = "<tuple> -> <tuple>" in
  let matcher = function
    | {ptyp_desc=Ptyp_tuple itypes} , {ptyp_desc=Ptyp_tuple otypes}
         when List.length itypes = List.length otypes ->
       Some (List.combine itypes otypes)
    | _ -> None
  in
  let builder casts =
    (* fun (c0,...ck) -> (cast0 c0, ... castk ck) *)
    Exp.fun_
      Nolabel None
      (Pat.tuple (List.mapi (fun i _ -> mkpatvar i) casts))
      (Exp.tuple (List.mapi (fun i cast -> Exp.apply cast [Nolabel, mkident i]) casts))
  in
  Rule.(register (make ~name ~matcher ~builder ()))

(* seriously, this is so dumb *)
let init () = ()
