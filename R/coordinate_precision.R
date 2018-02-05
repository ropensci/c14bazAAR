#### coordinate_precision ####

#' @name coordinate_precision
#' @title Return coordinate precision according to number length
#'
#' @description Return coordinate precision according to number length
#'
#' @param x an object of class c14_date_list
#'
#' @return an object of class c14_date_list
#' @export
#'
#' @rdname coordinate_precision
#'
coordinate_precision <- function(x) {
  UseMethod("coordinate_precision")
}

#' @rdname coordinate_precision
#' @export
coordinate_precision.default <- function(x) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname coordinate_precision
#' @export
coordinate_precision.c14_date_list <- function(x) {

}


#' circumference_calculator
#'
#' @param x vector of latitude
#' @param mode lat or lon
#' @return vecor with circumference values at specific latitudes
circumference_calculator <- function(x, mode, ...) {
  if(mode == "lat") {
    circumference <- (2 * pi) * 6378137 # Following WGS84
  }
  if(mode == "lon") {
    circumferencen <- (2* pi) * 6356752.3142
  }

  output <- circumference * cos((x * pi) / 180)
  return(output)
}


#' digits_counter
#'
#' @param x vector
#'
#' @return vecor with numer of digits
digits_counter <- function(x, ...) {
  output <- sapply(X = x,
                   FUN = function(x){nchar(unlist(strsplit(as.character(x),"\\."))[2])})
  output <- ifelse(test = is.na(output),
                   yes = 0,
                   no = output)
  return(output)
}

#' latitude_precision
#'
#' @param x vector of latitude
#'
#' @return vecor with precision in meters
latitude_precision <- function(x, ...) {
  output <- circumference_calculator(x) / (360 * 10^digits_counter(x))
  return(output)
}







