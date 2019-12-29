#' @rdname db_getter_backend
#' @export
get_euroevol <- function(db_url = get_db_url("euroevol")) {

  db_url1 <- db_url[1]
  db_url2 <- db_url[2]
  db_url3 <- db_url[3]

  check_connection_to_url(db_url1)
  check_connection_to_url(db_url2)
  check_connection_to_url(db_url3)

  # read dates data
  dates <- db_url1 %>%
    data.table::fread(
      colClasses = c(
        C14ID = "character",
        Period = "character",
        C14Age = "character",
        C14SD = "character",
        LabCode = "character",
        PhaseCode = "character",
        SiteID = "character",
        Material = "character",
        MaterialSpecies = "character"
      ),
      showProgress = FALSE
    )

  # read site data
  sites <- db_url2 %>%
    data.table::fread(
      sep = ",",
      colClasses = c(
        Country = "character",
        Latitude = "character",
        Longitude = "character",
        SiteID = "character",
        SiteName = "character"
      ),
      showProgress = FALSE
    )

  # read phases data
  phases <- db_url3 %>%
    data.table::fread(
      drop = c(
        "Subculture"
      ),
      colClasses = c(
        Culture = "character",
        Period = "character",
        PhaseCode = "character",
        SiteID = "character",
        Type = "character"
      ),
      showProgress = FALSE
    ) %>%
    dplyr::select(-.data[["Period"]], -.data[["SiteID"]])

  # merge and prepare
  euroevol <- dates %>%
    # merge
    dplyr::left_join(sites, by = "SiteID") %>%
    dplyr::left_join(phases, by = "PhaseCode") %>%
    base::replace(., . == "NULL", NA) %>%
    base::replace(., . == "", NA) %>%
    dplyr::transmute(
      labnr = .data[["LabCode"]],
      c14age = .data[["C14Age"]],
      c14std = .data[["C14SD"]],
      material = .data[["Material"]],
      species = .data[["MaterialSpecies"]],
      country = .data[["Country"]],
      lat = .data[["Latitude"]],
      lon = .data[["Longitude"]],
      site = .data[["SiteName"]],
      period = .data[["Period"]],
      culture = .data[["Culture"]],
      sitetype = .data[["Type"]]
    ) %>% dplyr::mutate(
      sourcedb = "euroevol",
      sourcedb_version = get_db_version("euroevol")
    ) %>%
    as.c14_date_list()

  return(euroevol)
}
