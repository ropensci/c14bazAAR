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
  CONTEXT_raw <- data.table::fread(
    paste0(
      tempdir(),
      "/Boehner_and_Schyle_Near_Eastern_radiocarbon_CONTEXT_database_2002-2006_doi10.1594GFZ.CONTEXT.Ed1.csv"
    ),
    sep = ";",
    encoding = "Latin-1",
    drop = c(
      "GR",
      "MAR",
      "PHASE",
      "LOCUS",
      "SAMPLE",
      "calBC68",
      "calBC95",
      "INCONGR",
      "ID"
    ),
    colClasses = c(
      "LABNR" = "character",
      "C14AGE" = "character",
      "C14STD" = "character",
      "C13" = "character",
      "COUNTRY" = "character",
      "SITE" = "character",
      "MATERIAL" = "character",
      "SPECIES" = "character",
      "CULTURE" = "character",
      "PERIOD" = "character",
      "REGION" = "character",
      "LATITUDE" = "character",
      "LONGITUDE" = "character",
      "NOTICE" = "character",
      "REFERENCE" = "character"
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
    base::replace(., . == "-", NA) %>%
    base::replace(., . == "--", NA) %>%
    base::replace(., . == "---", NA) %>%
    base::replace(., . == "", NA) %>%
    base::replace(., . == "NA", NA) %>%
    base::replace(., . == "n.d.", NA) %>%
    base::replace(., . == "?", NA) %>%
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
