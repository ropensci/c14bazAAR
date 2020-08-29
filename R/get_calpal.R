#' @rdname db_getter_backend
#' @export
get_calpal <- function(db_url = "/home/clemens/agora/CalPal-Database/CalPal_2020_08_20.tsv") {#db_url = get_db_url("calpal")) {

  check_connection_to_url(db_url)

  # read data
  calpal <- db_url %>%
    data.table::fread(
      sep = "\t",
      na.strings = c("", "nd", "--", "n/a", "NoCountry"),
      drop = c(
        "ID",
        "PHASE",
        "LOCUS",
        "SUBPERIOD",
        "SITEINFO"
      ),
      colClasses = c(
        "LABNR" = "character",
        "C14AGE" = "character",
        "C14STD" = "character",
        "C13" = "character",
        "MATERIAL" = "character",
        "SPECIES" = "character",
        "COUNTRY" = "character",
        "SITE" = "character",
        "PERIOD" = "character",
        "CULTURE" = "character",
        "SITETYPE" = "character",
        "LATITUDE" = "character",
        "LONGITUDE" = "character",
        "METHOD" = "character",
        "REFERENCE" = "character"
      ),
      showProgress = FALSE
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
      shortref = .data[["REFERENCE"]]
    ) %>% dplyr::mutate(
      sourcedb = "calpal",
      sourcedb_version = get_db_version("calpal")
    ) %>%
    as.c14_date_list()

  return(calpal)
}
