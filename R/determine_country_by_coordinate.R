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

  # check if packages sf and rworldxtra are available
  if (
    c("sf", "rworldxtra") %>%
    sapply(function(x) {requireNamespace(x, quietly = TRUE)}) %>%
    all %>% `!`
  ) {
    stop(
      "R package 'sf' and 'rworldxtra' needed for this function to work. Please install it.",
      call. = FALSE
    )
  }

  # load world map
  data(countriesHigh)
  world <- countriesHigh %>%
    sf::st_as_sf()


  x %<>% dplyr::mutate(ID=seq(1,nrow(x),1))

  sf_x <- x %>%
    dplyr::filter(!is.na(lat),lon!=0,lat!=0) %>%
    sf::st_as_sf(coords = c("lon","lat"),
             remove = FALSE,
             crs = 4326) %>%
    sf::st_join(y = world) %>%
    dplyr::select(names(x), country_coord=ADMIN.1) %>%
    `st_geometry<-`(NULL)

  sf_x <- x %>%
    dplyr::filter(is.na(lat) | lon == 0 | lat == 0) %>%
    dplyr::bind_rows(., sf_x) %>%
    dplyr::arrange(ID) %>%
    dplyr::select(-ID) %>%
    as.c14_date_list()


  return(sf_x)
}
