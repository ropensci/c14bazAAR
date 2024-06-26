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
    dplyr::filter(.data[["method"]] %in% c("AMS", "Conv 14C"))

  # final data preparation
  c14palaeolithic <- db_raw_c14 %>%
    dplyr::transmute(
      c14age   = .data[["ch_c14_age"]],
      c14std   = .data[["ch_c14_pm"]],
      country  = .data[["country"]],
      feature  = .data[["ayer_id"]],
      labnr    = .data[["ch_c14_labref"]],
      lat      = .data[["oord_lat"]],
      lon      = .data[["coord_long"]],
      material = .data[["ch_c14_sample"]],
      method   = .data[["method"]],
      period   = .data[["cul stage"]],
      shortref = .data[["bi_bibliogr_ref"]],
      site     = .data[["itename"]],
      comment  = .data[["ch_c14_result_unreliable"]]
    ) %>% dplyr::mutate(
      sourcedb = "14cpalaeolithic",
      sourcedb_version = get_db_version("14cpalaeolithic")
    ) %>%
    as.c14_date_list()

  return(c14palaeolithic)
}
