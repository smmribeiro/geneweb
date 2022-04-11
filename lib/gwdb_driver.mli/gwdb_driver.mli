(* Copyright (c) 1998-2007 INRIA *)

(** String id *)
type istr

(** Family id *)
type  ifam

(** Person id *)
type iper

(** Convert [iper] to string *)
val string_of_iper : iper -> string

(** Convert [ifam] to string *)
val string_of_ifam : ifam -> string

(** Convert [istr] to string *)
val string_of_istr : istr -> string

(** Convert [iper] from string *)
val iper_of_string : string -> iper

(** Convert [ifam] from string *)
val ifam_of_string : string -> ifam

(** Convert [istr] from string *)
val istr_of_string :  string -> istr

(** Person data structure *)
type person

(** Family data structure *)
type family

(** Database implementation for [Def.gen_relation] *)
type relation = (iper, istr) Def.gen_relation

(** Database implementation for [Def.gen_title] *)
type title = istr Def.gen_title

(** Database implementation for [Def.pers_event] *)
type pers_event = (iper, istr) Def.gen_pers_event

(** Database implementation for [Def.fam_event] *)
type fam_event = (iper, istr) Def.gen_fam_event

(** Data structure for optimised search throughout index by name
    (surname or first name). *)
type string_person_index

(** The database representation. *)
type base

(** Open database associated with (likely situated in) the specified directory. *)
val open_base : string -> base

(** Close database. May perform some clean up tasks. *)
val close_base : base -> unit

(** Dummy person id *)
val dummy_iper : iper

(** Dummy family id *)
val dummy_ifam : ifam

(** [true] if strings with the giving ids are equal *)
val eq_istr : istr -> istr -> bool

(** [true] if families with the giving ids are equal *)
val eq_ifam : ifam -> ifam -> bool

(** [true] if persons with the giving ids are equal *)
val eq_iper : iper -> iper -> bool

(** [true] if string with the giving id is empty ("") *)
val is_empty_string : istr -> bool

(** [true] if string with the giving id is a question mark ("?") *)
val is_quest_string : istr -> bool

(** Id of the empty string ("") *)
val empty_string : istr

(** Id of the question mark ("?") *)
val quest_string : istr

(** Returns unitialised person with the giving id. *)
val empty_person : base -> iper -> person

(** Returns unitialised family with the giving id. *)
val empty_family : base -> ifam -> family

(** Tells if person with giving id exists in the base. *)
val iper_exists : base -> iper -> bool

(** Tells if family with giving id exists in the base. *)
val ifam_exists : base -> ifam -> bool

(** {2 Getters}
    Getters are used to extract information about person and family.
    If corresponding information part isn't present, driver load it from
    the disk and cache it so further gets will return result immediately. *)

(** Get privacy settings that define access to person's data *)
val get_access : person -> Def.access

(** Get person's aliases ids *)
val get_aliases : person -> istr list

(** Get person's baptism date *)
val get_baptism : person -> Def.cdate

(** Get person's baptism note id *)
val get_baptism_note : person -> istr

(** Get person's baptism place id *)
val get_baptism_place : person -> istr

(** Get person's baptism source id *)
val get_baptism_src : person -> istr

(** Get person's birth date *)
val get_birth : person -> Def.cdate

(** Get person's birth note id *)
val get_birth_note : person -> istr

(** Get person's birth place id *)
val get_birth_place : person -> istr

(** Get person's birth source id *)
val get_birth_src : person -> istr

(** Get information about person's burial *)
val get_burial : person -> Def.burial

(** Get person's burial note id *)
val get_burial_note : person -> istr

(** Get person's burial place id *)
val get_burial_place : person -> istr

(** Get person's burial source id *)
val get_burial_src : person -> istr

(** Get array of family's children ids *)
val get_children : family -> iper array

(** Get family's comment (notes) id *)
val get_comment : family -> istr

(** Get person's consanguinity degree with his ascendants *)
val get_consang : person -> Adef.fix

(** Get person's death status *)
val get_death : person -> Def.death

(** Get person's death note id *)
val get_death_note : person -> istr

(** Get person's death place id *)
val get_death_place : person -> istr

(** Get person's death source id *)
val get_death_src : person -> istr

(** Get family's divorce status *)
val get_divorce : family -> Def.divorce

(** Get array of family's ids to which a person belongs as parent (person's union) *)
val get_family : person -> ifam array

(** Get family's father id (from the family's couple) *)
val get_father : family -> iper

(** Get family's event list *)
val get_fevents : family -> fam_event list

(** Get person's first name id *)
val get_first_name : person -> istr

(** Get list of person's first name aliases ids *)
val get_first_names_aliases : person -> istr list

(** Get family's sources id *)
val get_fsources : family -> istr

(** Get family's id *)
val get_ifam : family -> ifam

(** Get id of path to person's image *)
val get_image : person -> istr

(** Get person's id *)
val get_iper : person -> iper

(** Get family's marriage date *)
val get_marriage : family -> Def.cdate

(** Get family's marriage note id *)
val get_marriage_note : family -> istr

(** Get family's marriage place id *)
val get_marriage_place : family -> istr

(** Get family's marriage source id *)
val get_marriage_src : family -> istr

(** Get family's mother id (from the family's couple) *)
val get_mother : family -> iper

(** Get person's notes id *)
val get_notes : person -> istr

(** Get person's occurence number *)
val get_occ : person -> int

(** Get person's occupation id *)
val get_occupation : person -> istr

(** Get family's origin file (e.g. a .gw or .ged filename) id *)
val get_origin_file : family -> istr

(** Get family's parents ids (father and mother from family's couple) *)
val get_parent_array : family -> iper array

(** Get person's family id to which his parents belong (as family's couple) *)
val get_parents : person -> ifam option

(** Get person's event list *)
val get_pevents : person -> pers_event list

(** Get person's sources id *)
val get_psources : person -> istr

(** Get person's public name id *)
val get_public_name : person -> istr

(** Get list of person's qualifiers ids *)
val get_qualifiers : person -> istr list

(** Get person's related persons ids *)
val get_related : person -> iper list

(** Get relation kind between couple in the family *)
val get_relation : family -> Def.relation_kind

(** Get person's relations with not native parents *)
val get_rparents : person -> relation list

(** Get person's sex *)
val get_sex : person -> Def.sex

(** Get person's surname id *)
val get_surname : person -> istr

(** Get person's surname aliases ids *)
val get_surnames_aliases : person -> istr list

(** Get list of person's nobility titles *)
val get_titles : person -> title list

(** Get array of family's witnesses ids *)
val get_witnesses : family -> iper array

(** Extract [gen_couple] from [family]. *)
val gen_couple_of_family : family -> iper Def.gen_couple

(** Extract [gen_descend] from [family]. *)
val gen_descend_of_family : family -> iper Def.gen_descend

(** Extract [gen_family] from [family]. *)
val gen_family_of_family : family -> (iper, ifam, istr) Def.gen_family

(** Extract [gen_person] from [person]. *)
val gen_person_of_person : person -> (iper, iper, istr) Def.gen_person

(** Extract [gen_ascend] from [person]. *)
val gen_ascend_of_person : person -> ifam Def.gen_ascend

(** Extract [gen_union] from [person]. *)
val gen_union_of_person : person -> ifam Def.gen_union

(** Create [family] from associated values. *)
val family_of_gen_family : base -> (iper, ifam, istr) Def.gen_family * iper Def.gen_couple * iper Def.gen_descend -> family

(** Create [person] from associated values. *)
val person_of_gen_person : base -> (iper, iper, istr) Def.gen_person * ifam Def.gen_ascend * ifam Def.gen_union -> person

(** Create uninitialised person with giving id *)
val poi : base -> iper -> person

(** Create uninitialised family with giving id *)
val foi : base -> ifam -> family

(** Returns string that has giving id from the base *)
val sou : base -> istr -> string

(** Returns unitialised [gen_person] with giving id *)
val no_person : iper -> (iper, iper, istr) Def.gen_person

(** Returns unitialised [gen_ascend] *)
val no_ascend : ifam Def.gen_ascend

(** Returns unitialised [gen_union] *)
val no_union : ifam Def.gen_union

(** Returns unitialised [gen_family] with giving id *)
val no_family : ifam -> (iper, ifam, istr) Def.gen_family

(** Returns unitialised [gen_descend] *)
val no_descend :iper Def.gen_descend

(** Returns unitialised [gen_couple] *)
val no_couple : iper Def.gen_couple

(** Returns number of persons inside the database *)
val nb_of_persons : base -> int

(** Returns number of defined persons (without bogus definition "? ?")
    inside the database *)
val nb_of_real_persons : base -> int

(** Returns number of families inside the database *)
val nb_of_families : base -> int

(** Returns database name *)
val bname : base -> string

(** Modify/add person with the giving id in the base. New names are added
    to the patched name index for the cosidered person and for evey member of family to
    which he belongs. Modification stay blocked until call of [commit_patches]. *)
val patch_person : base -> iper -> (iper, iper, istr) Def.gen_person -> unit

(** Modify/add ascendants of a person with a giving id. Modification stay blocked until
    call of [commit_patches]. *)
val patch_ascend : base -> iper -> ifam Def.gen_ascend -> unit

(** Modify/add union of a person with a giving id. Modification stay blocked until
    call of [commit_patches]. *)
val patch_union : base -> iper -> ifam Def.gen_union -> unit

(** Modify/add family with a giving id. Modification stay blocked until
    call of [commit_patches]. *)
val patch_family : base -> ifam -> (iper, ifam, istr) Def.gen_family -> unit

(** Modify/add descendants of a family with a giving id. Modification stay blocked until
    call of [commit_patches]. *)
val patch_descend : base -> ifam -> iper Def.gen_descend -> unit

(** Modify/add couple of a family with a giving id. Modification stay blocked until
    call of [commit_patches]. *)
val patch_couple : base -> ifam -> iper Def.gen_couple -> unit

(** Modify/add string with a giving id. If string already exists return its id.
    Modification stay blocked until call of [commit_patches]. *)
val insert_string : base -> string -> istr

(** Commit blocked modifications (patches) and update database files in order to
    apply modifications on the disk.  *)
val commit_patches : base -> unit

(** [commit_notes fname s] Update content of the notes/extended page file [fname] if exists. *)
val commit_notes : base -> string -> string -> unit

(** Retruns new unused person's id *)
val new_iper : base -> iper

(** Retruns new unused family's id *)
val new_ifam : base -> ifam

(** Same as [patch_person] *)
val insert_person : base -> iper -> (iper, iper, istr) Def.gen_person -> unit

(** Same as [patch_ascend] *)
val insert_ascend : base -> iper -> ifam Def.gen_ascend -> unit

(** Same as [patch_union] *)
val insert_union : base -> iper -> ifam Def.gen_union -> unit

(** Same as [patch_family] *)
val insert_family : base -> ifam -> (iper, ifam, istr) Def.gen_family -> unit

(** Same as [patch_couple] *)
val insert_descend : base -> ifam -> iper Def.gen_descend -> unit

(** Same as [patch_descend] *)
val insert_couple : base -> ifam -> iper Def.gen_couple -> unit

(** Remplace person with the giving id by bogus definition and clear
    person's data structure. *)
val delete_person : base -> iper -> unit

(** Clear person's ascendants data structure *)
val delete_ascend : base -> iper -> unit

(** Clear person's union data structure *)
val delete_union : base -> iper -> unit

(** Remplace family with the giving id by dummy family and clear
    family's data structure. *)
val delete_family : base -> ifam -> unit

(** Clear family's descendants data structure *)
val delete_descend : base -> ifam -> unit

(** Clear family's couple data structure *)
val delete_couple : base -> ifam -> unit

(** [person_of_key first_name surname occ] returns person from his key information
    (first name, surname and occurence number) *)
val person_of_key : base -> string -> string -> int -> iper option

(** Return list of person ids that have giving name (could be one of the mix). *)
val persons_of_name : base -> string -> iper list

(** Returns data structure that allows to make optimised search throughout
    index by first name *)
val persons_of_first_name : base -> string_person_index

(** Returns data structure that allows to make optimised search throughout
    index by surname *)
val persons_of_surname : base -> string_person_index

(** Returns first [first/sur]name id starting with that string *)
val spi_first : string_person_index -> string -> istr

(** Retruns next [first/sur]name id that follows giving name's id by
    Gutil.alphabetical order *)
val spi_next : string_person_index -> istr -> istr

(** Retruns all persons id having that [first/sur]name. *)
val spi_find : string_person_index -> istr -> iper list

(** [base_visible_get base fct ip] get visibility of person [ip] ([true] for not visible
    (restrited)) from the [base]. If file {i restrict} is present then read it to get
    visibility information. If person's visibility isn't known, then set it with [fct].
    Used when mode `use_restrict` is ativated *)
val base_visible_get : base -> (person -> bool) -> iper -> bool

(** Write updated visibility information to the {i restricted} file. *)
val base_visible_write : base -> unit

(** Return regular expression that matches all defined in the [base] particles. *)
val base_particles : base -> Re.re

(** [base_strings_of_first_name base x]
    Return the list of first names (as [istr]) being equal or to [x]
    using {!val:Name.crush_lower} comparison. [x] could be also a substring
    of the matched first name.
*)
val base_strings_of_first_name : base -> string -> istr list

(** [base_strings_of_surname base x]
    Return the list of surnames (as [istr]) being equal to [x]
    using  {!val:Name.crush_lower} comparison. [x] could be also a substring
    of the matched surname.
*)
val base_strings_of_surname : base -> string -> istr list

(** Load array of ascendants in the memory and cache it so it could be accessed
    instantly by other functions unless [clear_ascends_array] is called. *)
val load_ascends_array : base -> unit

(** Load array of unions in the memory and cache it so it could be accessed
    instantly by other functions unless [clear_unions_array] is called. *)
val load_unions_array : base -> unit

(** Load array of couples in the memory and cache it so it could be accessed
    instantly by other functions unless [clear_couples_array] is called. *)
val load_couples_array : base -> unit

(** Load array of descendants in the memory and cache it so it could be accessed
    instantly by other functions unless [clear_descends_array] is called. *)
val load_descends_array : base -> unit

(** Load array of strings in the memory and cache it so it could be accessed
    instantly by other functions unless [clear_strings_array] is called. *)
val load_strings_array : base -> unit

(** Load array of persons in the memory and cache it so it could be accessed
    instantly by other functions unless [clear_persons_array] is called. *)
val load_persons_array : base -> unit

(** Load array of families in the memory and cache it so it could be accessed
    instantly by other functions unless [clear_families_array] is called. *)
val load_families_array : base -> unit

(** Remove array of ascendants from the memory *)
val clear_ascends_array : base -> unit

(** Remove array of unions from the memory *)
val clear_unions_array : base -> unit

(** Remove array of couples from the memory *)
val clear_couples_array : base -> unit

(** Remove array of descendants from the memory *)
val clear_descends_array : base -> unit

(** Remove array of strings from the memory *)
val clear_strings_array : base -> unit

(** Remove array of persons from the memory *)
val clear_persons_array : base -> unit

(** Remove array of families from the memory *)
val clear_families_array : base -> unit

(** [base_notes_read base fname] read and return content of [fname] note
    (either database note either extended page). *)
val base_notes_read : base -> string -> string

(** [base_notes_read base fname] read and return first line of [fname] note *)
val base_notes_read_first_line : base -> string -> string

(** Says if note has empty content *)
val base_notes_are_empty : base -> string -> bool

(** Retruns origin file (.gw file) of the note *)
val base_notes_origin_file : base -> string

(** Directory where extended pages are stored *)
val base_notes_dir : base -> string

(** Directory where wizard notes are stored *)
val base_wiznotes_dir : base -> string

(** Returns last modification time of the database on disk *)
val date_of_last_change : base -> float

(** {2 Useful collections} *)

(** Collection of person's ids *)
val ipers : base -> iper Common.Collection.t

(** Collection of persons *)
val persons : base -> person Common.Collection.t

(** Collection of family's ids *)
val ifams : ?select:(ifam -> bool) -> base -> ifam Common.Collection.t

(** Collection of families *)
val families : ?select:(family -> bool) -> base -> family Common.Collection.t

(** [dummy_collection x] create a dummy collection with no element.
    [x] is only used for typing.
    Useful for placeholders or for typing purpose. *)
val dummy_collection : 'a -> 'a Common.Collection.t

(** {2 Useful markers} *)

(** [iper_marker c v] create marker over collection of person's ids and initialise it
    for every element with [v] *)
val iper_marker : base -> iper Common.Collection.t -> 'a -> (iper, 'a) Common.Marker.t

(** [ifam_marker c v] create marker over collection of family's ids and initialise it
    for every element with [v] *)
val ifam_marker : base -> ifam Common.Collection.t -> 'a -> (ifam, 'a) Common.Marker.t

(** [dummy_marker k v] create a dummy collection with no element.
    [k] and [v] are only used for typing.
    Useful for placeholders or for typing purpose. *)
val dummy_marker : 'a -> 'b -> ('a, 'b) Common.Marker.t

(** {2 Database creation} *)

(** [make bname particles arrays] create a base with [bname] name and [arrays] as content. *)
val make
  : string
  -> string list
  -> ( ( (int, int, int) Def.gen_person array
         * int Def.gen_ascend array
         * int Def.gen_union array )
       * ( (int, int, int) Def.gen_family array
           * int Def.gen_couple array
           * int Def.gen_descend array )
       * string array
       * Def.base_notes )
  -> base

(** TODOOCP : doc *)
val read_nldb : base -> (iper, ifam) Def.NLDB.t
val write_nldb : base -> (iper, ifam) Def.NLDB.t -> unit

(** [sync scratch base]
    Ensure that everything is synced on disk.

    Depending on the backend,
    it may perform various operation such as indexes rebuilding,
    and it might be a lengthy operation.

    Use [scratch] (default false) to sync and rebuild
    the whole database. Otherwise, only changes that occured
    since the last [sync] call are treated.
*)
val sync : ?scratch:bool -> save_mem:bool -> base -> unit

val gc : ?dry_run:bool -> save_mem:bool -> base -> int list * int list * int list
