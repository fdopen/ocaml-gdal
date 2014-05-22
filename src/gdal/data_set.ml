open Ctypes
open Foreign

type t = T.t
let t = T.t

exception Data_set_error

let err = T.err Data_set_error

let open_ = (* 'open' is a keyword in OCaml *)
  Lib.c "GDALOpen"
    (string @-> int @-> returning t)

let close =
  Lib.c "GDALClose"
    (t @-> returning void)

let of_source ?(write = false) name =
  let h = open_ name (if write then 1 else 0) in
  if h = null then
    `Invalid_source
  else
    `Ok h

let with_source ?write name f =
  match of_source ?write name with
  | `Ok h -> `Ok (Lib.protect f h ~finally:close)
  | `Invalid_source -> `Invalid_source

let get_driver =
  Lib.c "GDALGetDatasetDriver"
    (t @-> returning Driver.t)

let get_projection =
  Lib.c "GDALGetProjectionRef"
    (t @-> returning string)

let get_geo_transform =
  Lib.c "GDALGetGeoTransform"
    (t @-> ptr double @-> returning err)

let get_geo_transform t =
  let ca = CArray.make double 6 in
  get_geo_transform t (CArray.start ca);
  Array.init 6 (fun i -> CArray.get ca i)

let origin_of_transform gt =
  gt.(0), gt.(3)

let pixel_size_of_transform gt =
  gt.(1), gt.(5)

let rotation_of_transform gt =
  gt.(2), gt.(4)

let get_origin t =
  let gt = get_geo_transform t in
  origin_of_transform gt

let get_pixel_size t =
  let gt = get_geo_transform t in
  pixel_size_of_transform gt

let get_rotation t =
  let gt = get_geo_transform t in
  rotation_of_transform gt

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
    `Invalid_source
  else
    `Ok dst

let create =
  Lib.c "GDALCreate" (
    Driver.t @-> string @-> int @-> int @-> int @-> int @-> ptr void @->
    returning t
  )

let create ?(options = []) driver name (nx, ny) nbands kind =
  let options = Lib.convert_creation_options options in
  create
    driver name nx ny nbands (Band.Data.to_int kind) options

let set_geo_transform =
  Lib.c "GDALSetGeoTransform"
    (t @-> ptr double @-> returning err)

let set_geo_transform t transform =
  assert (Array.length transform = 6);
  let ca = CArray.make double 6 in
  for i = 0 to 5 do
    CArray.set ca i transform.(i);
  done;
  set_geo_transform t (CArray.start ca)

let set_geo_transform t ~origin ~pixel_size ~rotation =
  set_geo_transform t [|
    fst origin;
    fst pixel_size;
    fst rotation;
    snd origin;
    snd rotation;
    snd pixel_size;
  |]

let set_projection =
  Lib.c "GDALSetProjection"
    (t @-> string @-> returning err)
