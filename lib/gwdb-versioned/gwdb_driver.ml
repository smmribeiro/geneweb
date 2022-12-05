
module Log = struct
  let oc : out_channel option ref = ref None

  let log fn =
    match !oc with
    | Some oc -> fn oc
    | None -> ()

  type level =
    [ `LOG_ALERT
    | `LOG_CRIT
    | `LOG_DEBUG
    | `LOG_EMERG
    | `LOG_ERR
    | `LOG_INFO
    | `LOG_NOTICE
    | `LOG_WARNING
    ]

  let syslog (level : level) msg =
    let flags = [`LOG_PERROR] in
    let log = Syslog.openlog ~flags @@ Filename.basename @@ Sys.executable_name in
    Syslog.syslog log level msg ;
    Syslog.closelog log ;
    Printexc.print_backtrace stderr
(*  let log msg =
    let tm = Unix.(time () |> localtime) in
    let level = "DEBUG" in
    Printf.eprintf "[%s]: %s %s\n"
      (Mutil.sprintf_date tm : Adef.safe_string :> string) level msg
  (*let log = Syslog.openlog ~flags @@ Filename.basename @@ Sys.executable_name in
    Syslog.syslog log level msg ;
    Syslog.closelog log ;
    if !debug then Printexc.print_backtrace stderr *)*)
end

(*let log msg = Log.syslog Log.(`LOG_DEBUG) msg*)
let log _ = ()

module type Data = sig
  type t
  type index = int
  type base
  val patch_file : base -> string
  val data_file : base -> string
  val directory : base -> string
end

module Store (D : Data) : sig
  val get : D.base -> D.index -> D.t option
  val set : D.base -> D.index -> D.t -> unit
  val unsafe_set : D.index -> D.t -> unit
  val write : D.base -> unit
  val sync : D.base -> unit
  val empty : unit -> unit
end = struct

  type t = (D.index, D.t) Hashtbl.t

  let patch_ht : (D.index, D.t) Hashtbl.t option ref = ref None

  let patch_file_exists base = Sys.file_exists (D.patch_file base)
  let data_file_exists base = Sys.file_exists (D.data_file base)
  let directory_exists base = Sys.file_exists (D.directory base)

  let create_files base = Files.mkdir_p (D.directory base)

  let load base =
    if patch_file_exists base then
      let file = D.patch_file base in
      let ic = Secure.open_in file in
      let tbl = (Marshal.from_channel ic : t) in
      close_in ic;
      patch_ht := Some tbl;
      tbl
    else begin
      let tbl = Hashtbl.create 1 in
      patch_ht := Some tbl;
      tbl
    end

  let patch base = match !patch_ht with
    | Some ht -> ht
    | None -> load base
  
  let get_from_data_file base index =
    if data_file_exists base then assert false
    else None

  let get base index =
    match Hashtbl.find_opt (patch base) index with
    | Some _v as value -> value
    | None -> get_from_data_file base index

  let set base index value =
    let tbl = patch base in
    Hashtbl.replace tbl index value

  let unsafe_set index value =
    let tbl = Option.get !patch_ht in
    Hashtbl.replace tbl index value
  
  let write base =
    let tbl = patch base in
    if not (directory_exists base) then create_files base;
    let patchfile = D.patch_file base in
    let patchfile_tmp = patchfile ^ "~" in
    if Sys.file_exists patchfile_tmp then failwith "oups";
    let oc = Secure.open_out patchfile_tmp in
    Marshal.to_channel oc tbl [Marshal.No_sharing];
    close_out oc;
    Files.mv patchfile_tmp patchfile;
    Files.rm patchfile_tmp

  let empty () = patch_ht := Some (Hashtbl.create 1)

  let load_data base : D.t array =
    if not (data_file_exists base) then [||]
    else begin
      let ic = Secure.open_in (D.data_file base) in
      let len = input_binary_int ic in
      seek_in ic len;
      let rec loop l =
        let l = try (Marshal.from_channel ic : t) :: l
          with
      in
      loop [];
      assert false
    end
  
  let sync base =
    if not (directory_exists base) then create_files base;
    let tbl = patch base in
    let data = load_data base in
    let dfile = D.data_file base in
    let dfile_tmp = dfile ^ "~" in
    let oc = Secure.open_out dfile_tmp in

    let syncdata = Hashtbl.create (Array.length data) in
    Array.iteri (Hashtbl.add syncdata) data;
    Hashtbl.iter (Hashtbl.replace syncdata) tbl;
    let len = Hashtbl.length syncdata in
    let accesses = Array.make len 0 in

    let l = Hashtbl.fold (fun k v l -> (k, v) :: l) syncdata [] in
    let a = Array.of_list l in
    Array.sort (fun (k, _) (k',_) -> k - k') a;
    let a = Array.map snd a in
    
    output_binary_int oc len;
    seek_out oc (4 + len * 4);
    Array.iteri (fun i data ->
        let pos = pos_out oc in
        Marshal.to_channel oc data [Marshal.No_sharing];
        accesses.(i) <- pos
      ) a;
    seek_out oc 4;
    Array.iter (output_binary_int oc) accesses;
    close_out oc;
    Files.mv dfile_tmp dfile;
    Files.rm dfile_tmp;
    Files.rm (D.patch_file base)
    
end

module Legacy_driver = struct

  include Gwdb_legacy.Gwdb_driver
  
  let compatibility_directory = "gnwb25"
  let compatibility_file = "witness_notes"
  let fcompatibility_file = "fwitness_notes"
  let data_file = "witness_notes.dat"
  let fdata_file = "fwitness_notes.dat"

  module PersonData = struct
      type t = istr array array
      type index = iper
      type base = Gwdb_legacy.Gwdb_driver.base
      let directory base = Filename.concat (bdir base) compatibility_directory
      let patch_file base = Filename.concat (directory base) compatibility_file
      let data_file base = Filename.concat (directory base) data_file
    end
  module PatchPer = Store (PersonData)

  module FamilyData = struct
    type t = istr array array
    type index = ifam
    type base = Gwdb_legacy.Gwdb_driver.base
    let directory base = Filename.concat (bdir base) compatibility_directory
    let patch_file base = Filename.concat (directory base) fcompatibility_file
    let data_file base = Filename.concat (directory base) fdata_file
  end
  module PatchFam = Store (FamilyData)

  let versions = Version.([gnwb20;gnwb21;gnwb22;gnwb23;gnwb24])

  type pers_event = (iper, istr) Def.gen_pers_event

  type fam_event = (iper, istr) Def.gen_fam_event

  type person = {
      person : Gwdb_legacy.Gwdb_driver.person;
      witness_notes : istr array array
    }

  type family = {
      family : Gwdb_legacy.Gwdb_driver.family;
      witness_notes : istr array array
    }
       
  let gen_person_of_person p =
    let gen_pers = gen_person_of_person p.person in
    let pevents =
      List.mapi (fun ie pe ->
          let pe = Translate.legacy_to_def_pevent empty_string pe in
          let epers_witnesses =
            Array.mapi (fun iw (ip, wk, _) ->
                ip, wk, p.witness_notes.(ie).(iw)) pe.epers_witnesses
          in
          {pe with epers_witnesses}
        ) gen_pers.pevents
    in
    let gen_pers = Translate.legacy_to_def_person empty_string gen_pers in
    {gen_pers with pevents}
                             
  let person_of_gen_person base (genpers, gen_ascend, gen_union) =
    let pevents = genpers.Def.pevents in
    let witness_notes =
      List.map (fun pe ->
          Array.map (fun (_,_,wnote) -> wnote) pe.Def.epers_witnesses
        ) pevents |> Array.of_list
    in
    let genpers = Translate.as_legacy_person genpers in
    let person = person_of_gen_person base (genpers, gen_ascend, gen_union) in
    {person; witness_notes}

  let no_person iper =
    let nop = no_person iper in
    Translate.legacy_to_def_person empty_string nop


  let test_on_person base genpers =
    let pers_events = genpers.Def.pevents in
    List.iter (fun pers_event ->
        let witnesses = pers_event.Def.epers_witnesses in
        let wnotes = Array.map (fun (_ip, _wk, wnote) -> sou base wnote) witnesses in
        Array.iter (log) wnotes
      ) pers_events

  let witness_notes_of_events pevents =
    Array.of_list @@ List.map (fun pe ->
        Array.map (fun (_,_,wnote) -> wnote) pe.Def.epers_witnesses)
      pevents

  let fwitness_notes_of_events fevents =
    Array.of_list @@ List.map (fun fe ->
        Array.map (fun (_,_,wnote) -> wnote) fe.Def.efam_witnesses)
      fevents
  
  let patch_person base iper genpers =
    log @@ "PATCH PERSON" ^ (string_of_int iper);
    test_on_person base genpers;
    log "LETS PATCH";
    let pevents = genpers.pevents in
    let genpers = Translate.as_legacy_person genpers in
    patch_person base iper genpers;
    let witnotes = witness_notes_of_events pevents in
    PatchPer.set base iper witnotes

  let insert_person base iper genpers =
    log "INSERT PERSON";
    test_on_person base genpers;
    log "LETS INSERT";
    let pevents = genpers.pevents in
    let genpers = Translate.as_legacy_person genpers in
    insert_person base iper genpers;
    let witnotes = witness_notes_of_events pevents in
    PatchPer.set base iper witnotes

  let commit_patches base =
    log "COMMIT LEGACY PATCHES";
    commit_patches base;
    log "COMMIT NOTES PATCHES";
    PatchPer.write base;
    PatchFam.write base

  let get_pevents p =
    let pevents = get_pevents p.person in
    let pevents =
      List.mapi (fun i pe ->
          let pe = Translate.legacy_to_def_pevent empty_string pe in
          let wnotes = p.witness_notes.(i) in
          let witnesses = Array.mapi (fun i (ip, wk, _) -> ip, wk, wnotes.(i)) pe.epers_witnesses in
          {pe with epers_witnesses = witnesses}
        ) pevents in
    pevents

  let get_fevents f =
    let fevents = get_fevents f.family in
    let fevents =
      List.mapi (fun i fe ->
          let fe = Translate.legacy_to_def_fevent empty_string fe in
          let wnotes = f.witness_notes.(i) in
          let witnesses = Array.mapi (fun i (ip, wk, _) -> ip, wk, wnotes.(i)) fe.efam_witnesses in
          {fe with efam_witnesses = witnesses}
        ) fevents in
    fevents

  (* TODO : properly sync *)
  let sync ?(scratch=false) ~save_mem base =
    sync ~scratch ~save_mem base;
    PatchPer.sync base;
    PatchFam.sync base
  
  let make bname particles ((persons, ascends, unions), (families, couples, descends), string_arrays, base_notes) =
    (*let persons = Array.map Translate.as_legacy_person persons in
      let families = Array.map Translate.as_legacy_family families in*)
    PatchPer.empty ();
    PatchFam.empty ();
    let persons = Array.map (fun p ->
        let leg_person = Translate.as_legacy_person p in
        PatchPer.unsafe_set p.key_index (witness_notes_of_events p.pevents);
        leg_person
      ) persons in
    let families = Array.map (fun f ->
        let leg_family = Translate.as_legacy_family f in
        PatchPer.unsafe_set f.fam_index (fwitness_notes_of_events f.fevents);
        leg_family
      ) families in
    let base = make bname particles ((persons, ascends, unions), (families, couples, descends), string_arrays, base_notes) in
    (* TODO : properly sync *)
    PatchPer.sync base;
    PatchFam.sync base;
    base


  let open_base bname =
    log @@ "BNAME:" ^ bname;
    let base = open_base bname in
    log @@ "Bdir:" ^ bdir base;
    base

  let close_base base =
    log "CLOSING THE BASE";
    close_base base

  let empty_person base iper =
    let p = empty_person base iper in
    {person = p; witness_notes = [||]}
    
  let get_access p = get_access p.person
  let get_aliases p = get_aliases p.person
  let get_baptism p = get_baptism p.person
  let get_baptism_note p = get_baptism_note p.person
  let get_baptism_place p = get_baptism_place p.person
  let get_baptism_src p = get_baptism_src p.person
  let get_birth p = get_birth p.person
  let get_birth_note p = get_birth_note p.person
  let get_birth_place p = get_birth_place p.person
  let get_birth_src p = get_birth_src p.person
  let get_death p = get_death p.person
  let get_death_note p = get_death_note p.person
  let get_death_place p = get_death_place p.person
  let get_death_src p = get_death_src p.person
  let get_burial p = get_burial p.person
  let get_burial_note p = get_burial_note p.person
  let get_burial_place p = get_burial_place p.person
  let get_burial_src p = get_burial_src p.person
  let get_consang p = get_consang p.person
  let get_family p = get_family p.person
  let get_first_name p = get_first_name p.person
  let get_first_names_aliases p = get_first_names_aliases p.person
  let get_image p = get_image p.person
  let get_iper p = get_iper p.person
  let get_notes p = get_notes p.person
  let get_occ p = get_occ p.person
  let get_occupation p = get_occupation p.person
  let get_parents p = get_parents p.person
  let get_psources p = get_psources p.person
  let get_public_name p =get_public_name p.person
  let get_qualifiers p = get_qualifiers p.person
  let get_related p = get_related p.person
  let get_rparents p =get_rparents p.person
  let get_sex p = get_sex p.person
  let get_surname p = get_surname p.person
  let get_surnames_aliases p =get_surnames_aliases p.person
  let get_titles p = get_titles p.person
  let gen_ascend_of_person p = gen_ascend_of_person p.person
  let gen_union_of_person p = gen_union_of_person p.person

  let witness_notes base iper =
    match PatchPer.get base iper with
    | Some notes -> notes
    | None ->
      let p = poi base iper in
      let genpers = Gwdb_legacy.Gwdb_driver.gen_person_of_person p in
      let pevents = genpers.Gwdb_legacy.Dbdisk.pevents in
      let witnesses_notes =
        List.map (fun pe ->
            let wits = pe.Gwdb_legacy.Dbdisk.epers_witnesses in
            Array.make (Array.length wits) empty_string) pevents
        |> Array.of_list
      in
      witnesses_notes

  let fwitness_notes base ifam =
    match PatchFam.get base ifam with
    | Some notes -> notes
    | None ->
      let f = foi base ifam in
      let genfam = Gwdb_legacy.Gwdb_driver.gen_family_of_family f in
      let fevents = genfam.Gwdb_legacy.Dbdisk.fevents in
      let witnesses_notes =
        List.map (fun fe ->
            let wits = fe.Gwdb_legacy.Dbdisk.efam_witnesses in
            Array.make (Array.length wits) empty_string) fevents
        |> Array.of_list
      in
      witnesses_notes

  let poi base iper =
    {person = poi base iper; witness_notes = witness_notes base iper}

  let base_visible_get base (f : person -> bool) iper =
    let f person =
      let witness_notes = witness_notes base (Gwdb_legacy.Gwdb_driver.get_iper person) in
      f {person; witness_notes} in
    base_visible_get base f iper

  let persons base =
    let coll = persons base in
    Collection.map (fun person ->
        let witness_notes = witness_notes base (Gwdb_legacy.Gwdb_driver.get_iper person) in
        {person; witness_notes} ) coll

  let empty_family base ifam =
    let f = empty_family base ifam in
    {family = f; witness_notes = [||]}

  let gen_family_of_family f =
    let gen_fam = gen_family_of_family f.family in
    let fevents =
      List.mapi (fun ie fe ->
          let fe = Translate.legacy_to_def_fevent empty_string fe in
          let efam_witnesses =
            Array.mapi (fun iw (ip, wk, _) ->
                ip, wk, f.witness_notes.(ie).(iw)) fe.efam_witnesses
          in
          {fe with efam_witnesses}
        ) gen_fam.fevents
    in
    let gen_fam = Translate.legacy_to_def_family empty_string gen_fam in
    {gen_fam with fevents}
    
  let family_of_gen_family base (genfam, gen_couple, gen_descend) =
    let fevents = genfam.Def.fevents in
    let witness_notes =
      List.map (fun fe ->
          Array.map (fun (_,_,wnote) -> wnote) fe.Def.efam_witnesses
        ) fevents |> Array.of_list
    in
    let genfam = Translate.as_legacy_family genfam in
    let family = family_of_gen_family base (genfam, gen_couple, gen_descend) in
    {family; witness_notes}

  let no_family ifam =
    let nof = no_family ifam in
    Translate.legacy_to_def_family empty_string nof
    
  let patch_family base ifam genfam =
    log @@ "PATCH FAMILY" ^ (string_of_int ifam);
    (* TODO HANDLE WNOTES *)
    log "LETS PATCH";
    let fevents = genfam.Def.fevents in
    let genfam = Translate.as_legacy_family genfam in
    patch_family base ifam genfam;
    let witnotes = fwitness_notes_of_events fevents in
    PatchFam.set base ifam witnotes

  let insert_family base ifam genfam =
    log "INSERT FAMILY";
    log "LETS INSERT";
    let fevents = genfam.Def.fevents in
    let genfam = Translate.as_legacy_family genfam in
    insert_family base ifam genfam;
    let witnotes = fwitness_notes_of_events fevents in
    PatchFam.set base ifam witnotes

  let get_children f = get_children f.family
  let get_comment f = get_comment f.family
  let get_divorce f = get_divorce f.family
  let get_father f = get_father f.family
  let get_fsources f = get_fsources f.family
  let get_ifam f = get_ifam f.family
  let get_marriage f = get_marriage f.family
  let get_marriage_note f = get_marriage_note f.family
  let get_marriage_place f = get_marriage_place f.family
  let get_marriage_src f = get_marriage_src f.family
  let get_mother f = get_mother f.family
  let get_origin_file f = get_origin_file f.family
  let get_parent_array f = get_parent_array f.family
  let get_relation f = get_relation f.family
  let get_witnesses f = get_witnesses f.family
  let gen_couple_of_family f = gen_couple_of_family f.family
  let gen_descend_of_family f = gen_descend_of_family f.family

  let foi base ifam =
    {family = foi base ifam; witness_notes = fwitness_notes base ifam}

  let families ?(select = fun _ -> true) base =
    let select f =
      select {family = f; witness_notes = [||]}
    in
    let coll = families ~select base in
    Collection.map (fun family ->
        let witness_notes = fwitness_notes base (Gwdb_legacy.Gwdb_driver.get_ifam family) in
        {family; witness_notes} ) coll

  
end

module Driver = Compat.Make (Legacy_driver) (Legacy_driver)

include Driver
