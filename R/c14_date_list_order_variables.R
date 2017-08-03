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
      .data[["labnr"]],
      .data[["site"]],
      .data[["c14age"]],
      .data[["c14std"]],
      dplyr::contains("calage"),
      dplyr::contains("calstd"),
      .data[["material"]],
      dplyr::contains("material_cor"),
      .data[["country"]],
      dplyr::contains("country_cor"),
      .data[["lat"]],
      .data[["lon"]],
      dplyr::everything()
    )

  return(x)
}
