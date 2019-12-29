#' @rdname db_getter_backend
#' @export
get_radonb <- function(db_url = get_db_url("radonb")) {

  check_connection_to_url(db_url)

  # read data
  radonb <- db_url %>%
    data.table::fread(
      quote = "",
      colClasses = c(
        ID = "character",
        LABNR = "character",
        C14AGE = "character",
        C14STD = "character",
        C13 = "character",
        MATERIAL = "character",
        SPECIES = "character",
        COUNTRY = "character",
        SITE = "character",
        PERIOD = "character",
        CULTURE = "character",
        FEATURETYPE = "character",
        FEATURE = "character",
        LATITUDE = "character",
        LONGITUDE = "character",
        REFERENCE = "character"
      ),
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
      sourcedb = "radonb",
      sourcedb_version = get_db_version("radonb")
    ) %>%
    as.c14_date_list()

  return(radonb)
}
