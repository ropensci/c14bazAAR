#' @rdname db_getter_backend
#' @export
get_eubar <- function(db_url = get_db_url("eubar")) {

  check_if_packages_are_available("readxl")

  check_connection_to_url(db_url)

  # download data to temporary file
  tempo <- tempfile()
  utils::download.file(db_url, tempo, mode = "wb", quiet = TRUE)

  # read data
  eubar <- tempo %>%
    readxl::read_excel(
      na = c("Combination fails", "nd", "-"),
    ) %>%
    dplyr::mutate_if(
      sapply(., is.character),
      trimws
    ) %>%
    dplyr::transmute(
      labnr = .[[13]],
      c14age = .[[14]],
      c14std = .[[15]],
      material = .[[18]],
      country = .[[10]],
      region = .[[9]],
      site = .[[1]],
      lat = .[[12]],
      lon = .[[11]],
      feature = .[[19]],
      shortref = .[[22]]
    ) %>%
    dplyr::mutate(
      sourcedb = "eubar",
      sourcedb_version = get_db_version("eubar")
    ) %>%
    as.c14_date_list()

  # delete temporary file
  unlink(tempo)

  return(eubar)
}
