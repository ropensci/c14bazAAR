#### order variables ####

#' @name order_variables
#' @title Order the variables in a \strong{c14_date_list}
#'
#' @description Arrange variables according to a defined order. This makes
#' sure that a \strong{c14_date_list} always appears with the same
#' outline. \cr
#' A \strong{c14_date_list} has at least the columns \strong{c14age}
#' and \strong{c14std}. Beyond that there's a selection of additional
#' variables depending on the input from the source databases, as a
#' result of the \code{c14bazAAR} functions or added by other data
#' analysis steps. This function arranges the expected variables in
#' a distinct, predefined order. Undefined variables are added at the
#' end.
#'
#' @param x an object of class c14_date_list
#'
#' @return an object of class c14_date_list
#' @export
#'
#' @rdname order_variables
#'
order_variables <- function(x) {
  UseMethod("order_variables")
}

#' @rdname order_variables
#' @export
order_variables.default <- function(x) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname order_variables
#' @export
order_variables.c14_date_list <- function(x) {

  # apply ordering key
  x <- x %>%
    dplyr::select(
      dplyr::matches("^sourcedb$"),
      dplyr::matches("^sourcedb_version$"),
      dplyr::matches("^method$"),
      dplyr::matches("^labnr$"),
      dplyr::matches("^c14age$"),
      dplyr::matches("^c14std$"),
      dplyr::matches("^calprobdistr$"),
      dplyr::matches("^calrange$"),
      dplyr::matches("^sigma$"),
      dplyr::matches("^c13val$"),
      dplyr::matches("^site$"),
      dplyr::matches("^sitetype$"),
      dplyr::matches("^feature$"),
      dplyr::matches("^period$"),
      dplyr::matches("^culture$"),
      dplyr::matches("^material$"),
      dplyr::matches("^material_thes$"),
      dplyr::matches("^species$"),
      dplyr::matches("^region$"),
      dplyr::matches("^country$"),
      dplyr::matches("^country_coord$"),
      dplyr::matches("^country_thes$"),
      dplyr::matches("^country_final$"),
      dplyr::matches("^lat$"),
      dplyr::matches("^lon$"),
      dplyr::matches("^coord_precision$"),
      dplyr::matches("^shortref$"),
      dplyr::matches("^comment$"),
      dplyr::matches("^duplicate_group$"),
      dplyr::matches("^duplicate_remove_log$"),
      # if there somehow are more variables:
      dplyr::everything()
    )

  return(x)
}
