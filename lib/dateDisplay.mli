(* Copyright (c) 1998-2007 INRIA *)

open Config
open Def
open Gwdb

(** [get_wday conf date]
    Return the day of the week for this [date] *)
val get_wday : config -> date -> string

(** Returns textual representation of the date translated to the current language. Uses different encodings depending on day's,
    month's and year's accessibility. Doesn't consider precision. *)
val code_dmy : config -> dmy -> string

(** Converts and translate date to the textual representation for the giving language. Considers precision. *)
val string_of_dmy : Config.config -> Def.dmy -> string

(** If date is [Dgreg] calls for [string_of_dmy] to convert date to the string else returns content of [Dtext].
    Difference between calendars is not taken into the acount. *)
val string_of_date : config -> date -> string

(** Converts and translate date with considering different calendars with prefix "on" before dates (changes for other languages).
    Date precision is much more verbose then with [string_of_date]. Decline phrase if needed.
    If [link] is true then encapsulates result in HTML link to the page calendar's date converter. *)
val string_of_ondate : ?link:bool -> config -> date -> string

(** Returns date in format dd/mm/yyyy. Format could be different for other languages (defined by [!dates order]
    keyword in the lexicon). *)
val string_slash_of_date : config -> date -> string

(** Returns textual representation of the age represented by [dmy]. *)
val string_of_age : config -> dmy -> string

(** Returns textual representation of date's precision and year. *)
val prec_year_text : config -> dmy -> string

(** Returns textual representation of date's precision *)
val prec_text : config -> dmy -> string

(** Returns textual representation of date's month number. *)
val month_text : dmy -> string

(** Returns textual representation of date's year. *)
val year_text : dmy -> string

(** Returns concatenation of person's birth and death dates (if exists). Precision is mentionned for each date.
    For example :

        * 1700-1780 (birth - death)
        * 1700-     (birth - death but don't know when)
        * 1700      (birth - alive)
        * †1780     (unknown birth date - death)
        * †         (unknown birth date - death but don't know when) *)
val short_dates_text : config -> base -> person -> string

(** Retruns year of marriage for given spouses with its precision. *)
val short_marriage_date_text : config -> base -> family -> person -> person -> string

(** [death_symbol conf]
    Return the value associated to ["death_symbol"] in [.gwf] file
    if it is defined, or use ["†"] if it is not.
 *)
val death_symbol : config -> string

(** Returns roman number of the year of French calendar *)
val code_french_year : config -> int -> string

(** Same as [string_of_ondate] except :
    - Conversion function for [Def.dmy] could be passed in in [dmy] argument
    - Doesn't consider phrase declination as [string_of_ondate] does. *)
val string_of_date_aux
  : ?link:bool
  -> ?dmy:(Config.config -> Def.dmy -> string)
  -> ?sep:string
  -> Config.config
  -> Def.date
  -> string
