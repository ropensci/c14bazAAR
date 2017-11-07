#' get AustArch: A Database of 14C and Luminescence Ages from Archaeological Sites in Australia
#'
#' See:
#' - AustArch: A Database of 14C and Non-14C Ages from Archaeological Sites in Australia - Composition, Compilation and Review (Data Paper) http://intarch.ac.uk/journal/issue36/6/williams.html
#' - AustArch: A Database of 14C and Luminescence Ages from Archaeological Sites in Australia http://archaeologydataservice.ac.uk/archives/view/austarch_na_2014/
#'
#' @examples
#'
#' \dontrun{
#'   AustArch <- get_AustArch()
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
        AGE = readr::col_integer(),
        ERROR = readr::col_integer(),
        C13_AGE = readr::col_double(),
        C13_ERROR = readr::col_double(),
        MATERIAL = readr::col_character(),
        MATERIAL_TOP_LEVEL = readr::col_character(),
        CONTEXT = readr::col_character(),
        DEPTH_FROM_SURFACE_CM = readr::col_character(),
        METHOD = readr::col_character(),
        TECHNIQUE = readr::col_character(),
        'Data pertinent for time-series analysis or calibration' = readr::col_character(),
        'Open or Closed Site' = readr::col_character(),
        'Directly Related to occupation? Yes/Unknown' = readr::col_character(),
        SOURCE = readr::col_character(),
        NOTES = readr::col_character(),
        RECORD_SOURCE = readr::col_character(),
        DATE_ISSUES = readr::col_character(),
        AGE_NORM = readr::col_integer(),
        ADDITIONAL_DATA_ISSUES = readr::col_character()
      )
    ) %>% dplyr::select(-c(X27)) %>% # removing additonal column that get's added due to trailing comma
    dplyr::rename(
      labnr = .data[["LAB_CODE"]],
      c14age = .data[["AGE"]],
      c14std = .data[["ERROR"]],
      c13val = .data[["C13_AGE"]],
      material = .data[["MATERIAL"]],
      site = .data[["SITE"]],
      lat = .data[["LATITUDE"]],
      lon = .data[["LONGITUDE"]],
      feature = .data[["CONTEXT"]],
      shortref = .data[["SOURCE"]],
      adsid = .data[["ADSID"]],
      region = .data[["IBRA_REGION"]],
      site_type = .data[["SITE_TYPE"]],
      c13error = .data[["C13_ERROR"]],
      material_class = .data[["MATERIAL_TOP_LEVEL"]],
      depth = .data[["DEPTH_FROM_SURFACE_CM"]],
      method = .data[["METHOD"]],
      technique = .data[["TECHNIQUE"]],
      timeseries = .data[["Data pertinent for time-series analysis or calibration"]],
      site_open_closed = .data[["Open or Closed Site"]],
      site_occipation = .data[["Directly Related to occupation? Yes/Unknown"]],
      notes = .data[["NOTES"]],
      record_c14 = .data[["RECORD_SOURCE"]],
      age_norm = .data[["AGE_NORM"]],
      data_issues = .data[["DATE_ISSUES"]],
      data_issues_additionl = .data[["ADDITIONAL_DATA_ISSUES"]]
    ) %>% dplyr::mutate(
      sourcedb = "AustArch"
    ) %>%
    as.c14_date_list() %>%
    c14bazAAR::order_variables()

  return(AustArch)

}
