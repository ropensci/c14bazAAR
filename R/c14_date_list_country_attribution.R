#' @name country_attribution
#' @title Functions to improve the country attribution in a \strong{c14_date_list}
#'
#' @description \code{c14bazAAR} provides two functions to check and improve the
#' spatial attribution of the individual dates in a \strong{c14_date_list} to a country. \cr \cr
#' \code{c14bazAAR::fix_database_country_name()} adds column \strong{country_thes} with
#' standardized country names. Most source databases come with a column \strong{country}
#' that contains a character name of the origin country for each date. Unfortunately the
#' different source databases don't rely on a unified naming convention and therefore use
#' various terms to represent the same country (for example: United Kingdom, Great Britain,
#' GB, etc.). This function aims to standardize the country naming scheme. To achieve this,
#' it compares the names to values in an external (\code{countrycode::codelist})
#' and an internal \link{country_thesaurus}. The latter relies on
#' manual curation to catch semantic and spelling errors in the source databases.
#' See \link{inspect_lookup_country} to trace the lookup decisions. \cr \cr
#' \code{c14bazAAR::determine_country_by_coordinate()} adds the column \strong{country_coord}
#' with standardized country attribution based on the coordinate information of the dates.
#' Due to the inconsistencies in the \strong{country} column in many c14 source databases
#' it's often necessary to rely on the coordinate position (\strong{lat} & \strong{lon})
#' for country attribution information. Unfortunately not all source databases store
#' coordinates.
#'
#' @param x an object of class c14_date_list
#' @param thesaurus data.frame with "correct" country names and "wrong" variants
#' @param codesets which country codesets should be searched for in \code{countrycode::codelist}
#' beyond \strong{country.name.en}? See \code{?countrycode::codelist} for more information
#' @param suppress_spatial_warnings suppress some spatial data messages and warnings
#' @param ... additional arguments are passed to \code{stringdist::stringdist()}.
#' \code{stringdist()} is used for fuzzy string matching of the country names in
#' \code{countrycode::codelist}
#'
#' @return an object of class c14_date_list with the additional columns \strong{country_thes},
#' \strong{country_coord} and/or \strong{country_final}
#'
#' @examples
#' library(magrittr)
#' example_c14_date_list %>%
#'   determine_country_by_coordinate()
#'
#' example_c14_date_list %>%
#'   fix_database_country_name()
#'

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

#' @keywords internal
#' @noRd
spatial_message_handler <- function(x) {
  if(any(
    grepl("dist is assumed to be in decimal degrees", x),
    grepl("although coordinates are longitude/latitude", x)
  )) {
    invokeRestart("muffleMessage")
  }
}

#' @keywords internal
#' @noRd
spatial_warning_handler <- function(x) {
  if(any(
      grepl("attribute variables are assumed to be spatially constant", x),
      grepl("st_buffer does not correctly buffer longitude/latitude data", x)
    )) {
    invokeRestart("muffleWarning")
  }
}

#' @keywords internal
#' @noRd
get_world_map <- function() {
  # load world map data from rworldxtra
  countriesHigh <- NA
  utils::data("countriesHigh", package = "rworldxtra", envir = environment())
  if(!"SpatialPolygonsDataFrame" %in% class(countriesHigh)) {
    stop("Problems loading countriesHigh dataset from package rworldxtra.")
  }
  world <- countriesHigh %>%
    sf::st_as_sf() %>% sf::st_make_valid()
  return(world)
}

#' @keywords internal
#' @noRd
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

#### fix_database_country_name ####

#' @export
#' @rdname country_attribution
fix_database_country_name <- function(
  x,
  thesaurus = c14bazAAR::country_thesaurus,
  codesets = c("country.name.de", "iso3c"),
  ...
) {
  UseMethod("fix_database_country_name")
}

#' @rdname country_attribution
#' @export
fix_database_country_name.default <- function(
  x,
  thesaurus = c14bazAAR::country_thesaurus,
  codesets = c("country.name.de", "iso3c"),
  ...
) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname country_attribution
#' @export
fix_database_country_name.c14_date_list <- function(
  x,
  thesaurus = c14bazAAR::country_thesaurus,
  codesets = c("country.name.de", "iso3c"),
  ...
) {

  x %>% check_if_columns_are_present("country")

  x %<>% add_or_replace_column_in_df("country_thes", NA, .after = "country")

  message(
    paste0("Standardizing country names... ", {
      if (nrow(x) > 10000) {"This may take several minutes."}}
    )
  )

  x %<>%
    dplyr::mutate(
      country_thes = lookup_in_countrycode_codelist(.$country, thesaurus, codesets, ...)
    )

  return(x)
}

#### helper functions ####

#' lookup_in_countrycode_codelist
#'
#' @param x vector of country codes to look up in countrycode codelist
#' @param country_thesaurus data.frame with correct and variants of country names
#' @param codesets which country codesets should be searched beyond "country.name.en"
#' @param ... additional arguments are passed to stringdist::stringdist()
#'
#' @return a vector with the correct english country names
#'
#' @keywords internal
#' @noRd
lookup_in_countrycode_codelist <- function(x, country_thesaurus, codesets, ...){

  check_if_packages_are_available(c("countrycode", "stringdist"))

  codes <- unique(c("country.name.en", codesets))
  country_df <- countrycode::codelist[, codes]

  x %>% pbapply::pbsapply(
    FUN = function(db_word) {
      # if a manual attribution is supplied then use this
      if (db_word %in% country_thesaurus$var) {
        country_thesaurus$cor[db_word == country_thesaurus$var]
        # if country name is NA or already the correct english term then use that
      } else if(db_word %in% c(NA, country_df$country.name.en)) {
        db_word
        # else determine correct english term based on stringdist
      } else {
        find_correct_name_by_stringdist_comparison(db_word, country_df, codes, ...)
      }
    }
  ) %>% unname

}

#' find_correct_name_by_stringdist_comparison
#'
#' @param db_word individual term for which to find a better name
#' @param country_df reference table
#' @param codes which country codesets are included in country_df
#' @param ... additional arguments are passed to stringdist::stringdist()
#'
#' @return a correct english country name
#'
#' @keywords internal
#' @noRd
find_correct_name_by_stringdist_comparison <- function(db_word, country_df, codes, ...) {

  db_word_dist <- function(x) { stringdist::stringdist(db_word, x, ...) }

  country_df %>%
    dplyr::mutate_all(list(stringdist = ~db_word_dist(.))) %>%
    tidyr::gather(
      key = "code_type",
      value = "dist",
      -codes
    ) %>%
    dplyr::slice(
      which.min(.data$dist)
    ) %>%
    magrittr::extract2("country.name.en") %>%
    magrittr::extract2(1)
}

