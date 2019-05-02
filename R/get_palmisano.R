#' @rdname db_getter
#' @export
# get_Palmisano <- function(db_url = get_db_url("Palmisano")) {

  # db_url <- "http://discovery.ucl.ac.uk/1575442/1/Palmisanoetal.zip"
  #
  # check_connection_to_url(db_url)
  #
  # # download and unzip data
  # temp <- tempfile()
  # utils::download.file(db_url, temp, quiet = TRUE)
  # radiocarbon <- utils::unzip(
  #   temp,
  #   file.path(
  #     "Palmisanoetal", "csv", "radiocarbon.csv"
  #   ),
  #   exdir = tempdir()
  # )
  # sites <- utils::unzip(
  #   temp,
  #   file.path(
  #     "Palmisanoetal", "csv", "sites.csv"
  #   ),
  #   exdir = tempdir()
  # )
  #
  # # read data
  # Palmisano_raw <- data.table::fread(
  #   radiocarbon,
  #   sep = ",",
  #   encoding = "Latin-1",
  #   drop = c(
  #     "DateID",
  #     "LocQual"
  #   ),
  #   colClasses = c(
  #     "LabID" = "character",
  #     "CRA" = "character",
  #     "Error" = "character",
  #     "Material" = "character",
  #     "Species" = "character",
  #     "SiteID" = "character",
  #     "SiteName" = "character",
  #     "Longitude" = "character",
  #     "Latitude" = "character",
  #     "Source" = "character"
  #   ),
  #   showProgress = FALSE
  # )
  # unlink(temp)
  # file.remove(radiocarbon)

# }
