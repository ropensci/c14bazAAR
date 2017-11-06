#### as.sf ####

#' @name as.sf
#' @title convert a c14_date_list to a sf object
#'
#' @description convert a c14_date_list to a sf object
#'
#' @param x an object of class c14_date_list
#'
#' @return an object of class sf
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

  # check if package sf is available
  if (
    c("sf") %>%
    sapply(function(x) {requireNamespace(x, quietly = TRUE)}) %>%
    all %>% `!`
  ) {
    stop(
      "R package 'sf' needed for this function to work. Please install it.",
      call. = FALSE
    )
  }

  x_sf <- sf::st_sfc(sf::st_multipoint(as.matrix(x[,c('lon','lat')])), crs = sf::st_crs(4326)) %>%
    sf::st_cast("POINT") %>%
    sf::st_sf(data = x, geom = .)

  return(x_sf)
}

#### as.BLÖÖK ####
# TODO
