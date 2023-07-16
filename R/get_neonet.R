#' @rdname db_getter_backend
#' @export
get_neonet <- function(db_url = get_db_url("neonet")) {

  check_connection_to_url(db_url)

  c14dates <- read.table(db_url, quote = "", sep = "\t", header = T)

  neonet <- c14dates %>%
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
      sourcedb = "neonet",
      sourcedb_version = get_db_version("neonet")
    ) %>%
    as.c14_date_list()

  return(neonet)
}
