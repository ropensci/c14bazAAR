#' @rdname db_getter_backend
#' @export
get_14cpalaeolithic <- function(db_url = get_db_url("14cpalaeolithic")) {

  check_if_packages_are_available("readxl")
  check_connection_to_url(db_url)

  # download data
  temp <- tempfile(fileext = ".xlsx")
  utils::download.file(db_url, destfile = temp, mode = "wb", quiet = TRUE)

  # read data
  db_raw <- temp %>%
    readxl::read_excel(
      sheet = 1,
      col_types = "text",
      na = "",
      trim_ws = TRUE
    )

  # delete temporary file
  unlink(temp)

  # remove non-radiocarbon dates
  db_raw_c14 <- db_raw %>%
    dplyr::filter(!is.na(.data[["ch_c14_labref"]]))

  # final data preparation
  c14palaeolithic <- db_raw_c14 %>%
    dplyr::transmute(
      c13val = .data[["ch_c14_delta13c"]],
      feature = .data[["g_layer_id"]],
      labnr = .data[["ch_c14_labref"]],
      c14age = .data[["ch_c14_age"]],
      c14std = .data[["ch_c14_pm"]],
      site = .data[["g_sitename"]],
      period = .data[["cu_stage"]],
      material = .data[["ch_c14_sample"]],
      country = .data[["g_country"]],
      lat = .data[["g_coord_lat"]],
      lon = .data[["g_coord_long"]],
      shortref = .data[["bi_bibliogr_ref"]]
    ) %>% dplyr::mutate(
      sourcedb = "14cpalaeolithic",
      sourcedb_version = get_db_version("14cpalaeolithic")
    ) %>%
    as.c14_date_list() %>%
    # remove non-radiocarbon dates
    dplyr::filter(.data$c14age <= 70000)

  return(c14palaeolithic)
}
