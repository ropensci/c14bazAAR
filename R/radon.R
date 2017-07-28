#' get current RADON-Database
#'
#' Downloads the current version of the RADON-Database from \url{http://radon.ufg.uni-kiel.de/}.
#'
#' @examples
#'
#' \dontrun{
#'   RADON <- get_RADON()
#' }
#'
#' @export
get_RADON <- function() {

  # URL
  db_url <- "http://134.245.38.100/radondownload/radondaily.txt"

  # check connection
  if (!curl::has_internet()) {stop("No internet connection.")}
  if (!RCurl::url.exists(db_url)) {stop(paste(db_url, "is not available."))}

  # read data
  RADON <- db_url %>%
    readr::read_tsv(
      col_types = readr::cols(
        ID = readr::col_integer(),
        LABNR = readr::col_character(),
        C14AGE = readr::col_integer(),
        C14STD = readr::col_integer(),
        C13 = readr::col_double(),
        MATERIAL = readr::col_character(),
        SPECIES = readr::col_character(),
        COUNTRY = readr::col_character(),
        SITE = readr::col_character(),
        PERIOD = readr::col_character(),
        CULTURE = readr::col_character(),
        FEATURETYPE = readr::col_character(),
        FEATURE = readr::col_character(),
        LATITUDE = readr::col_double(),
        LONGITUDE = readr::col_double(),
        REFERENCE = readr::col_character(),
        PAGES = readr::col_character()
      )
    # rename variables
    ) %>%
    dplyr::rename_(
      id = "ID",
      labnr = "LABNR",
      c14age = "C14AGE",
      c14std = "C14STD",
      c13val = "C13",
      material = "MATERIAL",
      species = "SPECIES",
      country = "COUNTRY",
      site = "SITE",
      period = "PERIOD",
      culture = "CULTURE",
      featuretype = "FEATURETYPE",
      feature = "FEATURE",
      lat = "LATITUDE",
      lon = "LONGITUDE",
      shortref = "REFERENCE",
      pages = "PAGES"
    ) %>%
    # unite shortref & pages (if not NA)
    tidyr::replace_na(list(shortref = "", pages = "")) %>%
    tidyr::unite_(
      ., "shortref", c("shortref", "pages"), sep = ", ", remove = TRUE
    ) %>%
    dplyr::mutate(
      shortref = replace(.$shortref, which(.$shortref == ", "), NA)
    ) %>%
    dplyr::mutate(
      shortref = replace(.$shortref, grep("[,]+[[:space:]]$", .$shortref), "")
    ) %>%
    # add fullref column
    dplyr::mutate(fullref = NA_character_ ) %>%
    # add class attribute
    `class<-`(c("c14_date_list", class(.)))

  return(RADON)
}
