#### determine_country_by_coordinate ####

#' @name determine_country_by_coordinate
#' @title Determines country by coordinate
#'
#' @description Determines country by coordinate
#'
#' @param x an object of class c14_date_list
#'
#' @return an object of class c14_date_list
#' @export
#'
#' @rdname determine_country_by_coordinate
#'
determine_country_by_coordinate <- function(x) {
  UseMethod("determine_country_by_coordinate")
}

#' @rdname determine_country_by_coordinate
#' @export
determine_country_by_coordinate.default <- function(x) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname determine_country_by_coordinate
#' @export
determine_country_by_coordinate.c14_date_list <- function(x) {

  check_if_packages_are_available(c("sf", "rworldxtra"))

  # load world map data from rworldxtra
  countriesHigh <- NA
  utils::data("countriesHigh", package = "rworldxtra", envir = environment())
  if(!"SpatialPolygonsDataFrame" %in% class(countriesHigh)) {
    stop("Problems loading countriesHigh dataset from package rworldxtra.")
  }
  world <- countriesHigh %>%
    sf::st_as_sf()


  x %<>% dplyr::mutate(ID = seq(1,nrow(x),1))

  sf_x <- x %>%
    dplyr::filter(!is.na(.data$lat),.data$lon!=0,.data$lat!=0) %>%
    sf::st_as_sf(coords = c("lon","lat"),
             remove = FALSE,
             crs = 4326) %>%
    sf::st_join(y = world) %>%
    dplyr::select(names(x), country_coord = .data$ADMIN.1)

  sf::st_geometry(sf_x) <- NULL

  sf_x <- x %>%
    dplyr::filter(is.na(.data$lat) | .data$lon == 0 | .data$lat == 0) %>%
    dplyr::bind_rows(., sf_x) %>%
    dplyr::arrange(.data$ID) %>%
    dplyr::select(-.data$ID) %>%
    as.c14_date_list() %>%
    coordinate_precision() %>%
    as.c14_date_list()

  return(sf_x)
}
