#### as.sf ####

#' @name as.sf
#' @title Convert a \strong{c14_date_list} to a sf object
#'
#' @description Most 14C dates have point position information in
#' the coordinates columns \strong{lat} and \strong{lon}. This allows
#' them to be converted to a spatial simple feature collection as provided
#' by the \code{sf} package. This simplifies for example mapping of the
#' dates.
#'
#' @param x an object of class c14_date_list
#'
#' @return an object of class sf
#'
#' @examples
#' sf_c14 <- as.sf(example_c14_date_list)
#'
#' \dontrun{
#' library(mapview)
#' mapview(sf_c14$geom)
#' }
#'
#' @export
#'
#' @rdname as.sf
#'
as.sf <- function(x) {
  UseMethod("as.sf")
}

#' @rdname as.sf
#' @export
as.sf.default <- function(x) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname as.sf
#' @export
as.sf.c14_date_list <- function(x) {

  check_if_packages_are_available("sf")

  x %>% check_if_columns_are_present(c("lat", "lon"))

  x_sf <- sf::st_sfc(sf::st_multipoint(as.matrix(x[,c('lon','lat')])), crs = sf::st_crs(4326)) %>%
    sf::st_cast("POINT") %>%
    sf::st_sf(data = x, geom = .)

  return(x_sf)
}
