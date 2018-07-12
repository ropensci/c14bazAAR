#' get db url
#'
#' Downloads URLs of c14 source databases from a reference table
#' on github.
#'
#' @param db_name name of the database
#'
#' @export
get_db_url <- function(db_name) {

  # URL
  ref_url <- "https://raw.githubusercontent.com/ISAAKiel/c14bazAAR/master/data-raw/url_reference.csv"

  check_connection_to_url(ref_url)

  # download current version of reference table
  url_table <- readr::read_csv(
    ref_url,
    col_types = readr::cols(
      db = readr::col_character(),
      url_num = readr::col_integer(),
      url = readr::col_character()
    )
  )

  # extract urls
  url_tab <- url_table %>%
    dplyr::arrange(.data[["db"]], .data[["url_num"]]) %>%
    dplyr::filter(
      tolower(.data[["db"]]) == tolower(db_name)
    )
  url_vec <- url_tab[["url"]]

  return(url_vec)
}
