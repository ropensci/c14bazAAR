#' @rdname db_getter_backend
#' @export
get_CalPal <- function(db_url = get_db_url("CalPal")) {

  check_connection_to_url(db_url)

  # read data
  CALPAL <- db_url %>%
    data.table::fread(
      drop = c(
        "ID",
        "PHASE",
        "LOCUS"
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
        "LATITUDE" = "character",
        "LONGITUDE" = "character",
        "METHOD" = "character",
        "REFERENCE" = "character",
        "NOTICE" = "character"
      ),
      showProgress = FALSE
    ) %>%
    base::replace(., . == "", NA) %>%
    base::replace(., . == "nd", NA) %>%
    base::replace(., . == "--", NA) %>%
    base::replace(., . == "n/a", NA) %>%
    base::replace(., . == "NoCountry", NA) %>%
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
      shortref = .data[["REFERENCE"]],
      comment = .data[["NOTICE"]]
    ) %>% dplyr::mutate(
      sourcedb = "CALPAL"
    ) %>%
    as.c14_date_list()

  return(CALPAL)
}
