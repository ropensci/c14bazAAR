#' get current CONTEXT-Database
#'
#' Downloads the current version of the CONTEXT-Database from \url{http://context-database.uni-koeln.de/}.
#'
#' @examples
#'
#' \dontrun{
#'   CONTEXT <- get_CONTEXT()
#' }
#'
#' @export
get_CONTEXT <- function() {

  db_url <- "http://context-database.uni-koeln.de/download/Boehner_and_Schyle_Near_Eastern_radiocarbon_CONTEXT_database_2002-2006_doi10.1594GFZ.CONTEXT.Ed1csv.zip"

  # check connection
  if (!curl::has_internet()) {stop("No internet connection.")}
  if (!RCurl::url.exists(db_url)) {stop(paste(db_url, "is not available."))}

  # download, unzip and read data
  temp <- tempfile()
  download.file(db_url, temp, quiet = TRUE)
  con <- unzip(temp, "Boehner_and_Schyle_Near_Eastern_radiocarbon_CONTEXT_database_2002-2006_doi10.1594GFZ.CONTEXT.Ed1.csv")
  CONTEXT_raw <- readr::read_delim(
    "Boehner_and_Schyle_Near_Eastern_radiocarbon_CONTEXT_database_2002-2006_doi10.1594GFZ.CONTEXT.Ed1.csv",
    delim = ";",
    na = c("-", "--", "---", "", "NA"),
    col_types = readr::cols(
      LABNR = readr::col_character(),
      GR = readr::col_character(),
      C14AGE = readr::col_integer(),
      C14STD = readr::col_integer(),
      C13 = readr::col_character(),
      COUNTRY = readr::col_character(),
      SITE = readr::col_character(),
      MAR = readr::col_character(),
      MATERIAL = readr::col_character(),
      SPECIES = readr::col_character(),
      PHASE = readr::col_character(),
      LOCUS = readr::col_character(),
      SAMPLE = readr::col_character(),
      CULTURE = readr::col_character(),
      PERIOD = readr::col_character(),
      calBC68 = readr::col_character(),
      calBC95 = readr::col_character(),
      REGION = readr::col_character(),
      LATITUDE = readr::col_character(),
      LONGITUDE = readr::col_character(),
      INCONGR = readr::col_character(),
      NOTICE = readr::col_character(),
      REFERENCE = readr::col_character(),
      ID = readr::col_integer()
    )
  )
  unlink(temp)
  file.remove("Boehner_and_Schyle_Near_Eastern_radiocarbon_CONTEXT_database_2002-2006_doi10.1594GFZ.CONTEXT.Ed1.csv")

  # rename
  CONTEXT <- CONTEXT_raw %>%
    # remove strange columns
    dplyr::select_(
      quote(-GR), quote(-MAR)
    ) %>%
    # rename
    dplyr::rename_(
      id = "ID",
      labnr = "LABNR",
      c14age = "C14AGE",
      c14std = "C14STD",
      c13val = "C13",
      country = "COUNTRY",
      site = "SITE",
      material = "MATERIAL",
      species = "SPECIES",
      phase = "PHASE",
      locus = "LOCUS",
      sample = "SAMPLE",
      culture = "CULTURE",
      period = "PERIOD",
      calage68 = "calBC68",
      calage95 = "calBC95",
      region = "REGION",
      lat = "LATITUDE",
      lon = "LONGITUDE",
      shortref = "REFERENCE"
    ) %>%
    # add class attribute
    `class<-`(c("c14_date_list", class(.)))

  return(CONTEXT)
}
