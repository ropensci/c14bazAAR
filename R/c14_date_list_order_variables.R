#### order variables ####

#' @name order_variables
#' @title Order variables (static key)
#'
#' @description Order variables in a c14_date_list after a defined key
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
      dplyr::matches("^method$"),
      dplyr::matches("^labnr$"),
      .data[["c14age"]],
      .data[["c14std"]],
      dplyr::matches("^calage$"),
      dplyr::matches("^calstd$"),
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
      dplyr::matches("country$"),
      dplyr::matches("^country_coord$"),
      dplyr::matches("^country_thes$"),
      dplyr::matches("^lat$"),
      dplyr::matches("^lon$"),
      dplyr::matches("^spatial_quality$"),
      dplyr::matches("^shortref$"),
      dplyr::matches("^comment$"),
      # if there somehow are more variables:
      dplyr::everything()
    )

  return(x)
}
