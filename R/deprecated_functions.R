#' @name deprecated_functions
#' @title Deprecated functions
#'
#' @description Run them anyway to get some information about their replacements
#' or why they were removed.
#'
#' @param ... ...
#'

#' @rdname deprecated_functions
#' @export
mark_duplicates <- function(...) {
  stop(
    "This function is deprecated. remove_duplicates() includes this functionality now. ",
    "Please use remove_duplicates() with mark_only = TRUE if you only want to ",
    "retrieve the duplicate_group column. ",
    "Check '?duplicates' for more information."
  )
}

#' @rdname deprecated_functions
#' @export
coordinate_precision <- function(...) {
  stop(
    "This function was removed from c14bazAAR without a replacement. ",
    "The functionality was not essential and the calculated precision values ",
    "probably frequently misleading."
  )
}

#' @rdname deprecated_functions
#' @export
finalize_country_name <- function(...) {
  stop(
    "This function was removed from c14bazAAR without a replacement. ",
    "It was a confusing wrapper that can be very easily reimplemented."
  )
}

#' @rdname deprecated_functions
#' @export
standardize_country_name <- function(...) {
  stop(
    "This function was renamed to fix_database_country_name()"
  )
}

#' @rdname deprecated_functions
#' @export
get_emedyd <- function(...) {
  stop(
    "The emedyd database was removed from c14bazAAR, because it was ",
    "superseded by the nerd database."
  )
}

#' @rdname deprecated_functions
#' @export
fix_database_country_name <- function(...) {
  stop(
    "This function was removed from c14bazAAR v.3.0 without a replacement. ",
    "It was a secondary feature difficult to maintain."
  )
}

#' @rdname deprecated_functions
#' @export
classify_material <- function(...) {
  stop(
    "This function was removed from c14bazAAR v.3.0 without a replacement. ",
    "Maintaining the material table and keeping it up-to-date was too tedious. ",
    "The extensive lookup-table is still available and we welcome derived ",
    "applications built on it: ",
    "https://github.com/ropensci/c14bazAAR/blob/master/data-raw/material_thesaurus.csv"
  )
}

#' @rdname deprecated_functions
#' @export
get_context <- function(...) {
  stop(
    "The CONTEXT database was removed from c14bazAAR v4.0.0, because its ",
    "website can not be reached any more (as of July 2023)."
  )
}
