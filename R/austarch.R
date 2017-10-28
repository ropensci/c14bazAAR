#' get current AustArch-Database
#'
#' Downloads the current version of the AustArch-Database from \url{http://archaeologydataservice.ac.uk/archives/view/austarch_na_2014/}.
#'
#' @examples
#'
#' \dontrun{
#'   CARD <- get_CARD()
#' }
#'
#' @export
get_AustArch <- function() {

  # URL
  db_url <- "http://archaeologydataservice.ac.uk/catalogue/adsdata/arch-1661-1/dissemination/csv/Austarch_1-3_and_IDASQ_28Nov13-1.csv"

  # check connection
  if (!RCurl::url.exists(db_url)) {stop(paste(db_url, "is not available. No internet connection?"))}

  # read data
  AustArch <- db_url %>%
    readr::read_csv(
      trim_ws = TRUE,
      col_types = readr::cols(
        ADSID = readr::col_integer(),
        IBRA_REGION = readr::col_character(),
        LONGITUDE = readr::col_double(),
        LATITUDE = readr::col_double(),
        SITE = readr::col_character(),
        SITE_TYPE = readr::col_character(),
        LAB_CODE = readr::col_character(),
        AGE = readr::col_character(),
        ERROR = readr::col_character(),
        C13_AGE = readr::col_double(),
        C13_ERROR = readr::col_double(),
        MATERIAL = readr::col_character(),
        MATERIAL_TOP_LEVEL = readr::col_character(),
        CONTEXT = readr::col_character(),
        DEPTH_FROM_SURFACE_CM = readr::col_character(),
        METHOD = readr::col_character(),
        TECHNIQUE = readr::col_character(),
        `Data pertinent for time-series analysis or calibration` = readr::col_character(),
        `Open or Closed Site` = readr::col_character(),
        `Directly Related to occupation? Yes/Unknown` = readr::col_character(),
        SOURCE = readr::col_character(),
        NOTES = readr::col_character(),
        RECORD_SOURCE = readr::col_character(),
        DATE_ISSUES = readr::col_character(),
        AGE_NORM = readr::col_integer(),
        ADDITIONAL_DATA_ISSUES = readr::col_character(),
        X27 = readr::col_character()
      )
    ) #%>%
    # dplyr::rename(
    #   labnr = .data[["LABNR"]],
    #   c14age = .data[["C14AGE"]],
    #   c14std = .data[["C14STD"]],
    #   c13val = .data[["C13"]],
    #   material = .data[["MATERIAL"]],
    #   site = .data[["SITE"]],
    #   country = .data[["COUNTRY"]],
    #   feature = .data[["FEATURE"]],
    #   featuredescription = .data[["FEATURE_DESC"]],
    #   lat = .data[["LAT"]],
    #   lon = .data[["LONG"]],
    #   shortref = .data[["SOURCE"]]
    # ) %>% dplyr::mutate(
    #   sourcedb = "aDRAC"
    # ) %>%
    # as.c14_date_list() %>%
    # c14bazAAR::order_variables()

  return(AustArch)
}
