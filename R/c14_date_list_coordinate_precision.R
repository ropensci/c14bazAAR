#### coordinate_precision ####

#' @name coordinate_precision
#' @title Return coordinate precision according to number length
#'
#' @description Return coordinate precision according to number length
#'
#' @param x an object of class c14_date_list
#'
#' @return an object of class c14_date_list
#'
#' @rdname coordinate_precision
#'
coordinate_precision <- function(x) {
  UseMethod("coordinate_precision")
}

#' @rdname coordinate_precision
coordinate_precision.default <- function(x) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname coordinate_precision
coordinate_precision.c14_date_list <- function(x) {
  lat <- x$lat %>%
    individual_precision(mode = "lat")
  lon <- x$lon %>%
    individual_precision(mode = "lon")
  
  x <- add_or_replace_column_in_df(x,
                              column_name_s = "coord_precision",
                              column_content_mi = apply(cbind(lat,lon), 1, mean),
                              .after = "country_coord")
  return(x)
}


#' individual_precision
#'
#' @param x vector of coordinates (latitude or longitude)
#' @param mode argument indicating the `mode` of the coordinates (whether these are lat or lon)
#'
#' @return vecor with precision in meters
individual_precision <- function(x, mode) {
  output <- circumference_calculator(x, mode) / (360 * 10^digits_counter(x))
  return(output)
}

#' circumference_calculator
#'
#' @param x vector of latitude or longitude coordinates
#' @param mode a character "lat" or "lon" 
#' @return vecor with circumference values at specific latitudes
circumference_calculator <- function(x, mode) {
  if(mode == "lat") {
    circumference <- (2 * pi) * 6378137 # Following WGS84
  }
  if(mode == "lon") {
    circumference <- (2 * pi) * 6356752.3142 # Following WGS84
  }

  output <- circumference * cos((x * pi) / 180)
  return(output)
}


#' digits_counter
#'
#' counts the digits of the given coordinates
#'
#' @param x vector of coordinate values#' 
#'
#' @return vecor with numer of digits
digits_counter <- function(x) {
  output <- sapply(X = x,
                   FUN = function(x){nchar(unlist(strsplit(as.character(x),"\\."))[2])})
  output <- ifelse(test = is.na(output),
                   yes = 0,
                   no = output)
  return(output)
}







