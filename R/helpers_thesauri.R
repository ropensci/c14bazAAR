#' Get an overview of the lookup decisions
#'
#' These functions allow to inspect the lookups done in \link{fix_database_country_name}
#' and \link{classify_material}. This can be useful to understand which values are not
#' covered in the in the thesaurus tables.
#'
#' @param x a c14_date_list with the columns country and country_thes or material
#' and material_thes which went through either or both \link{fix_database_country_name}
#' or \link{classify_material}
#' @param thesaurus see \link{fix_database_country_name} or \link{classify_material}
#'
#' @return a data.frame with information about lookup decisions. Columns:
#' \itemize{
#'  \item{already_in_thesaurus: entry is already identical to the "correct" one in the thesaurus table}
#'  \item{changed: entry was changed with \link{fix_database_country_name} or \link{classify_material}}
#'  \item{changed_thesaurus: entry was changed with a lookup in the thesaurus}
#'  \item{changed_not_thesaurus: entry was changed by lookup in another reference}
#'  \item{not_changed_not_thesaurus: entry was not changed is not in the thesaurus}
#' }
#' For material classification this last column indicates
#' values that should be added to the thesaurus, because
#' they are missing there. For countries it often means
#' that the entries were found in \link[countrycode]{codelist}.
#'
#' @rdname inspect_lookup
#' @export
inspect_lookup_country <- function(x, thesaurus = c14bazAAR::country_thesaurus) {
  find_lookup_decisions(x, "country", "country_thes", thesaurus)
}

#' @rdname inspect_lookup
#' @export
inspect_lookup_material <- function(x, thesaurus = c14bazAAR::material_thesaurus) {
  find_lookup_decisions(x, "material", "material_thes", thesaurus)
}

#' @keywords internal
#' @noRd
find_lookup_decisions <- function(x, variants_column, corrected_column, thesaurus) {
  res <- x %>%
    tibble::tibble() %>%
    dplyr::select(.data[[variants_column]], .data[[corrected_column]]) %>%
    dplyr::filter(!is.na(.data[[corrected_column]])) %>%
    unique %>%
    dplyr::arrange(.data[[variants_column]]) %>%
    dplyr::mutate(
      already_in_thesaurus = .data[[variants_column]] %in% thesaurus$cor,
      changed = .data[[variants_column]] != .data[[corrected_column]],
      changed_thesaurus = .data[[variants_column]] %in% thesaurus$var,
      changed_not_thesaurus = .data[["changed"]] & !.data[["changed_thesaurus"]],
      not_changed_not_thesaurus = !.data[["changed"]] & !.data[["changed_thesaurus"]]
    )
  message(
    "Number of values that were already as in the thesaurus:  ",
    sum(res$already_in_thesaurus, na.rm = T)
  )
  message(
    "Number of values corrected by lookup in the thesaurus:   ",
    sum(res$changed_thesaurus, na.rm = T)
  )
  message(
    "Number of values corrected by lookup in other reference: ",
    sum(res$changed_not_thesaurus, na.rm = T)
  )
  message(
    "Number of values not corrected and not in the thesaurus: ",
    sum(res$not_changed_not_thesaurus, na.rm = T)
  )
  message(paste(
    "For material classification this last number usually indicates",
    "values that should be added to the thesaurus.",
    "For countries it often means that the entries were found in",
    "countrycode::codelist."
  ))
  return(res)
}

