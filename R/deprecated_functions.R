#' @name deprecated_functions
#' @title Deprecated functions
#'
#' Run them anyway to get some information about their replacements.
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
