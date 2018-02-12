#' get_country_thesaurus
#'
#' Download thesaurus and provide it as tibble.
#'
#' @export
get_country_thesaurus <- function() {
  "https://raw.githubusercontent.com/ISAAKiel/c14bazAAR/master/data-raw/country_thesaurus.csv" %>%
    get_thesaurus() %>%
    return()
}

#' get_material_thesaurus
#'
#' Download thesaurus and provide it as tibble.
#'
#' @export
get_material_thesaurus <- function() {
  "https://raw.githubusercontent.com/ISAAKiel/c14bazAAR/master/data-raw/material_thesaurus.csv" %>%
    get_thesaurus() %>%
    return()
}

get_thesaurus <- function(url) {
  readr::read_csv(
    url,
    col_types = readr::cols(
      cor = readr::col_character(),
      var = readr::col_character()
    ),
    trim_ws = TRUE
  )
}
