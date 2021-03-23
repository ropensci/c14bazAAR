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
  changes <- find_lookup_decisions(x, variants_column, corrected_column, thesaurus) %>%
    dplyr::filter(!.data[["thesaurus"]] & !.data[["already_fine"]])
  if (nrow(changes) > 0) {
    message("For the following values there was no relevant thesaurus entry: \n")
    for(i in 1:nrow(changes)) {
      message(
        ifelse(
          changes$no_change[i],
          crayon::magenta("no change:   "),
          crayon::yellow("string match:")
        ),
        " ",
        changes[[variants_column]][i], " -> ", changes[[corrected_column]][i]
      )
    }
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
      already_fine = .data[[variants_column]] %in% unique(thesaurus$cor),
      thesaurus = .data[[variants_column]] %in% thesaurus$var,
      no_change = .data[[variants_column]] == .data[[corrected_column]]
    )
}

