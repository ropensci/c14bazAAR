#' @rdname db_getter_backend
#' @export
get_radon <- function(db_url = get_db_url("radon")) {

  check_connection_to_url(db_url)

  # read data
  radon <- db_url %>%
    data.table::fread(
      quote = "",
      colClasses = "character",
      showProgress = FALSE
    ) %>%
    base::replace(., . == "", NA) %>%
    base::replace(., . == "n/a", NA) %>%
    base::replace(., . == "n.a.", NA) %>%
    dplyr::transmute(
      labnr = .data[["LABNR"]],
      c14age = .data[["C14AGE"]],
      c14std = .data[["C14STD"]],
      c13val = .data[["C13"]],
      material = .data[["MATERIAL"]],
      species = .data[["SPECIES"]],
      country = .data[["COUNTRY"]],
      site = .data[["SITE"]],
      period = .data[["PERIOD"]],
      culture = .data[["CULTURE"]],
      sitetype = .data[["FEATURETYPE"]],
      feature = .data[["FEATURE"]],
      lat = .data[["LATITUDE"]],
      lon = .data[["LONGITUDE"]],
      shortref = .data[["REFERENCE"]]
    ) %>%
    dplyr::mutate(
      sourcedb = "radon",
      sourcedb_version = get_db_version("radon")
    ) %>%
    as.c14_date_list()

  return(radon)
}
