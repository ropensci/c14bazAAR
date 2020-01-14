#### determine_country_by_coordinate ####

#' @rdname country_attribution
#' @export
determine_country_by_coordinate <- function(x, suppress_spatial_warnings = TRUE) {
  UseMethod("determine_country_by_coordinate")
}

#' @rdname country_attribution
#' @export
determine_country_by_coordinate.default <- function(x, suppress_spatial_warnings = TRUE) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname country_attribution
#' @export
determine_country_by_coordinate.c14_date_list <- function(x, suppress_spatial_warnings = TRUE) {

  check_if_packages_are_available(c("sf", "rworldxtra", "rgeos", "lwgeom"))
  x %>% check_if_columns_are_present(c("lat", "lon"))

  message(paste0("Determining country by coordinates... ", {if (nrow(x) > 10000) {"This may take several minutes."}}))

  x %<>% dplyr::mutate(ID = as.integer(seq(1,nrow(x),1)))

  x_with_coords <- x %>%
    dplyr::filter(!is.na(.data$lat), .data$lon != 0, .data$lat != 0)
  if (suppress_spatial_warnings) {
    sf_x <- withCallingHandlers(
      spatial_join_with_country_dataset(x_with_coords),
      message = spatial_message_handler,
      warning = spatial_warning_handler
    )
  } else {
    sf_x <- spatial_join_with_country_dataset(x_with_coords)
  }

  sf_x <- x %>%
    dplyr::filter(is.na(.data$lat) | .data$lon == 0 | .data$lat == 0) %>%
    dplyr::bind_rows(., sf_x) %>%
    dplyr::arrange(.data$ID) %>%
    dplyr::select(-.data$ID) %>%
    as.c14_date_list()

  return(sf_x)
}

#### helpers ####

spatial_message_handler <- function(x) {
  if(any(
    grepl("dist is assumed to be in decimal degrees", x),
    grepl("although coordinates are longitude/latitude", x)
  )) {
    invokeRestart("muffleMessage")
  }
}

spatial_warning_handler <- function(x) {
  if(any(
      grepl("attribute variables are assumed to be spatially constant", x),
      grepl("st_buffer does not correctly buffer longitude/latitude data", x)
    )) {
    invokeRestart("muffleWarning")
  }
}

get_world_map <- function() {
  # load world map data from rworldxtra
  countriesHigh <- NA
  utils::data("countriesHigh", package = "rworldxtra", envir = environment())
  if(!"SpatialPolygonsDataFrame" %in% class(countriesHigh)) {
    stop("Problems loading countriesHigh dataset from package rworldxtra.")
  }
  world <- countriesHigh %>%
    sf::st_as_sf() %>% lwgeom::st_make_valid()
  return(world)
}

spatial_join_with_country_dataset <- function(x) {
  world <- get_world_map()
  # transform data to sf
  x_sf <- x %>% sf::st_as_sf(
    coords = c("lon","lat"),
    remove = FALSE,
    crs = sf::st_crs(world)
  )
  # normal join
  x_sf %<>%
    sf::st_join(y = world) %>%
    dplyr::mutate(country_coord = as.character(.data$ADMIN.1)) %>%
    dplyr::select(unique(c(names(x), "country_coord"))) %>% sf::st_as_sf(
      coords = c("lon","lat"),
      remove = FALSE,
      crs = 4326
    )
  # join with buffer for all dates without country
  # increase buffer size step by step in loop
  buffer_dist <- 0.1
  while(sum(is.na(x_sf$country_coord)) > 0 & buffer_dist <= 1){
    x_sf[is.na(x_sf$country_coord), ] %<>%
      sf::st_buffer(dist = buffer_dist) %>%
      sf::st_join(y = world, largest = TRUE) %>%
      dplyr::mutate(country_coord = as.character(.data$ADMIN.1)) %>%
      dplyr::select(unique(c(names(x), "country_coord"))) %>%
      sf::st_as_sf(
        coords = c("lon","lat"),
        remove = FALSE,
        crs = 4326
      )
    buffer_dist = buffer_dist + 0.1
  }

  x_sf %>%
    tibble::as_tibble() %>%
    dplyr::select(-.data$geometry) %>%
    return()
}
