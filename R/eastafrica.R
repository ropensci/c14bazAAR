#' get KITE East Africa v2.1.csv from ...
#'
#' See:
#' - A Database of Radiocarbon Dates for Palaeoenvironmental Research in Eastern Africa: https://www.openquaternary.com/articles/10.5334/oq.22/
#' - Radiocarbon dates from eastern Africa in the CARD2.0 format: https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/NJLNRJ
#'
#' The dataset is stored within https://dataverse.harvard.edu that requires the dataverse-package (see https://cran.r-project.org/web/packages/dataverse/vignettes/C-retrieval.html)
#'
#' @examples
#'
#' \dontrun{
#'   KITEeastAfrica <- get_KITEeastAfrica()
#' }
#'
#' @export
get_KITEeastAfrica <- function() {

  # URL
  db_url <- "https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/NJLNRJ"

  # check connection
  if (!RCurl::url.exists(db_url)) {stop(paste(db_url, "is not available. No internet connection?"))}

  # download data to temporary file
  tempo <- tempfile()

  Sys.setenv("DATAVERSE_SERVER" = "dataverse.harvard.edu")
  writeBin(get_file("CARD Upload Template - KITE East Africa v2.1.csv", "doi:10.7910/DVN/NJLNRJ"), tempo)

  # read data
  KITEeastafrica <- readr::read_csv("data-raw/KITE_EastAfrica.csv",
      skip = 3,
      trim_ws = TRUE,
      col_types = list(
        'Field Number'='_',
        'Taxa Dated'= '_',
        'Type of Date'= '_',
        'Locality' = '_',
        'Map Sheet' = '_',
        'Elevation     (m ASL)' = '_',
        'Submitter' = '_',
        'Date Submitted' = '_',
        'Collector' = '_',
        'Date Collected' = '_',
        'Updater' = '_',
        'Date Updated' = '_',
        'Measured Age' = '_',
        'MA Sigma' = '_',
        'Delta 13 C Source' = '_',
        'Significance' = '_',
        'Site Name' = '_',
        'Stratigraphic Component' = '_',
        'Context' = '_',
        'Associated Taxa' = '_',
        'Additional Information' = '_',
        'Comments' = '_'
        )) %>%
    dplyr::rename(
      labnr = .data[["Lab Number"]],
      c14age = .data[["Normalized Age"]],
      c14std = .data[["NA Sigma"]],
      c13val = .data[["Delta 13C (per mil)"]],
      material = .data[["Material Dated"]],
      site = .data[["Site Identifier"]],
      lat = .data[["Latitude"]],
      lon = .data[["Longitude"]],
      shortref = .data[["References"]]
    ) %>% dplyr::mutate(
      sourcedb = "KITEeastafrica"
    ) %>%
    as.c14_date_list() %>%
    c14bazAAR::order_variables()

  return(KITEeastafrica)

}
