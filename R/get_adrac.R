#' @rdname db_getter
#' @export
get_aDRAC <- function(db_url = get_db_url("aDRAC")) {

  check_connection_to_url(db_url)

  # read data
  aDRAC <- db_url %>%
    readr::read_csv(
      trim_ws = TRUE,
      col_types = readr::cols(
        LABNR = readr::col_character(),
        C14AGE = readr::col_character(),
        C14STD = readr::col_character(),
        C13 = readr::col_character(),
        MATERIAL = readr::col_character(),
        SITE = readr::col_character(),
        COUNTRY = readr::col_character(),
        FEATURE = readr::col_character(),
        FEATURE_DESC = "_",
        LAT = readr::col_character(),
        LONG = readr::col_character(),
        SOURCE = readr::col_character()
      )
    ) %>%
    dplyr::transmute(
      labnr = .data[["LABNR"]],
      c14age = .data[["C14AGE"]],
      c14std = .data[["C14STD"]],
      c13val = .data[["C13"]],
      material = .data[["MATERIAL"]],
      site = .data[["SITE"]],
      country = .data[["COUNTRY"]],
      feature = .data[["FEATURE"]],
      lat = .data[["LAT"]],
      lon = .data[["LONG"]],
      shortref = .data[["SOURCE"]]
    ) %>% dplyr::mutate(
      sourcedb = "aDRAC"
    ) %>%
    as.c14_date_list()

  return(aDRAC)
}
