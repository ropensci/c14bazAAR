#### employ_coordinate_information ####

#' @name spatial_country_checker
#' @title Check and assign country based on spatial information
#'
#' @description Check and assign country based on spatial information by first determining country named based on spatial join, and second compare to already supplied country information
#'
#' @param x an object of class c14_date_list
#'
#' @return an object of class c14_date_list
#' @export
#'
#' @rdname spatial_country_checker
#'
spatial_country_checker <- function(x) {
  UseMethod("spatial_country_checker")
}

#' @rdname spatial_country_checker
#' @export
spatial_country_checker.default <- function(x) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname spatial_country_checker
#' @export
spatial_country_checker.c14_date_list <- function(x) {
  x %>%
    c14bazAAR::coordinate_precision() %>%
    c14bazAAR::determine_country_by_coordinate() %>%
    c14bazAAR::standardize_country_name() %>%
    c14bazAAR::finalize_country_name() %>%
    return()
}
