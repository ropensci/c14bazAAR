#' @rdname db_getter_backend
#' @export
get_palmisano <- function(db_url = get_db_url("palmisano")) {

  check_connection_to_url(db_url)

  # download and unzip data
  temp <- tempfile()
  utils::download.file(db_url, temp, quiet = TRUE)
  radiocarbon_path <- utils::unzip(
    temp,
    file.path(
      "Palmisanoetal", "csv", "radiocarbon.csv"
    ),
    exdir = tempdir()
  )
  sites_path <- utils::unzip(
    temp,
    file.path(
      "Palmisanoetal", "csv", "sites.csv"
    ),
    exdir = tempdir()
  )

  # read data
  radiocarbon_raw <- data.table::fread(
    radiocarbon_path,
    sep = ",",
    encoding = "UTF-8",
    drop = c(
      "DateID",
      "LocQual"
    ),
    colClasses = "character",
    showProgress = FALSE
  )

  sites_raw <- data.table::fread(
    sites_path,
    sep = ",",
    encoding = "UTF-8",
    drop = c(
      "Toponyms",
      "Longitude",
      "Latitude",
      "LocQual",
      "SizeHa",
      "SizeQual",
      "Source",
      "Source_id"
    ),
    colClasses = "character",
    showProgress = FALSE
  )

  # remove files in file system
  unlink(temp)
  file.remove(radiocarbon_path)
  file.remove(sites_path)

  # merge data
  radiocarbon_additional_info <- radiocarbon_raw %>%
    dplyr::left_join(
      sites_raw,
      by = c("SiteID" = "Id")
    ) %>%
    dplyr::mutate(
      CRA_bc = 1950 - as.numeric(.data[["CRA"]]),
      StartDate = as.numeric(.data[["StartDate"]]),
      EndDate = as.numeric(.data[["EndDate"]])
    ) %>%
    dplyr::filter(
      .data[["CRA_bc"]] >= .data[["StartDate"]] & .data[["CRA_bc"]] < .data[["EndDate"]]
    )

  palmisano_raw <- radiocarbon_raw %>%
    dplyr::left_join(
      radiocarbon_additional_info,
      by = c("LabID", "CRA", "Error", "Material", "Species",
             "SiteID", "SiteName", "Longitude", "Latitude", "Source")
    )

  # final data preparation
  palmisano <- palmisano_raw %>%
    base::replace(., . == "", NA) %>%
    dplyr::transmute(
      labnr = .data[["LabID"]],
      c14age = .data[["CRA"]],
      c14std = .data[["Error"]],
      site = .data[["SiteName"]],
      sitetype = .data[["Type"]],
      material = .data[["Material"]],
      species = .data[["Species"]],
      period = .data[["Period"]],
      lat = .data[["Latitude"]],
      lon = .data[["Longitude"]],
      shortref = .data[["Source"]]
    ) %>% dplyr::mutate(
      sourcedb = "palmisano",
      sourcedb_version = get_db_version("palmisano")
    ) %>%
    as.c14_date_list()

  return(palmisano)
}
