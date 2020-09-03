#' @rdname db_getter_backend
#' @export
get_irdd <- function(db_url = get_db_url("irdd")) {

  check_if_packages_are_available("readxl")

  check_connection_to_url(db_url)

  # download data to temporary file
  tempo <- tempfile()
  utils::download.file(db_url, tempo, mode = "wb", quiet = TRUE)

  # read data
  irdd <- tempo %>%
    readxl::read_excel(
      sheet = 3,
      na = c("?"),
      skip = 1,
      col_names =  FALSE,
      col_types = "text"
    ) %>%
    as.data.table() %>%
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
    dplyr::mutate_if(
      sapply(., is.character),
      trimws
    ) %>%
    dplyr::mutate(
      sourcedb = "irdd",
      sourcedb_version = get_db_version("irdd")
    ) %>%
    as.c14_date_list()

  # delete temporary file
  unlink(tempo)

  return(irdd)
}
