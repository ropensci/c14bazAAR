#' get current EUROEVOL-Database
#'
#' Downloads the current version of the EUROEVOL-Database from \url{http://discovery.ucl.ac.uk/1469811/}.
#'
#' @examples
#'
#' \dontrun{
#'   EUROEVOL <- get_EUROEVOL()
#' }
#'
#' @export
get_EUROEVOL <- function() {

  # URL
  db_url1 <- "http://discovery.ucl.ac.uk/1469811/7/EUROEVOL09-07-201516-34_C14Samples.csv"
  db_url2 <- "http://discovery.ucl.ac.uk/1469811/9/EUROEVOL09-07-201516-34_CommonSites.csv"
  db_url3 <- "http://discovery.ucl.ac.uk/1469811/8/EUROEVOL09-07-201516-34_CommonPhases.csv"

  # check connection
  if (!curl::has_internet()) {stop("No internet connection.")}
  if (!RCurl::url.exists(db_url1)) {stop(paste(db_url1, "is not available."))}
  if (!RCurl::url.exists(db_url2)) {stop(paste(db_url2, "is not available."))}
  if (!RCurl::url.exists(db_url3)) {stop(paste(db_url3, "is not available."))}

  # read dates data
  dates <- db_url1 %>%
    readr::read_csv(
      col_types = readr::cols(
        C14ID = readr::col_integer(),
        Period = readr::col_character(),
        C14Age = readr::col_integer(),
        C14SD = readr::col_integer(),
        LabCode = readr::col_character(),
        PhaseCode = readr::col_character(),
        SiteID = readr::col_character(),
        Material = readr::col_character(),
        MaterialSpecies = readr::col_character()
      )
    )

  # read site data
  sites <- db_url2 %>%
    readr::read_csv(
        col_types = readr::cols(
        Country = readr::col_character(),
        Latitude = readr::col_double(),
        Longitude = readr::col_double(),
        SiteID = readr::col_character(),
        SiteName = readr::col_character()
      )
    )

  # read phases data
  phases <- db_url3 %>%
    readr::read_csv(
      col_types = readr::cols(
        Culture = readr::col_character(),
        Subculture = readr::col_character(),
        Period = readr::col_character(),
        PhaseCode = readr::col_character(),
        SiteID = readr::col_character(),
        Type = readr::col_character()
      )
    ) %>%
    dplyr::select(
      -.data[["Period"]], -.data[["SiteID"]]
    )

  # merge and prepare
  EUROEVOL <- dates %>%
    # merge
    dplyr::left_join(sites, by = "SiteID") %>%
    dplyr::left_join(phases, by = "PhaseCode") %>%
    # remove unnecessary variables
    dplyr::select(
      -.data[["PhaseCode"]], -.data[["SiteID"]]
    ) %>%
    # rename variables
    dplyr::rename(
      id = .data[["C14ID"]],
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
      subculture = .data[["Subculture"]],
      sitetype = .data[["Type"]]
    ) %>%
    # add class attribute
    `class<-`(
      c("c14_date_list", class(.))
    ) %>%
    c14databases::order_variables()

  return(EUROEVOL)
}
