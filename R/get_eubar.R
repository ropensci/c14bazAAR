#' @rdname db_getter_backend
#' @export
get_EUBAR <- function(db_url = get_db_url("EUBAR")) {

  check_if_packages_are_available("openxlsx")

  check_connection_to_url(db_url)

  # download data to temporary file
  tempo <- tempfile()
  utils::download.file(db_url, tempo, mode = "wb", quiet = TRUE)

  # read data
  EUBAR <- tempo %>%
    openxlsx::read.xlsx(
      na.strings = c("Combination fails", "nd", "-"),
      startRow = 2,
      colNames = FALSE,
      rowNames = FALSE
    ) %>%
    dplyr::mutate_if(
      sapply(., is.character),
      trimws
    ) %>%
    dplyr::transmute(
      labnr = .[[13]],
      c14age = .[[14]],
      c14std = .[[15]],
      c13val = NA,
      material = .[[18]],
      country = .[[10]],
      region = .[[9]],
      site = .[[1]],
      lat = .[[12]],
      lon = .[[11]],
      period = NA,
      feature = .[[19]],
      shortref = .[[22]],
      comment = NA
    ) %>%
    dplyr::mutate(
      sourcedb = "EUBAR",
      sourcedb_version = get_db_version("EUBAR")
    ) %>%
    as.c14_date_list()

  # delete temporary file
  unlink(tempo)

  return(EUBAR)
}
