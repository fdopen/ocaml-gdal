(** {1 Drivers} *)

type t
val t : t Ctypes.typ

val get_short_name : t -> string
val get_long_name : t -> string
(** [get_*_name t] returns the name associated with [t]. *)

val get_by_name : string -> t option
(** [get_by_name name] returns the driver associated with [name] or [None]
    if no driver matches [name]. *)
