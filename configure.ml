(* ocaml ./configure.ml *)
#use "topfind"

#require "unix"

let strip = ref true
let rm = ref ""
let ext = ref ""
let os_type = ref ""
let installed pkg = 0 = Sys.command ("ocamlfind query -qo -qe " ^ pkg)
let errmsg = "usage: " ^ Sys.argv.(0) ^ " [options]"
let api = ref false
let sosa = ref `None
let gwdb = ref `None
let syslog = ref false
let set_api () = api := true
let set_syslog () = syslog := true

let set_sosa_legacy () =
  assert (!sosa = `None);
  sosa := `Legacy

let set_sosa_zarith () =
  assert (!sosa = `None);
  sosa := `Zarith

let set_sosa_num () =
  assert (!sosa = `None);
  sosa := `Num

let set_gwdb_legacy () = assert (!gwdb = `None) ; gwdb := `Legacy
let set_gwdb_versioned () = assert (!gwdb = `None) ; gwdb := `Versioned

let release = ref false

let speclist =
  [
    ("--gwdb-versioned",
     Arg.Unit set_gwdb_versioned,
     "Use versioned backend"
    );
    ( "--gwdb-legacy"
    , Arg.Unit set_gwdb_legacy
    , " Use legacy backend" )
  ; ( "--release"
    , Arg.Set release
    , " Use release profile: no debug informations \
      (defaut: " ^ string_of_bool !release ^ ")" )
  ; ( "--debug"
    , Arg.Clear release
    , " Use dev profile: no optimization, debug informations \
       (default: " ^ string_of_bool (not !release) ^ ")" )
  ; ( "--sosa-legacy"
    , Arg.Unit set_sosa_legacy
    , " Use legacy Sosa module implementation" )
  ; ( "--sosa-num"
    , Arg.Unit set_sosa_num
    , " Use Sosa module implementation based on `num` library" )
  ; ( "--sosa-zarith"
    , Arg.Unit set_sosa_zarith
    , " Use Sosa module implementation based on `zarith` library" )
  ; ( "--syslog"
    , Arg.Unit set_syslog
    , " Log gwd errors using syslog" )
  ]
  |> List.sort compare |> Arg.align

let () =
  Arg.parse speclist failwith errmsg;
  let dune_dirs_exclude = ref "" in
  let exclude_dir s = dune_dirs_exclude := !dune_dirs_exclude ^ " " ^ s in
  let syslog_d, syslog_pkg =
    match !syslog with true -> (" -D SYSLOG", "syslog") | false -> ("", "")
  in
  if !sosa = `None then
    if installed "zarith" then set_sosa_zarith ()
    else if installed "num" then set_sosa_num ()
    else set_sosa_legacy ();
  let sosa_d, sosa_pkg =
    match !sosa with
    | `Legacy ->
        exclude_dir "sosa_num";
        exclude_dir "sosa_zarith";
        ("", "geneweb_sosa_array")
    | `Num ->
        exclude_dir "sosa_array";
        exclude_dir "sosa_zarith";
        (" -D SOSA_NUM ", "geneweb_sosa_num")
    | `Zarith ->
        exclude_dir "sosa_array";
        exclude_dir "sosa_num";
        (" -D SOSA_ZARITH ", "geneweb_sosa_zarith")
    | `None -> assert false
  in
  let gwdb_d, gwdb_pkg =
    match !gwdb with
    | `None
    | `Versioned ->
       " -D GENEWEB_GWDB_VERSIONED", "geneweb.gwdb-versioned"
    | `Legacy ->
      (" -D GENEWEB_GWDB_LEGACY", "geneweb.gwdb-legacy") ;
  in
  let dune_profile = if !release then "release" else "dev" in
  let os_type, os_d, ext, rm, strip =
    match
      let p = Unix.open_process_in "uname -s" in
      let line = input_line p in
      close_in p;
      line
    with
    | ("Linux" | "Darwin" | "FreeBSD") as os_type ->
        (os_type, " -D UNIX", "", "/bin/rm -f", "strip")
    | _ -> ("Win", " -D WINDOWS", ".exe", "rm -f", "true")
  in
  let ch = open_out "Makefile.config" in
  let writeln s = output_string ch @@ s ^ "\n" in
  let var name value = writeln @@ name ^ "=" ^ value in
  writeln @@ "# This file is generated by " ^ Sys.argv.(0) ^ ".";
  var "OS_TYPE" os_type;
  var "STRIP" strip;
  var "RM" rm;
  var "EXT" ext;
  var "GWDB_D" gwdb_d;
  var "OS_D" os_d;
  var "SOSA_D" sosa_d;
  var "SYSLOG_D" syslog_d;
  var "GWDB_PKG" gwdb_pkg;
  var "SOSA_PKG" sosa_pkg;
  var "SYSLOG_PKG" syslog_pkg;
  var "DUNE_DIRS_EXCLUDE" !dune_dirs_exclude;
  var "DUNE_PROFILE" dune_profile;
  close_out ch
