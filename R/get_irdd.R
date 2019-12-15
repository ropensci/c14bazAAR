#' @rdname db_getter_backend
#' @export
get_IRDD <- function(db_url = get_db_url("IRDD")) {

  check_if_packages_are_available("openxlsx")

  check_connection_to_url(db_url)

  # download data to temporary file
  tempo <- tempfile()
  utils::download.file(db_url, tempo, mode = "wb", quiet = TRUE)

  # read data
  IRDD <- tempo %>%
    openxlsx::read.xlsx(
      sheet = 3,
      startRow = 2,
      colNames = FALSE,
      rowNames = FALSE,
      na.strings = c("?")
    ) %>%
    dplyr::mutate_if(
      sapply(., is.character),
      trimws
    ) %>%
    dplyr::transmute(
      labnr = .[[7]],
      c14age = .[[4]],
      c14std = .[[6]],
      site = .[[2]],
      sitetype = .[[14]],
      material = .[[26]],
      lat = .[[19]],
      lon = .[[20]],
      shortref = .[[15]],
      comment = .[[16]]
    ) %>%
    dplyr::mutate(
      sourcedb = "IR-DD",
      sourcedb_version = get_db_version("IRDD")
    ) %>%
    as.c14_date_list()

  # delete temporary file
  unlink(tempo)

  return(IRDD)
}
