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
  if (!RCurl::url.exists(db_url)) {stop(paste(db_url, "is not available. No internet connection?"))}

  # download, unzip and read data
  temp <- tempfile()
  utils::download.file(db_url, temp, quiet = TRUE)
  con <- utils::unzip(temp, "Boehner_and_Schyle_Near_Eastern_radiocarbon_CONTEXT_database_2002-2006_doi10.1594GFZ.CONTEXT.Ed1.csv")
  CONTEXT_raw <- readr::read_delim(
    "Boehner_and_Schyle_Near_Eastern_radiocarbon_CONTEXT_database_2002-2006_doi10.1594GFZ.CONTEXT.Ed1.csv",
    delim = ";",
    trim_ws = TRUE,
    na = c("-", "--", "---", "", "NA", "n.d.", "?"),
    locale = readr::locale(decimal_mark = ","),
    col_types = readr::cols(
      LABNR = readr::col_character(),
      GR = readr::col_character(),
      C14AGE = readr::col_integer(),
      C14STD = readr::col_integer(),
      C13 = readr::col_double(),
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
      LATITUDE = readr::col_double(),
      LONGITUDE = readr::col_double(),
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
    # remove unnecessary variables
    dplyr::select(
      -.data[["GR"]], -.data[["MAR"]]
    ) %>%
    dplyr::rename(
      id = .data[["ID"]],
      labnr = .data[["LABNR"]],
      c14age = .data[["C14AGE"]],
      c14std = .data[["C14STD"]],
      c13val = .data[["C13"]],
      country = .data[["COUNTRY"]],
      site = .data[["SITE"]],
      material = .data[["MATERIAL"]],
      species = .data[["SPECIES"]],
      phase = .data[["PHASE"]],
      locus = .data[["LOCUS"]],
      sample = .data[["SAMPLE"]],
      culture = .data[["CULTURE"]],
      period = .data[["PERIOD"]],
      calage68 = .data[["calBC68"]],
      calage95 = .data[["calBC95"]],
      region = .data[["REGION"]],
      lat = .data[["LATITUDE"]],
      lon = .data[["LONGITUDE"]],
      shortref = .data[["REFERENCE"]]
    ) %>% dplyr::mutate(
      sourcedb = "CONTEXT"
    ) %>%
    as.c14_date_list() %>%
    c14bazAAR::order_variables()

  return(CONTEXT)
}
