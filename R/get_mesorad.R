#' @rdname db_getter_backend
#' @export
get_mesorad <- function(db_url = get_db_url("mesorad")) {

  check_if_packages_are_available("readxl")
  check_connection_to_url(db_url)

  # download data
  temp <- tempfile(fileext = ".xlsx")
  utils::download.file(db_url, temp, mode = "wb", quiet = TRUE)

  # read data
  db_raw <- temp %>%
    readxl::read_excel(
      sheet = 1,
      col_types = "text",
      trim_ws = TRUE
    )

  # delete temporary file
  unlink(temp)

  # final data preparation
  mesorad <- db_raw %>%
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
    dplyr::mutate(
      sourcedb = "mesorad",
      sourcedb_version = get_db_version("mesorad")
    ) %>%
    as.c14_date_list()

  return(mesorad)
}
