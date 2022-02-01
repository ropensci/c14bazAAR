#' @rdname db_getter_backend
#' @export
get_p3k14c <- function(db_url = get_db_url("p3k14c")) {

  check_connection_to_url(db_url)

  # download and unzip data
  p3k14c <- db_url %>%
    data.table::fread(
      colClasses = "character",
      showProgress = FALSE,
      na.strings = ""
    ) %>%
    dplyr::mutate(
      d13C = suppressWarnings(as.numeric(.data[["d13C"]])),
      d13C = ifelse(.data[["d13C"]] == 0, NA, .data[["d13C"]])
    ) %>%
    dplyr::transmute(
      labnr = .data[["LabID"]],
      c14age = .data[["Age"]],
      c13val = .data[["d13C"]],
      c14std = .data[["Error"]],
      material = .data[["Material"]],
      species = .data[["Taxa"]],
      site = .data[["SiteName"]],
      method = .data[["Method"]],
      period = .data[["Period"]],
      region = .data[["Continent"]],
      country = .data[["Country"]],
      lat = .data[["Lat"]],
      lon = .data[["Long"]],
      shortref = ifelse(is.na(.data[["Reference"]]), .data[["Source"]], .data[["Reference"]])
    ) %>%
    dplyr::mutate(
      sourcedb = "p3k14c",
      sourcedb_version = get_db_version("p3k14c")
    ) %>%
    as.c14_date_list()

  return(p3k14c)
}
