val select_person_by_date :
  Config.config ->
  Gwdb.base ->
  (Gwdb.person -> Date.date option) ->
  ascending:bool ->
  (Gwdb.person * (Date.dmy * Date.calendar)) list * int
(** [select_person_by_date conf base get_date ~ascending] select 20 persons by default
    from the base according to the one of their date (birth, death,
    marriage, specific event, etc.) that could be get with [get_date].
    Returns sorted by date persons that have the latest or oldest date depending on [~ascending].
    Selection could be different depending
    on environement [conf.env]. These variables affect the selection:
      k - allows to modify default value (20) of selected persons
      by,bm,bd - allows to set reference date (all dates after the reference
                 one aren't selected)
    Returns also the number of selected persons *)

val select_person_by_duration :
  Config.config ->
  Gwdb.base ->
  (Gwdb.person -> Duration.t option) ->
  ascending:bool ->
  (Gwdb.person * Duration.t) list * int
(** Same as [select_person_by_date] but for elapsed_time instead of date *)

val select_family :
  Config.config ->
  Gwdb.base ->
  (Gwdb.family -> Date.date option) ->
  bool ->
  (Gwdb.family * (Date.dmy * Date.calendar)) list * int
(** Same as [select_person] but dealing with families *)

val death_date : Gwdb.person -> Date.date option
(** Returns person's death date (if exists) *)

val make_population_pyramid :
  nb_intervals:int ->
  interval:int ->
  limit:int ->
  at_date:Date.dmy ->
  Config.config ->
  Gwdb.base ->
  int array * int array
(** [make_population_pyramid nb_intervals interval interval at_date conf base]
    Calculates population pyramid of all perons in the base. Population pyramid
    consists of two separated arrays that regroups number of men's and women's born
    in each time interval. One array has a size [nb_intervals + 1] and every element
    is a number of persons born in the giving time interval that represents [interval] years.
    Calculation starts at the date [at_date] and persons that are considered
    in pyramid should be alive at this date. [limit] allows to limit persons
    by age (those that has age greater then limit aren't taken into the account) *)
