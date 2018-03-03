#' @rdname db_getter
#' @export
get_CONTEXT <- function(db_url = get_db_url("CONTEXT")) {

  check_connection_to_url(db_url)

  # download, unzip and read data
  temp <- tempfile()
  utils::download.file(db_url, temp, quiet = TRUE)
  con <- utils::unzip(
    temp,
    "Boehner_and_Schyle_Near_Eastern_radiocarbon_CONTEXT_database_2002-2006_doi10.1594GFZ.CONTEXT.Ed1.csv",
    exdir = tempdir()
  )
  CONTEXT_raw <- readr::read_delim(
    paste0(
      tempdir(),
      "/Boehner_and_Schyle_Near_Eastern_radiocarbon_CONTEXT_database_2002-2006_doi10.1594GFZ.CONTEXT.Ed1.csv"
    ),
    delim = ";",
    trim_ws = TRUE,
    na = c("-", "--", "---", "", "NA", "n.d.", "?"),
    col_types = readr::cols(
      LABNR = readr::col_character(),
      GR = "_",
      C14AGE = readr::col_character(),
      C14STD = readr::col_character(),
      C13 = readr::col_character(),
      COUNTRY = readr::col_character(),
      SITE = readr::col_character(),
      MAR = "_",
      MATERIAL = readr::col_character(),
      SPECIES = readr::col_character(),
      PHASE = "_",
      LOCUS = "_",
      SAMPLE = "_",
      CULTURE = readr::col_character(),
      PERIOD = readr::col_character(),
      calBC68 = "_",
      calBC95 = "_",
      REGION = readr::col_character(),
      LATITUDE = readr::col_character(),
      LONGITUDE = readr::col_character(),
      INCONGR = "_",
      NOTICE = readr::col_character(),
      REFERENCE = readr::col_character(),
      ID = "_"
    )
  )
  unlink(temp)
  file.remove(
    paste0(
      tempdir(),
      "/Boehner_and_Schyle_Near_Eastern_radiocarbon_CONTEXT_database_2002-2006_doi10.1594GFZ.CONTEXT.Ed1.csv"
    )
  )

  # rename
  CONTEXT <- CONTEXT_raw %>%
    dplyr::transmute(
      labnr = .data[["LABNR"]],
      c14age = .data[["C14AGE"]],
      c14std = .data[["C14STD"]],
      c13val = .data[["C13"]],
      country = .data[["COUNTRY"]],
      site = .data[["SITE"]],
      material = .data[["MATERIAL"]],
      species = .data[["SPECIES"]],
      culture = .data[["CULTURE"]],
      period = .data[["PERIOD"]],
      region = .data[["REGION"]],
      lat = .data[["LATITUDE"]],
      lon = .data[["LONGITUDE"]],
      shortref = .data[["REFERENCE"]],
      comment = .data[["NOTICE"]]
    ) %>% dplyr::mutate(
      sourcedb = "CONTEXT",
      lat = gsub(",", ".", .data[["lat"]]),
      lon = gsub(",", ".", .data[["lon"]])
    ) %>%
    as.c14_date_list()

  return(CONTEXT)
}
