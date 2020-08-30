#' @rdname db_getter_backend
#' @export
get_calpal <- function(db_url = get_db_url("calpal")) {

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
        "CALAGE",
        "CALSTD",
        "SITEINFO",
        "SUBPERIOD",
        "TABLE"
      ),
      colClasses = c(
        "METHOD" = "character",
        "LABNR" = "character",
        "C14AGE" = "character",
        "C14STD" = "character",
        "C13" = "character",
        "SITE" = "character",
        "SITETYPE" = "character",
        "PERIOD" = "character",
        "CULTURE" = "character",
        "MATERIAL" = "character",
        "SPECIES" = "character",
        "COUNTRY" = "character",
        "LATITUDE" = "character",
        "LONGITUDE" = "character",
        "REFERENCE" = "character"
      ),
      showProgress = FALSE
    ) %>%
    dplyr::transmute(
      method = .data[["METHOD"]],
      labnr = .data[["LABNR"]],
      c14age = .data[["C14AGE"]],
      c14std = .data[["C14STD"]],
      c13val = .data[["C13"]],
      site = .data[["SITE"]],
      sitetype = .data[["SITETYPE"]],
      period = .data[["PERIOD"]],
      culture = .data[["CULTURE"]],
      material = .data[["MATERIAL"]],
      species = .data[["SPECIES"]],
      country = .data[["COUNTRY"]],
      lat = .data[["LATITUDE"]],
      lon = .data[["LONGITUDE"]],
      shortref = .data[["REFERENCE"]]
    ) %>% dplyr::mutate(
      sourcedb = "calpal",
      sourcedb_version = get_db_version("calpal")
    ) %>%
    as.c14_date_list()

  return(calpal)
}
