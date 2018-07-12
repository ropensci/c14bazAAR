#' @rdname db_getter
#' @export
get_AustArch <- function(db_url = get_db_url("AustArch")) {

  check_connection_to_url(db_url)

  # read data
  AustArch <- data.table::fread(
    db_url,
    drop = c(
      "ADSID",
      "C13_ERROR",
      "MATERIAL_TOP_LEVEL",
      "DEPTH_FROM_SURFACE_CM",
      "TECHNIQUE",
      "Data pertinent for time-series analysis or calibration",
      "Open or Closed Site",
      "Directly Related to occupation? Yes/Unknown",
      "RECORD_SOURCE",
      "DATE_ISSUES",
      "AGE_NORM",
      "ADDITIONAL_DATA_ISSUES"
    ),
    colClasses = c(
      "IBRA_REGION" = "character",
      "LONGITUDE" = "character",
      "LATITUDE" = "character",
      "SITE" = "character",
      "SITE_TYPE" = "character",
      "LAB_CODE" = "character",
      "AGE" = "character",
      "ERROR" = "character",
      "C13_AGE" = "character",
      "MATERIAL" = "character",
      "CONTEXT" = "character",
      "METHOD" = "character",
      "SOURCE" = "character",
      "NOTES" = "character"
    ),
    data.table = FALSE
  ) %>%
    dplyr::transmute(
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
      region = .data[["IBRA_REGION"]],
      sitetype = .data[["SITE_TYPE"]],
      method = .data[["METHOD"]],
      comment = .data[["NOTES"]]
    ) %>% dplyr::mutate(
      sourcedb = "AustArch"
    ) %>%
    # AustArch also contains dates from other dating
    # methods (OSL, TL, U-Series, etc.)
    dplyr::filter(
      .data$method == "Radiocarbon"
    ) %>%
    as.c14_date_list()

  return(AustArch)
}
