#' @rdname db_getter_backend
#' @export
get_pacea <- function(db_url = get_db_url("pacea")) {

  check_connection_to_url(db_url)

  # db_url <-"http://www.paleoanthro.org/media/journal/content/PA20110001_S01.zip"

  # download and unzip data
  temp <- tempfile()
  utils::download.file(db_url, temp, quiet = TRUE)
  db_path <- utils::unzip(
    temp,
    file.path("PA20110001_S01.txt"),
    exdir = tempdir()
  )

  # read data
  db_raw <- data.table::fread(
    db_path,
    sep = "\t",
    encoding = "UTF-8",
    skip = 1,
    colClasses = c(
      "Site" = "character",
      "Longitude" = "character",
      "Latitude" = "character",
      "Town" = "character",
      "Region" = "character",
      "Country" = "character",
      "Biogeography" = "character",
      "Altitude" = "character",
      "Orientation" = "character",
      "Site Type" = "character",
      "Site Function" = "character",
      "Cultural Attribution 1" = "character",
      "Cultural Attribution 2" = "character",
      "Cultural Attribution 3" = "character",
      "Level" = "character",
      "Date Type" = "character",
      "Sample" = "character",
      "Code" = "character",
      "Age" = "character",
      "s.dev." = "character",
      "Cal BP" = "character",
      "cal s.dev." = "character",
      "IntCal09 max BP" = "character",
      "IntCal09 min BP" = "character",
      "Biblio" = "character",
      "Notes" = "character"
    ),
    showProgress = FALSE
  )

  # remove files in file system
  unlink(temp)
  file.remove(db_path)


  # final data preparation
  pacea <- db_raw %>%
    base::replace(., . == "", NA) %>%
    dplyr::transmute(
      method = .data[["Date Type"]],
      labnr = .data[["Code"]],
      c14age = .data[["Age"]],
      c14std = .data[["s.dev."]],
      site = .data[["Site"]],
      sitetype = .data[["Site Type"]],
      feature = .data[["Site Function"]],
      period = .data[["Cultural Attribution 1"]],
      culture = .data[["Cultural Attribution 2"]],
      material = .data[["Sample"]],
      region = .data[["Region"]],
      country = .data[["Country"]],
      lat = .data[["Latitude"]],
      lon = .data[["Longitude"]],
      shortref = .data[["Biblio"]],
      comment = .data[["Notes"]]
    ) %>% dplyr::mutate(
      sourcedb = "pacea",
      sourcedb_version = get_db_version("pacea")
    ) %>%
    as.c14_date_list()


  return(pacea)
}
