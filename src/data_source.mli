type t

exception Invalid_source

val of_source : ?write:bool -> string -> t

val destroy : t -> unit
val release : t -> int

val with_source :
  ?write:bool ->
  string ->
  (t -> 'a) ->
  'a

val get_layer_by_name : t -> string -> Layer.t
val get_layer : t -> int -> Layer.t
