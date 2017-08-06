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
#' @export
get_CALPAL <- function() {

  # URL
  db_url <- "https://raw.githubusercontent.com/nevrome/CalPal-Database/master/CalPal_14C-Database.csv"

  # check connection
  if (!RCurl::url.exists(db_url)) {stop(paste(db_url, "is not available. No internet connection?"))}

  # read data
  CALPAL <- db_url %>%
    readr::read_csv(
      trim_ws = TRUE,
      na = c("", "nd", "--"),
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
    ) %>%
    dplyr::rename(
      id = .data[["ID"]],
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
      phase = .data[["PHASE"]],
      locus = .data[["LOCUS"]],
      lat = .data[["LATITUDE"]],
      lon = .data[["LONGITUDE"]],
      method = .data[["METHOD"]],
      calage = .data[["CALAGE"]],
      calstd = .data[["CALSTD"]],
      shortref = .data[["REFERENCE"]],
      comment = .data[["NOTICE"]]
    ) %>%
    as.c14_date_list() %>%
    c14databases::order_variables()

  return(CALPAL)
}
