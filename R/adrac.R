#' get current aDRAC-Database
#'
#' Downloads the current version of the aDRAC-Database from \url{https://github.com/dirkseidensticker/aDRAC/}.
#'
#' @examples
#'
#' \dontrun{
#'   aDRAC <- get_aDRAC()
#' }
#'
#' @export
get_aDRAC <- function() {

  # URL
  db_url <- "https://raw.githubusercontent.com/dirkseidensticker/aDRAC/master/data/aDRAC.csv"

  # check connection
  if (!curl::has_internet()) {stop("No internet connection.")}
  if (!RCurl::url.exists(db_url)) {stop(paste(db_url, "is not available."))}

  # read data
  aDRAC <- db_url %>%
    readr::read_csv(
      col_types = readr::cols(
        LABNR = readr::col_character(),
        C14AGE = readr::col_integer(),
        C14STD = readr::col_integer(),
        C13 = readr::col_double(),
        MATERIAL = readr::col_character(),
        SITE = readr::col_character(),
        COUNTRY = readr::col_character(),
        FEATURE = readr::col_character(),
        FEATURE_DESC = readr::col_character(),
        LAT = readr::col_double(),
        LONG = readr::col_double(),
        SOURCE = readr::col_character()
      )
      # rename variables
    ) %>%
    dplyr::rename(
      labnr = .data[["LABNR"]],
      c14age = .data[["C14AGE"]],
      c14std = .data[["C14STD"]],
      c13val = .data[["C13"]],
      material = .data[["MATERIAL"]],
      site = .data[["SITE"]],
      country = .data[["COUNTRY"]],
      feature = .data[["FEATURE"]],
      featuredescription = .data[["FEATURE_DESC"]],
      lat = .data[["LAT"]],
      lon = .data[["LONG"]],
      shortref = .data[["SOURCE"]]
    ) %>%
    # add class attribute
    `class<-`(c("c14_date_list", class(.)))

  return(aDRAC)
}
