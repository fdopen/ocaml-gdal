(** {1 GDAL Data Sets} *)

type t
val t : t Ctypes.typ
(** Data set *)

exception Wrong_data_type

type geotransform_t

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

val get_geo_transform : t -> geotransform_t
(** [get_geo_transform t] returns the geotransform array associated with
    [t]. *)

val get_origin : geotransform_t -> float * float
(** [get_origin t] returns the [(x, y)] origin of rasters in [t]. *)

val get_pixel_size : geotransform_t -> float * float
(** [get_pixel_size t] returns the [(x, y)] pixel size of the rasters in [t]. *)

val get_rotation : geotransform_t -> float * float
(** [get_rotation t] returns the rotation of rasters in [t]. *)

val get_x_size : t -> int
val get_y_size : t -> int
(** [get_x/y_size t] returns the [x] or [y] dimension of [t]'s rasters. *)

val get_count : t -> int
(** [get_count t] returns number of raster bands in [t]. *)

val get_band : t -> int -> ('v, 'e) Band.Data.t -> ('v, 'e) Band.t
(** [get_band t i kind] returns the [i]th raster band from [t].

    @param i is 1-based, not 0-based
    @param kind is the native data type of the band
    @raise Wrong_data_type if [kind] is not correct *)

val get_band_data_type : t -> int -> [
    `byte
  | `uint16
  | `int16
  | `uint32
  | `int32
  | `float32
  | `float64
  | `unknown
  | `unhandled
  ]
(** [get_band_data_type t i] returns the native data type of the [i]th band in
    [t]. *)

val create_copy :
  ?strict:bool ->
  ?options:string list ->
  t -> Driver.t -> string ->
  [ `Invalid_source | `Ok of t ]
(** [create_copy ?strict ?options t driver name] creates a copy of [t].

    @param driver specifies the driver to use for the copy. *)

val create :
  ?options:string list ->
  ?bands:int * (_, _) Band.Data.t ->
  Driver.t -> string -> int * int -> t
(** [create ?options ?bands driver name size] creates a new {!t} with the
    given specifications.

    @param size specifies the [(x, y)] dimensions of bands in pixels
    @param bands specifies the number of bands to initialize in the data set
           and their data type *)

val make_geo_transform :
  origin:float * float ->
  pixel_size:float * float ->
  rotation:float * float ->
  geotransform_t
(** [make_geo_transform ~origin ~pixel_size ~rotation] creates a geotransform
    with the given specifications. *)

val set_geo_transform : t -> geotransform_t -> unit
(** [set_geo_transform_array t] sets the geotransform array for [t]. *)

val set_projection : t -> string -> unit
(** [set_project t wkt_projection] sets the projection for [t].  The projection
    string should be in WKT format. *)

val of_band : (_, _) Band.t -> t
(** [of_band band] returns the {!t} associated with [band]. *)
