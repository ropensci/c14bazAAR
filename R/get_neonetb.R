#' @rdname db_getter_backend
#' @export
get_neonetb <- function(db_url = get_db_url("neonetb")) {

  check_connection_to_url(db_url)

  c14dates <- data.table::fread(db_url, na.strings = c("NA","n/a","n/d"))

  neonetb <- c14dates %>%
    dplyr::transmute(
      labnr = .data[["LabCode"]],
      c14age = .data[["C14Age"]],
      c14std = .data[["C14SD"]],
      site = .data[["SiteName"]],
      feature = .data[["PhaseCode"]],
      period = .data[["Period"]],
      material = .data[["Material"]],
      species = .data[["MaterialSpecies"]],
      country = .data[["Country"]],
      lat = .data[["Latitude"]],
      lon = .data[["Longitude"]],
      shortref = .data[["bib"]],
    ) %>% dplyr::mutate(
      sourcedb = "neonetb",
      sourcedb_version = get_db_version("neonetb")
    ) %>%
    as.c14_date_list()

  return(neonetb)
}
