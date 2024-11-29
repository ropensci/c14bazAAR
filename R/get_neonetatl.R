#' @rdname db_getter_backend
#' @export
get_neonetatl <- function(db_url = get_db_url("neonetatl")) {

  check_connection_to_url(db_url)

  c14dates <- data.table::fread(
    db_url,
    na.strings = c("NA","n/a","n/d"),
    colClasses = "character",
    showProgress = FALSE
  )

  neonetatl <- c14dates %>%
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
      sourcedb = "neonetatl",
      sourcedb_version = get_db_version("neonetatl")
    ) %>%
    as.c14_date_list()

  return(neonetatl)
}
