open Ctypes

type t = T.t
let t = T.t

exception Invalid_projection
exception Band_error

let proj_err = T.err Invalid_projection
let band_err = T.err Band_error

let open_ = (* 'open' is a keyword in OCaml *)
  Lib.c "GDALOpen"
    (string @-> int @-> returning t)

let close =
  Lib.c "GDALClose"
    (t @-> returning void)

let of_source ?(write = false) name =
  let h = open_ name (if write then 1 else 0) in
  if h = null then
    `Error `Invalid_source
  else
    `Ok h

let with_source ?write name f =
  match of_source ?write name with
  | `Ok h -> Lib.protect f h ~finally:close
  | `Error _ as e -> e

let get_driver =
  Lib.c "GDALGetDatasetDriver"
    (t @-> returning Driver.t)

let get_projection =
  Lib.c "GDALGetProjectionRef"
    (t @-> returning string)

let get_x_size =
  Lib.c "GDALGetRasterXSize"
    (t @-> returning int)

let get_y_size =
  Lib.c "GDALGetRasterYSize"
    (t @-> returning int)

let get_count =
  Lib.c "GDALGetRasterCount"
    (t @-> returning int)

let get_band =
  Lib.c "GDALGetRasterBand"
    (t @-> int @-> returning Band.t)

let get_band_data_type t i =
  let c = get_band t i in
  Band.get_data_type c

let get_band t i kind =
  let c = get_band t i in
  if Band.check_data_type c kind then
    (c, Band.Data.to_ba_kind kind)
  else
    invalid_arg "get_band"

let add_band =
  Lib.c "GDALAddBand"
    (t @-> int @-> ptr void @-> returning band_err)

let add_band ?(options = []) t kind =
  let i = Band.Data.to_int kind in
  add_band t i (Lib.convert_creation_options options)

let create_copy =
  Lib.c "GDALCreateCopy" (
    Driver.t @->
    string @->
    t @->
    int @->
    ptr void @-> ptr void @-> ptr void @->
    returning t
  )

let create_copy ?(strict = false) ?(options = []) src driver name =
  let options = Lib.convert_creation_options options in
  let dst =
    create_copy driver name src
      (if strict then 1 else 0)
      options null null
  in
  if dst = null then
    `Error `Invalid_source
  else
    `Ok dst

let create =
  Lib.c "GDALCreate" (
    Driver.t @-> string @-> int @-> int @-> int @-> int @-> ptr void @->
    returning t
  )

let create ?(options = []) ?bands driver name (nx, ny) =
  let nbands, kind =
    match bands with
    | None -> 0, None
    | Some (n, kind) -> n, Some kind
  in
  let options = Lib.convert_creation_options options in
  let ds =
    create
      driver name nx ny nbands (Band.Data.to_int_opt kind) options
  in
  if ds = null then
    `Error `Invalid_source
  else
    `Ok ds

let set_projection =
  Lib.c "GDALSetProjection"
    (t @-> string @-> returning proj_err)

let of_band =
  Lib.c "GDALGetBandDataset"
    (Band.t @-> returning t)

let of_band (band, _) =
  of_band band
