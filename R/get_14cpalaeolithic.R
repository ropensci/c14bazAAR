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
    dplyr::filter(.data[["Method"]] %in% c("AMS", "Con 14C"))

  # final data preparation
  c14palaeolithic <- db_raw_c14 %>%
    dplyr::transmute(
      c13val   = .data[["delta13c"]],
      c14age   = .data[["c14_age BP"]],
      c14std   = .data[["\u00B1"]],
      country  = .data[["Ccountry"]],
      culture  = .data[["Cult"]],
      feature  = .data[["Arch Layer"]],
      labnr    = .data[["Lab"]],
      lat      = .data[["Lat"]],
      lon      = .data[["Long"]],
      material = .data[["Sample"]],
      method   = .data[["Method"]],
      region   = .data[["Province"]],
      shortref = .data[["bi_bibliogr_ref"]],
      site     = .data[["Site"]]
    ) %>% dplyr::mutate(
      sourcedb = "14cpalaeolithic",
      sourcedb_version = get_db_version("14cpalaeolithic")
    ) %>%
    as.c14_date_list()

  return(c14palaeolithic)
}
