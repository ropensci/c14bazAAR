#' @rdname db_getter_backend
#' @export
get_nerd <- function(db_url = get_db_url("nerd")) {

  check_connection_to_url(db_url)

  nerd <- db_url %>%
    data.table::fread(
      drop = c(
        "DateID",
        "OthLabID",
        "Problems",
        "SiteID",
        "LocQual"
        ),
      colClasses = c(
        "LabID" = "character",
        "CRA" = "character",
        "Error" = "character",
        "DC13" = "character",
        "Material" = "character",
        "Species" = "character",
        "SiteName" = "character",
        "SiteContext" = "character",
        "SiteType" = "character",
        "Country" = "character",
        "Longitude" = "character",
        "Latitude" = "character",
        "Source" = "character",
        "Comments" = "character"
      ),
      showProgress = FALSE
    ) %>%
    base::replace(., . == "", NA) %>%
    dplyr::transmute(
      labnr = .data[["LabID"]],
      c14age = .data[["CRA"]],
      c14std = .data[["Error"]],
      c13val = .data[["DC13"]],
      material = .data[["Material"]],
      species = .data[["Species"]],
      site = .data[["SiteName"]],
      sitetype = .data[["SiteType"]],
      country = .data[["Country"]],
      feature = .data[["SiteContext"]],
      lat = .data[["Latitude"]],
      lon = .data[["Longitude"]],
      comment = .data[["Comments"]],
      shortref = .data[["Source"]]
    ) %>%
    dplyr::mutate(
      sourcedb = "nerd",
      sourcedb_version = get_db_version("nerd")
    ) %>%
    as.c14_date_list()

  return(nerd)
}
