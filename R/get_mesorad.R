#' @name get_dates
#' @rdname db_getter_backend
#' @export
get_mesorad <- function(db_url = get_db_url("mesorad")) {

  check_if_packages_are_available("readxl")

  # download data
  temp <- tempfile(fileext = ".xlsx")
  utils::download.file(url = db_url, destfile = temp, mode = "wb", quiet = TRUE)

  mesorad <- temp %>%
    readxl::read_excel(
      sheet = 1,
      col_types = "text"
    ) %>%
    as.data.table() %>%
    dplyr::transmute(
      labnr = .[["Lab No."]],
      c14age = .[["Conventional 14C age (BP)"]],
      c14std = .[["Error (±)"]],
      method = .[["Dating Method"]],
      region = .[["Adaptive Region"]],
      site = .[["Site"]],
      sitetype = .[["Context"]],
      feature = .[["Provenience"]],
      shortref = .[["Citation"]],
      comment = .[["Chronometric Hygiene/ Issues with Dates"]]
    ) %>%
    dplyr::mutate_if(
      sapply(., is.character),
      trimws
    ) %>%
    dplyr::mutate(
      sourcedb = "mesorad",
      sourcedb_version = get_db_version("mesorad")
    ) %>%
    as.c14_date_list()

  # delete temporary file
  unlink(temp)

  return(mesorad)
}
