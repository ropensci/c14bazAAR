#' @rdname db_getter
#' @export
get_KITEeastAfrica <- function(db_url = get_db_url("KITEeastAfrica")) {

  check_connection_to_url(db_url)

  # download data to temporary file
  tempo <- tempfile()

  writeBin(
    dataverse::get_file(
      "CARD Upload Template - KITE East Africa v2.1.csv", "doi:10.7910/DVN/NJLNRJ",
      server = "dataverse.harvard.edu"
    ),
    tempo
  )

  # read data
  KITEeastafrica <- tempo %>%
    data.table::fread(
      skip = 3,
      encoding = "Latin-1",
      drop = c(
        "Field Number",
        "Type of Date",
        "Locality",
        "Map Sheet",
        "Elevation     (m ASL)",
        "Submitter",
        "Date Submitted",
        "Collector",
        "Date Collected",
        "Updater",
        "Date Updated",
        "Measured Age",
        "MA Sigma",
        "Delta 13 C Source",
        "Significance",
        "Stratigraphic Component",
        "Context",
        "Associated Taxa"
      ),
      colClasses = c(
        "Lab Number" = "character",
        "Material Dated" = "character",
        "Taxa Dated" = "character",
        "Latitude" = "character",
        "Longitude" = "character",
        "Normalized Age" = "character",
        "NA Sigma" = "character",
        "Delta 13C (per mil)" = "character",
        "Site Identifier" = "character",
        "Site Name" = "character",
        "Additional Information" = "character",
        "Comments" = "character",
        "References" = "character"
      ),
      showProgress = FALSE
    ) %>%
    base::replace(., . == "", NA) %>%
    dplyr::transmute(
      labnr = .data[["Lab Number"]],
      c14age = .data[["Normalized Age"]],
      c14std = .data[["NA Sigma"]],
      c13val = .data[["Delta 13C (per mil)"]],
      material = .data[["Material Dated"]],
      species = .data[["Taxa Dated"]],
      site = .data[["Site Identifier"]],
      lat = .data[["Latitude"]],
      lon = .data[["Longitude"]],
      shortref = .data[["References"]],
      feature = .data[["Site Name"]],
      comment = gsub("^, $", NA, paste0(.data[["Comments"]], .data[["Additional Information"]], sep = ", "))
    ) %>% dplyr::mutate(
      sourcedb = "KITEeastafrica"
    ) %>%
    as.c14_date_list()

  return(KITEeastafrica)

}
