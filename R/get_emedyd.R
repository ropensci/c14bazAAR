#' @rdname db_getter_backend
#' @export
get_emedyd <- function(db_url = get_db_url("emedyd")) {

  check_connection_to_url(db_url)

  # download and unzip data
  temp <- tempfile()
  utils::download.file(db_url, temp, quiet = TRUE)
  radiocarbon_path <- utils::unzip(
    temp,
    file.path(
      "robertsetal17", "csv", "emedyd.csv"
    ),
    exdir = tempdir()
  )

  # read data
  radiocarbon_raw <- data.table::fread(
    radiocarbon_path,
    sep = ",",
    encoding = "UTF-8",
    drop = c("Region"),
    colClasses = c(
      "LabID" = "character",
      "CRA" = "integer",
      "Error" = "integer",
      "Material" = "character",
      "Species" = "character",
      "SiteName" = "character",
      "Country" = "character",
      "Longitude" = "numeric",
      "Latitude" = "numeric"
    ),
    showProgress = FALSE
  )

  # delete temporary files
  unlink(temp)
  file.remove(radiocarbon_path)

  # final data preparation
  radiocarbon_raw %>%
    base::replace(., . == "", NA) %>%
    dplyr::transmute(
      labnr = .data[["LabID"]],
      c14age = .data[["CRA"]],
      c14std = .data[["Error"]],
      material = .data[["Material"]],
      species = .data[["Species"]],
      site = .data[["SiteName"]],
      country  = .data[["Country"]],
      lat = .data[["Latitude"]],
      lon = .data[["Longitude"]]
    ) %>%
    dplyr::mutate(
      sourcedb = "emedyd",
      sourcedb_version = get_db_version("emedyd")
    ) %>%
    as.c14_date_list() ->
    emedyd

  return(emedyd)
}
