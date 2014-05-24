(** {1 GDAL Data Sets} *)

type t
val t : t Ctypes.typ
(** Data set *)

val of_source : ?write:bool -> string -> [ `Invalid_source | `Ok of t ]
(** [of_source ?write name] opens the source [name] for access.

    @param write defaults to false (read-only)
    @param name is source-type specific.  See the upstream GDAL documentation
           for more information.

    @return `Invalid_source if [name] does not represent a valid data source. *)

val close : t -> unit
(** [close t] closes the data set [t]. *)

val with_source :
  ?write:bool ->
  string ->
  (t -> 'a) ->
  [ `Invalid_source | `Ok of 'a ]
(** [with_source ?write name f] opens [name] and calls [f src] if [name] is a
    valid data source.  The data source passed to [f] will be closed if [f]
    returns normally or raises an exception.

    This is a wrapper around {!of_source}.  See its documentation for a
    description of the expected arguments. *)

val get_driver : t -> Driver.t
(** [get_driver t] returns the driver associated with [t]. *)

val get_projection : t -> string
(** [get_projection t] returns a string representing the projection applied to
    [t]. *)

val get_origin : t -> float * float
(** [get_origin t] returns the [(x, y)] origin of rasters in [t]. *)

val get_pixel_size : t -> float * float
(** [get_pixel_size t] returns the [(x, y)] pixel size of the rasters in [t]. *)

val get_rotation : t -> float * float
(** [get_rotation t] returns the rotation of rasters in [t]. *)

val get_x_size : t -> int
val get_y_size : t -> int
(** [get_x/y_size t] returns the [x] or [y] dimension of [t]'s rasters. *)

val get_count : t -> int
(** [get_count t] returns number of raster bands in [t]. *)

val get_band : t -> int -> Band.t
(** [get_band t i] returns the [i]th raster band from [t].

    @param i is 1-based, not 0-based. *)

val create_copy :
  ?strict:bool ->
  ?options:string list ->
  t -> Driver.t -> string ->
  [ `Invalid_source | `Ok of t ]
(** [create_copy ?strict ?options t driver name] creates a copy of [t].

    @param driver specifies the driver to use for the copy. *)

val create :
  ?options:string list ->
  Driver.t -> string -> int * int -> int -> 'a Band.Data.t -> t
(** [create ?options driver name size bands kind] creates a new {!t} with the
    given specifications.

    @param size specifies the [(x, y)] dimensions of bands in pixels
    @param bands specifies the number of bands in the data set
    @param kind specifies the data type used to store data internally *)

val set_geo_transform :
  t ->
  origin:float * float ->
  pixel_size:float * float ->
  rotation:float * float ->
  unit
(** [set_geo_transform t ~origin ~pixel_size ~rotation] sets the geotransform
    data for [t]. *)

val set_projection : t -> string -> unit
(** [set_project t wkt_projection] sets the projection for [t].  The projection
    string should be in WKT format. *)

val of_band : Band.t -> t
(** [of_band band] returns the {!t} associated with [band]. *)
