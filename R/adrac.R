#' get current aDRAC-Database
#'
#' Downloads the current version of the aDRAC-Database from \url{https://github.com/dirkseidensticker/aDRAC/}.
#'
#' @param db_url string with weblink to c14 archive file
#'
#' @examples
#'
#' \dontrun{
#'   aDRAC <- get_aDRAC()
#' }
#'
#' @export
get_aDRAC <- function(db_url = "https://raw.githubusercontent.com/dirkseidensticker/aDRAC/master/data/aDRAC.csv") {

  # check connection
  if (!RCurl::url.exists(db_url)) {stop(paste(db_url, "is not available. No internet connection?"))}

  # read data
  aDRAC <- db_url %>%
    readr::read_csv(
      trim_ws = TRUE,
      col_types = readr::cols(
        LABNR = readr::col_character(),
        C14AGE = readr::col_character(),
        C14STD = readr::col_character(),
        C13 = readr::col_character(),
        MATERIAL = readr::col_character(),
        SITE = readr::col_character(),
        COUNTRY = readr::col_character(),
        FEATURE = readr::col_character(),
        FEATURE_DESC = "_",
        LAT = readr::col_character(),
        LONG = readr::col_character(),
        SOURCE = readr::col_character()
      )
    ) %>%
    dplyr::transmute(
      labnr = .data[["LABNR"]],
      c14age = .data[["C14AGE"]],
      c14std = .data[["C14STD"]],
      c13val = .data[["C13"]],
      material = .data[["MATERIAL"]],
      site = .data[["SITE"]],
      country = .data[["COUNTRY"]],
      feature = .data[["FEATURE"]],
      lat = .data[["LAT"]],
      lon = .data[["LONG"]],
      shortref = .data[["SOURCE"]]
    ) %>% dplyr::mutate(
      sourcedb = "aDRAC"
    ) %>%
    as.c14_date_list() %>%
    c14bazAAR::order_variables() %>%
    c14bazAAR::enforce_types()

  return(aDRAC)
}
