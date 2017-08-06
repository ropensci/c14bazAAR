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
  if (!RCurl::url.exists(db_url)) {stop(paste(db_url, "is not available. No internet connection?"))}

  # read data
  RADON <- db_url %>%
    readr::read_tsv(
      trim_ws = TRUE,
      na = c("", "n/a", "n.a."),
      quote = "",
      quoted_na = TRUE,
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
      featuretype = .data[["FEATURETYPE"]],
      feature = .data[["FEATURE"]],
      lat = .data[["LATITUDE"]],
      lon = .data[["LONGITUDE"]],
      shortref = .data[["REFERENCE"]],
      pages = .data[["PAGES"]]
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
      shortref = gsub("[,]+[[:space:]]$", "", .$shortref)
    ) %>%
    as.c14_date_list() %>%
    c14databases::order_variables()

  return(RADON)
}
