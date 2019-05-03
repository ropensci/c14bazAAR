#' @rdname db_getter
#' @export
# get_Palmisano <- function(db_url = get_db_url("Palmisano")) {

  db_url <- "http://discovery.ucl.ac.uk/1575442/1/Palmisanoetal.zip"

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
    encoding = "Latin-1",
    drop = c(
      "DateID",
      "LocQual"
    ),
    colClasses = c(
      "LabID" = "character",
      "CRA" = "character",
      "Error" = "character",
      "Material" = "character",
      "Species" = "character",
      "SiteID" = "character",
      "SiteName" = "character",
      "Longitude" = "character",
      "Latitude" = "character",
      "Source" = "character"
    ),
    showProgress = FALSE
  )

  sites_raw <- data.table::fread(
    sites_path,
    sep = ",",
    encoding = "Latin-1",
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
    colClasses = c(
      "Id" = "character",
      "Type" = "character",
      "Period" = "character",
      "StartDate" = "character",
      "EndDate" = "character"
    ),
    showProgress = FALSE
  )

  # remove files in file system
  unlink(temp)
  file.remove(radiocarbon_path)
  file.remove(sites_path)

  # merge data

# }
