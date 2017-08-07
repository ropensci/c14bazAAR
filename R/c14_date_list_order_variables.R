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
      .data[["sourcedb"]],
      .data[["labnr"]],
      .data[["site"]],
      .data[["c14age"]],
      .data[["c14std"]],
      dplyr::matches("^calage$"),
      dplyr::matches("^calstd$"),
      .data[["material"]],
      dplyr::matches("^material_thes$"),
      dplyr::matches("^species$"),
      .data[["country"]],
      dplyr::matches("^country_coord$"),
      dplyr::matches("^country_thes$"),
      .data[["lat"]],
      .data[["lon"]],
      dplyr::matches("spatial_quality"),
      dplyr::everything()
    )

  return(x)
}
