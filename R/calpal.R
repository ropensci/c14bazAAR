#' get current CALPAL-Database
#'
#' Downloads the current version of the CALPAL-Database from \url{https://github.com/nevrome/CalPal-Database}.
#'
#' @examples
#'
#' \dontrun{
#'   CALPAL <- get_CALPAL()
#' }
#'
#' @importFrom magrittr "%>%"
#'
#' @export
get_CALPAL <- function() {

  # URL
  db_url <- "https://raw.githubusercontent.com/nevrome/CalPal-Database/master/CalPal_14C-Database.csv"

  # check connection
  if (!curl::has_internet()) {stop("No internet connection.")}
  if (!RCurl::url.exists(db_url)) {stop(paste(db_url, "is not available."))}

  # read data
  CALPAL <- db_url %>%
    readr::read_csv(
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
        PHASE = readr::col_character(),
        LOCUS = readr::col_character(),
        LATITUDE = readr::col_double(),
        LONGITUDE = readr::col_double(),
        METHOD = readr::col_character(),
        CALAGE = readr::col_integer(),
        CALSTD = readr::col_integer(),
        REFERENCE = readr::col_character(),
        NOTICE = readr::col_character()
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
      phase = "PHASE",
      locus = "LOCUS",
      lat = "LATITUDE",
      lon = "LONGITUDE",
      method = "METHOD",
      calage = "CALAGE",
      calstd = "CALSTD",
      shortref = "REFERENCE",
      comment = "NOTICE"
    ) %>%
    dplyr::mutate(fullref = NA_character_ ) %>%
      `class<-`(c("c14_date_list", class(.)))

  return(CALPAL)
}
