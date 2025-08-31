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
      sheet = 6,
      col_types = "text",
      na = "",
      trim_ws = TRUE
    )

  # delete temporary file
  unlink(temp)

  # remove non-radiocarbon dates
  db_raw_c14 <- db_raw %>%
    dplyr::filter(.data[["Method"]] %in% c("AMS", "14C"))

  # final data preparation
  c14palaeolithic <- db_raw_c14 %>%
    dplyr::transmute(
      c14age   = .data[["Age"]],
      c14std   = .data[["sigma"]],
      country  = .data[["country"]],
      feature  = .data[["layer"]],
      labnr    = .data[["Labref"]],
      lat      = .data[["coord_lat"]],
      lon      = .data[["coord_long"]],
      material = .data[["sample"]],
      method   = .data[["Method"]],
      period   = .data[["Cult stage"]],
      shortref = .data[["bibliogr_ref"]],
      site     = .data[["sitename"]],
      comment  = .data[["reliability"]]
    ) %>%
    add_sourcedb_columns("14cpalaeolithic") %>%
    as.c14_date_list()

  return(c14palaeolithic)
}
