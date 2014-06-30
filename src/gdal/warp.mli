(** {1 Raster Interpolation and Resampling} *)

type resample_t =
  | Nearest_neighbor
  | Bilinear
  | Cubic
  | Cubic_spline
  | Lanczos

exception Warp_error

module Options : sig
  type t

  val create : unit -> t
  (** [create ()] creates a warping options value initialized with sane
      defaults. *)

  val clone : t -> t
  (** [clone t] returns a copy of [t]. *)

  val set_warp_options : t -> string list -> unit
  val set_memory_limit : t -> float -> unit
  val set_resample_alg : t -> resample_t -> unit
  val set_working_data_type : t -> (_, _) Band.Data.t -> unit
  val set_src : t -> Data_set.t -> unit
  val set_dst : t -> Data_set.t -> unit
  val set_bands : t -> (int * int) list -> unit
  val set_src_no_data_real : t -> float list -> unit
  val set_src_no_data_imag : t -> float list -> unit
  val set_dst_no_data_real : t -> float list -> unit
  val set_dst_no_data_real : t -> float list -> unit
  (** [set_* t ...] set warp option fields.  See the [gdalwarper.h]
      documentation for descriptions of the affected fields. *)

  val make :
    ?warp_options:string list ->
    ?memory_limit:float ->
    ?resample_alg:resample_t ->
    ?working_data_type:(_, _) Band.Data.t ->
    ?src:Data_set.t ->
    ?dst:Data_set.t ->
    ?bands:(int * int) list ->
    ?src_no_data_real:float list ->
    ?src_no_data_imag:float list ->
    ?dst_no_data_real:float list ->
    ?dst_no_data_imag:float list ->
    unit -> t
  (** Create and initialize warp options.  The arguments to [make] can be used
      to override GDAL's defaults.  The parameters match the [set_*] functions
      above. *)
end

module Operation : sig
  (** {2 Warp Operations} *)

  type t

  val create : Options.t -> t
  (** [create o] creates a warp operation value based on the given options. *)

  val warp_region :
    ?dst_offset:int * int ->
    ?dst_size:int * int ->
    ?src_offset:int * int ->
    ?src_size:int * int ->
    t -> unit
  (** [warp_region ?dst_offset ?dst_size ?src_offset ?src_size op] warps the
      defined region according to [op].

      The optional parameters default to all zeroes which will result in the
      entire image being warped. *)

  val warp_region_to_buffer :
    ?dst_offset:int * int ->
    ?dst_size:int * int ->
    ?src_offset:int * int ->
    ?src_size:int * int ->
    ?buffer:('e, 'v, Bigarray.c_layout) Bigarray.Array2.t ->
    t -> ('e, 'v) Band.Data.t ->
    ('e, 'v, Bigarray.c_layout) Bigarray.Array2.t
  (** [warp_region_to_buffer] is like {!warp_region} except that it writes
      the result to [buffer].

      @param buffer may be used to provide a pre-allocated output buffer. *)
end

val reproject_image :
  ?memory_limit:float ->
  ?max_error:float ->
  ?options:Options.t ->
  ?src_wkt:string ->
  ?dst_wkt:string ->
  src:Data_set.t ->
  dst:Data_set.t ->
  resample_t ->
  unit
(** [reproject_image ?memory_limit ?max_error ?options ?src_wkt ?dst_wkt ~src ~dst alg]
    reprojects the image [src] to [dst], overwriting [dst] in the process.

    @param memory_limit is specified in bytes.
    @param max_error is the maximum error allowed between the [src] and [dst].
    Defaults to [0.0].
    @param src_wkt may be used to override the projection information in [src].
    @param dst_wkt may be used to override the projection information in [dst].
    @param alg specifies which resampling algorithm to use.

    @raise Warp_error if the operation can not be performed. *)

val create_and_reproject_image :
  ?memory_limit:float ->
  ?max_error:float ->
  ?options:Options.t ->
  ?src_wkt:string ->
  ?dst_wkt:string ->
  ?create_options:string list ->
  Data_set.t ->
  filename:string ->
  Driver.t ->
  resample_t ->
  unit
(** [create_and_reproject_image ?memory_limit ?max_error ?options
     ?src_wkt ?dst_wkt ?create_options src filename driver alg]
    reprojects the image [src] to [filename].

    @param memory_limit is specified in bytes.
    @param max_error is the maximum error allowed between the [src] and [dst].
    Defaults to [0.0].
    @param src_wkt may be used to override the projection information in [src].
    @param dst_wkt specifies the projection to use when creating [filename].
    Defaults to the same projection as [src].
    @param filename specifies the file to write the result to.
    @param driver specifies the driver to use when creating [filename].
    @param alg specifies which resampling algorithm to use.

    @raise Warp_error if the operation can not be performed. *)

val auto_create_warped_vrt :
  ?src_wkt:string ->
  ?dst_wkt:string ->
  ?max_error:float ->
  ?options:Options.t ->
  Data_set.t ->
  resample_t ->
  Data_set.t
(** [auto_create_warped_vrt ?src_wkt ?dst_wkt ?max_error ?options src alg]
    creates a virtual dataset warped from [src].

    @param src_wkt may be used to override the projection information in [src].
    @param dst_wkt specifies the projection to use when creating [filename].
    Defaults to the same projection as [src].
    @param max_error is the maximum error allowed between the [src] and [dst].
    Defaults to [0.0].
    @param alg specifies which resampling algorithm to use.

    @raise Warp_error if the operation can not be performed. *)
