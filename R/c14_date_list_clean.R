#### clean ####

#' @name clean
#' @title Clean dataset
#'
#' @description Apply some data cleaning steps to a c14_date_list
#'
#' @param x an object of class c14_date_list
#'
#' @return an object of class c14_date_list
#' @export
#'
#' @rdname clean
#'
clean <- function(x) {
  UseMethod("clean")
}

#' @rdname clean
#' @export
clean.default <- function(x) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname clean
#' @export
clean.c14_date_list <- function(x) {

  # lat&lon not available but zero
  x[which(x[["lon"]] == 0 & x[["lat"]] == 0), c("lon", "lat")] <- NA
  message("Made missing coordinate values explicit. 0/0 -> NA/NA.")

  # lat&long not on this earth
  x[which(x[["lon"]] > 180 | x[["lon"]] < -180 | x[["lat"]] > 90 | x[["lat"]] < -90), c("lon", "lat")] <- NA
  message("Removed coordinate values which are out of bounds.")

  # add class again -- gets lost in in mutate_if :-(
  x <- x %>%
    as.c14_date_list()

  return(x)
}
