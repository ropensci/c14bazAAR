#' get KITE East Africa v2.1.csv from ...
#'
#' See:
#' - A Database of Radiocarbon Dates for Palaeoenvironmental Research in Eastern Africa: https://www.openquaternary.com/articles/10.5334/oq.22/
#' - Radiocarbon dates from eastern Africa in the CARD2.0 format: https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/NJLNRJ
#'
#' The dataset is stored within https://dataverse.harvard.edu that requires the dataverse-package (see https://cran.r-project.org/web/packages/dataverse/vignettes/C-retrieval.html)
#'
#' @param db_url string with weblink to c14 archive file
#'
#' @examples
#'
#' \dontrun{
#'   KITEeastAfrica <- get_KITEeastAfrica()
#' }
#'
#' @export
get_KITEeastAfrica <- function(db_url = get_db_url("KITEeastAfrica")) {

  # check connection
  if (!RCurl::url.exists(db_url)) {stop(paste(db_url, "is not available. No internet connection?"))}

  # download data to temporary file
  tempo <- tempfile()

  Sys.setenv("DATAVERSE_SERVER" = "dataverse.harvard.edu")
  writeBin(dataverse::get_file("CARD Upload Template - KITE East Africa v2.1.csv", "doi:10.7910/DVN/NJLNRJ"), tempo)

  # read data
  KITEeastafrica <- tempo %>%
    readr::read_csv(
      skip = 3,
      trim_ws = TRUE,
      col_types = readr::cols(
        "Lab Number" = readr::col_character(),
        "Field Number" = "_", # `= "_"` removes/skips the column
        "Material Dated" = readr::col_character(),
        "Taxa Dated" = "_",
        "Type of Date" = readr::col_character(),
        "Locality" = "_",
        "Latitude" = readr::col_double(),
        "Longitude" = readr::col_double(),
        "Map Sheet" = "_",
        "Elevation     (m ASL)" = readr::col_integer(),
        "Submitter" = "_",
        "Date Submitted" = "_",
        "Collector" = readr::col_character(),
        "Date Collected" = "_",
        "Updater" = readr::col_character(),
        "Date Updated" = readr::col_date(format = "%d/%m/%Y"),
        "Measured Age" = "_",
        "MA Sigma" = "_",
        "Normalized Age" = readr::col_integer(),
        "NA Sigma" = readr::col_integer(),
        "Delta 13C (per mil)" = readr::col_double(),
        "Delta 13 C Source" = readr::col_character(),
        "Significance" = "_",
        "Site Identifier" = readr::col_character(),
        "Site Name" = readr::col_character(),
        "Stratigraphic Component" = "_",
        "Context" = "_",
        "Associated Taxa" = readr::col_character(),
        "Additional Information" = readr::col_character(),
        "Comments" = readr::col_character()
      )
    ) %>%
    dplyr::rename(
      labnr = .data[["Lab Number"]],
      c14age = .data[["Normalized Age"]],
      c14std = .data[["NA Sigma"]],
      c13val = .data[["Delta 13C (per mil)"]],
      material = .data[["Material Dated"]],
      site = .data[["Site Identifier"]],
      lat = .data[["Latitude"]],
      lon = .data[["Longitude"]],
      shortref = .data[["References"]],
      type_date= .data[["Type of Date"]],
      elevation = .data[["Elevation     (m ASL)"]],
      collector = .data[["Collector"]],
      updater = .data[["Updater"]],
      date_updated = .data[["Date Updated"]],
      delta_13c_source = .data[["Delta 13 C Source"]],
      site_additional = .data[["Site Name"]],
      taxa_associated = .data[["Associated Taxa"]],
      additional_information = .data[["Additional Information"]],
      comments = .data[["Comments"]]
    ) %>% dplyr::mutate(
      sourcedb = "KITEeastafrica"
    ) %>%
    as.c14_date_list() %>%
    c14bazAAR::order_variables() %>%
    c14bazAAR::enforce_types()

  return(KITEeastafrica)

}
