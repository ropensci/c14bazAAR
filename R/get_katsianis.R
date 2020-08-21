#' @rdname db_getter_backend
#' @export

get_katsianis <- function(db_url = get_db_url("katsianis")) {

  check_connection_to_url(db_url)

  # read data
  temp <- tempfile(fileext = ".zip")

  utils::download.file(db_url,
                       temp,
                       mode="wb",
                       quiet = TRUE)

  katsianis <- data.table::fread(
    unzip(temp,
          files = "C14Samples.txt"),
    sep = "\t",
    drop = c(
      "DBID",
      "OthLabID",
      "OthDateCode",
      "Problems",
      "OthMeasures"
    ),
    colClasses = c(
      "DateMethod" = "character",
      "LabID" = "character",
      "CRA" = "character",
      "Error" = "character",
      "DC13" = "character",
      "SiteName" = "character",
      "SiteType" = "character",
      "SiteContext" = "character",
      "SitePhase" = "character",
      "CulturalPeriod" = "character",
      "Material" = "character",
      "Species" = "character",
      "AdminRegion" = "character",
      "Country" = "character",
      "Latitude" = "character",
      "Longitude" = "character",
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
      method = .data[["DateMethod"]],
      material = .data[["Material"]],
      species = .data[["Species"]],
      site = .data[["SiteName"]],
      sitetype = .data[["SiteType"]],
      region = .data[["AdminRegion"]],
      country = .data[["Country"]],
      feature = .data[["SiteContext"]],
      period = .data[["SitePhase"]],
      culture = .data[["CulturalPeriod"]],
      lat = .data[["Latitude"]],
      lon = .data[["Longitude"]],
      shortref = .data[["Source"]],
      comment = .data[["Comments"]]
    ) %>% dplyr::mutate(
      sourcedb = "katsianis",
      sourcedb_version = get_db_version("katsianis")
    ) %>%
    as.c14_date_list()

  return(katsianis)
}
