#' get db info
#'
#' Downloads information for c14 source databases from a reference table
#' on github.
#'
#' @param db_name name of the database
#' @param info_type type of information: "url", "version"
#' @param ref_url url of the relevant reference table
#'
#' @export
get_db_info <- function(
  db_name, info_type = c("url", "version"), ref_url = paste(c(
    "https://raw.githubusercontent.com",
    "ropensci",
    "c14bazAAR",
    "master",
    "data-raw",
    "url_reference.csv"
  ), collapse = "/")) {

  #check_connection_to_url(ref_url)

  if (length(db_name) > 1) {
    stop("get_db_info only works for one database at a time")
  }
  info_type <- match.arg(info_type, c("url", "version"), several.ok = FALSE)

  # download current version of reference table
  db_info_table <- data.table::fread(
    ref_url,
    colClasses = c(
      "db" = "character",
      "version" = "character",
      "url_num" = "integer",
      "url" = "character"
    ),
    showProgress = FALSE,
    na.strings = c("datatable.na.strings", "", "NA")
  )

  # extract urls
  if (info_type == "url") {
    url_tab <- db_info_table %>%
      dplyr::arrange(.data[["db"]], .data[["url_num"]]) %>%
      dplyr::filter(
        tolower(.data[["db"]]) == tolower(db_name)
      )
    url_vec <- url_tab[["url"]]

    return(url_vec)
  }

  # extract versions
  if (info_type == "version") {
    version_tab <- db_info_table %>%
      dplyr::arrange(.data[["db"]], .data[["url_num"]]) %>%
      dplyr::filter(
        tolower(.data[["db"]]) %in% tolower(db_name)
      ) %>%
      dplyr::filter(!is.na(.data[["version"]]))
    db_version <- version_tab[["version"]]

    # replace today with current date
    if (db_version == "today") {
      db_version <- format(Sys.time(), "%Y-%m-%d")
    }

    # transform date string to class Date
    db_version_date <- as.Date(db_version, format = "%Y-%m-%d")

    return(db_version_date)
  }

}
