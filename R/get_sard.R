#' @rdname db_getter_backend
#' @export
get_sard <- function(db_url = get_db_url("sard")) {

  # read data
  sard <- db_url %>%
    data.table::fread(
      drop = c(),
      colClasses = c(
        "Lab ID" = "character",
        "Date" = "character",
        "Uncertainty" = "character",
        "delta 13" = "character",
        "Species" = "character",
        "Material dated" = "character",
        "Dating technique" = "character",
        "Site" = "character",
        "Country" = "character",
        "Stratigraphic context" = "character",
        "Archaeological Period" = "character",
        "Archaeological Sub-chronology" = "character",
        "DecdegS" = "character",
        "DecdegE" = "character",
        "Notes" = "character",
        "refcode" = "character"
      ),
      showProgress = FALSE
    ) %>%
    dplyr::transmute(
      labnr = .data[["Lab ID"]],
      c14age = .data[["Date"]],
      c14std = .data[["Uncertainty"]],
      c13val = .data[["delta 13"]],
      species = .data[["Species"]],
      material = .data[["Material dated"]],
      method = .data[["Dating technique"]],
      site = .data[["Site"]],
      country = .data[["Country"]],
      feature = .data[["Stratigraphic context"]],
      culture = .data[["Archaeological Period"]],
      period = .data[["Archaeological Sub-chronology"]],
      lat = .data[["DecdegS"]],
      lon = .data[["DecdegE"]],
      comment = .data[["Notes"]],
      shortref = .data[["refcode"]]
    ) %>%
    dplyr::filter(
      .data$c14age != ''
    ) %>%
    dplyr::mutate(
      sourcedb = "sard",
      sourcedb_version = get_db_version("sard")
    ) %>%
    as.c14_date_list()

  return(sard)
}
