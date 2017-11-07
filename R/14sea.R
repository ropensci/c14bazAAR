#' get current 14SEA-Database
#'
#' Downloads the current version of the 14SEA-Database from \url{http:///www.14sea.org/}.
#'
#' @examples
#'
#' \dontrun{
#'   14SEA <- get_14SEA()
#' }
#'
#' @export
get_14SEA <- function() {

  # URL
  db_url <- "http://www.14sea.org/img/14SEA_Full_Dataset_2017-01-29.xlsx"

  # check connection
  if (!RCurl::url.exists(db_url)) {stop(paste(db_url, "is not available. No internet connection?"))}

  # download data to temporary file
  tempo <- tempfile()
  utils::download.file(db_url, tempo)

  # read data
  SEA14 <- tempo %>%
    readxl::read_xlsx(
      trim_ws = TRUE,
      na = c("Combination fails", "nd", "-"),
      col_types = c(
        "Site" = "text",
        "Subregion" = "text",
        "Subregion no." = "text",
        "Country" = "text",
        "Lab. no." = "text",
        "Date BP" = "text",
        "\u00B1" = "text",
        "\u03B413C" = "text",
        "calBC 1\u03C3 (from)" = "text",
        "calBC 1\u03C3 (to)" = "text",
        "Material" = "text",
        "Level" = "text",
        "Provenance" = "text",
        "Comment" = "text",
        "Period" = "text",
        "Reference 1" = "text",
        "Reference 2" = "text",
        "Reference 3" = "text",
        "Reference 4" = "text"
      )
    ) %>%
    dplyr::transmute(
      labnr = .data[["Lab. no."]],
      c14age = as.numeric(.data[["Date BP"]]),
      c14std = as.numeric(.data[["\u00B1"]]),
      c13val = as.numeric(.data[["\u03B413C"]]),
      material = .data[["Material"]],
      country = .data[["Country"]],
      region = .data[["Subregion"]],
      site = .data[["Site"]],
      lat = NA,
      lon = NA,
      period = .data[["Period"]],
      level = .data[["Level"]],
      feature = .data[["Provenance"]],
      shortref = {
        combined_ref <- paste0(
          ifelse(!is.na(.data[["Reference 1"]]), .data[["Reference 1"]], ""),
          ifelse(!is.na(.data[["Reference 1"]]) & !is.na(.data[["Reference 2"]]), ", ", ""),
          ifelse(!is.na(.data[["Reference 2"]]), .data[["Reference 2"]], ""),
          ifelse(!is.na(.data[["Reference 2"]]) & !is.na(.data[["Reference 3"]]), ", ", ""),
          ifelse(!is.na(.data[["Reference 3"]]), .data[["Reference 3"]], ""),
          ifelse(!is.na(.data[["Reference 3"]]) & !is.na(.data[["Reference 4"]]), ", ", ""),
          ifelse(!is.na(.data[["Reference 4"]]), .data[["Reference 4"]], "")
        )
        ifelse(nchar(combined_ref) == 0, NA, combined_ref)
      },
      comment = .data[["Comment"]]
    ) %>%
    dplyr::mutate(
      sourcedb = "14SEA"
    ) %>%
    as.c14_date_list() %>%
    c14bazAAR::order_variables()

    # delete temporary file
    unlink(tempo)

    return(SEA14)
}
