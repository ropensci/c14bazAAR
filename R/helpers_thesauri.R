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

#' get_thesaurus
#'
#' helper function to download thesaurus files
#'
#' @param url url of thesaurus csv file
#'
#' @return thesaurus data.frame
#'
#' @keywords internal
#' @noRd
get_thesaurus <- function(url) {
  data.table::fread(
    url,
    colClasses = c(
      "cor" = "character",
      "var" = "character"
    ),
    showProgress = FALSE
  ) %>%
    tibble::as_tibble()
}

#' print_lookup_decisions
#'
#' @param x a c14_date_list with country and country_thes
#' @param variants_column name of the column with heterogeneous values
#' @param corrected_column name of the column with the corrected values
#' @param thesaurus data.frame with correct and variants of country names
#'
#' @return NULL, called for the print side effect
#'
#' @keywords internal
#' @noRd
print_lookup_decisions <- function(x, variants_column, corrected_column, thesaurus) {
  changes <- find_lookup_decisions(x, variants_column, corrected_column, thesaurus)
  message("The following decisions were made: \n")
  for(i in 1:nrow(changes)) {
    message(
      ifelse(
        changes$thesaurus[i],
        crayon::green("thesaurus:   "),
        ifelse(
          changes$no_change[i],
          crayon::red("no change:   "),
          crayon::yellow("string match:")
        )
      ),
      " ",
      changes[[variants_column]][i], " -> ", changes[[corrected_column]][i]
    )
  }
  message("\ ")
}

#' find_lookup_decisions
#'
#' @param x a c14_date_list
#' @param variants_column name of the column with heterogeneous values
#' @param corrected_column name of the column with the corrected values
#' @param thesaurus data.frame with correct values (cor) and variants (var)
#'
#' @return a tibble with the country names and the new country_thes names
#' found by \code{find_correct_name_by_stringdist_comparison()}
#'
#' @keywords internal
#' @noRd
find_lookup_decisions <- function(x, variants_column, corrected_column, thesaurus) {
  x %>%
    dplyr::select(.data[[variants_column]], .data[[corrected_column]]) %>%
    dplyr::filter(!is.na(.data[[corrected_column]])) %>%
    unique %>%
    dplyr::arrange(.data[[variants_column]]) %>%
    # check if decision was based on thesaurus entry
    dplyr::mutate(
      thesaurus = .data[[variants_column]] %in% thesaurus$var,
      no_change = .data[[variants_column]] == .data[[corrected_column]]
    )
}

