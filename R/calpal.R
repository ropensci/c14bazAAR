#' get current CALPAL-Database
#'
#' Downloads an (actually old) version of the CALPAL-Database from \url{https://github.com/nevrome/CalPal-Database}.
#'
#' @param db_url string with weblink to c14 archive file
#'
#' @examples
#'
#' \dontrun{
#'   CALPAL <- get_CALPAL()
#' }
#'
#' @export
get_CalPal <- function(db_url = "https://raw.githubusercontent.com/nevrome/CalPal-Database/master/CalPal_14C-Database.csv") {

  # check connection
  if (!RCurl::url.exists(db_url)) {stop(paste(db_url, "is not available. No internet connection?"))}

  # read data
  CALPAL <- db_url %>%
    readr::read_csv(
      trim_ws = TRUE,
      na = c("", "nd", "--", "n/a", "NoCountry"),
      col_types = readr::cols(
        ID = "_",
        LABNR = readr::col_character(),
        C14AGE = readr::col_character(),
        C14STD = readr::col_character(),
        C13 = readr::col_character(),
        MATERIAL = readr::col_character(),
        SPECIES = readr::col_character(),
        COUNTRY = readr::col_character(),
        SITE = readr::col_character(),
        PERIOD = readr::col_character(),
        CULTURE = readr::col_character(),
        PHASE = "_",
        LOCUS = "_",
        LATITUDE = readr::col_character(),
        LONGITUDE = readr::col_character(),
        METHOD = readr::col_character(),
        CALAGE = readr::col_character(),
        CALSTD = readr::col_character(),
        REFERENCE = readr::col_character(),
        NOTICE = readr::col_character()
      )
    ) %>%
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
      lat = .data[["LATITUDE"]],
      lon = .data[["LONGITUDE"]],
      method = .data[["METHOD"]],
      calage = .data[["CALAGE"]],
      calstd = .data[["CALSTD"]],
      shortref = .data[["REFERENCE"]],
      comment = .data[["NOTICE"]]
    ) %>% dplyr::mutate(
      sourcedb = "CALPAL"
    ) %>%
    as.c14_date_list() %>%
    c14bazAAR::order_variables() %>%
    c14bazAAR::enforce_types()

  return(CALPAL)
}
