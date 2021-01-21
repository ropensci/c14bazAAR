#' @rdname db_getter_backend
#' @export
get_adrac <- function(db_url = get_db_url("adrac")) {

  check_connection_to_url(db_url)

  # read data
  adrac <- db_url %>%
    data.table::fread(
      drop = c(
        "FEATURE_DESC",
        "LITHICS",
        "POTTERY",
        "IRON",
        "FRUIT",
        "CLASS_DS.WH_etal_2021"
      ),
      colClasses = c(
        "LABNR" = "character",
        "C14AGE" = "character",
        "C14STD" = "character",
        "C13" = "character",
        "MATERIAL" = "character",
        "METHOD" = "character",
        "SITE" = "character",
        "COUNTRY" = "character",
        "FEATURE" = "character",
        "PHASE" = "character",
        "LAT" = "character",
        "LONG" = "character",
        "REMARK" = "character",
        "SOURCE" = "character"
      ),
      showProgress = FALSE
    ) %>%
    base::replace(., . == "", NA) %>%
    dplyr::transmute(
      labnr = .data[["LABNR"]],
      c14age = .data[["C14AGE"]],
      c14std = .data[["C14STD"]],
      c13val = .data[["C13"]],
      material = .data[["MATERIAL"]],
      method = .data[["METHOD"]],
      site = .data[["SITE"]],
      country = .data[["COUNTRY"]],
      feature = .data[["FEATURE"]],
      period = .data[["PHASE"]],
      lat = .data[["LAT"]],
      lon = .data[["LONG"]],
      comment = .data[["REMARK"]],
      shortref = .data[["SOURCE"]]
    ) %>%
    dplyr::filter(
      is.na(.data[["method"]]) | .data[["method"]] != "TL"
    ) %>%
    dplyr::mutate(
      sourcedb = "adrac",
      sourcedb_version = get_db_version("adrac")
    ) %>%
    as.c14_date_list()

  return(adrac)
}
