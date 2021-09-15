#' @rdname db_getter_backend
#' @export
get_rxpand <- function(db_url = get_db_url("rxpand")) {

  check_connection_to_url(db_url)

  rxpand <- db_url %>%
    data.table::fread(
      drop = c(
        "FullReference",
        "Exclude",
        "Class"
      ),
      colClasses = "character",
      showProgress = FALSE,
      encoding = "UTF-8"
    ) %>%
    base::replace(., . == "", NA) %>%
    dplyr::transmute(
      labnr = .data[["LabCode"]],
      c14age = .data[["C14Age"]],
      c14std = .data[["C14SD"]],
      material = .data[["Material"]],
      site = .data[["Site"]],
      feature = .data[["Description"]],
      culture = .data[["Culture"]],
      lat = .data[["Latitude"]],
      lon = .data[["Longitude"]],
      comment = .data[["Comments"]],
      shortref = .data[["Reference"]]
    ) %>%
    dplyr::mutate(
      sourcedb = "rxpand",
      sourcedb_version = get_db_version("rxpand")
    ) %>%
    as.c14_date_list()

  return(rxpand)
}
