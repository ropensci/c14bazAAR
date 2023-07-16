#' @rdname db_getter_backend
#' @export
get_neonet <- function(db_url = get_db_url("neonet")) {

  # db_url <- "http://mappaproject.arch.unipi.it/mod/files/140_140_id00140_doc_elencoc14.tsv"
  check_connection_to_url(db_url)

  c14dates <- read.table(db_url, quote = "", sep = "\t", header = T)

  neonet <- c14dates %>%
    dplyr::transmute(
      # method = .data[["Methode"]],
      labnr = .data[["LabCode"]],
      c14age = .data[["C14Age"]],
      c14std = .data[["C14SD"]],
      # c13val = .data[["delta13"]],
      site = .data[["SiteName"]],
      # sitetype = .data[["Nature_site"]],
      feature = .data[["PhaseCode"]],
      period = .data[["Period"]],
      # culture = .data[["culture"]],
      material = .data[["Material"]],
      species = .data[["MaterialSpecies"]],
      # region = .data[["Region"]],
      country = .data[["Country"]],
      lat = .data[["Latitude"]],
      lon = .data[["Longitude"]],
      shortref = .data[["bib"]],
      # comment = .data[["Fiabilite.x"]],
    ) %>% dplyr::mutate(
      sourcedb = "neonet",
      sourcedb_version = get_db_version("neonet")
    ) %>%
    as.c14_date_list()

  return(neonet)
}
