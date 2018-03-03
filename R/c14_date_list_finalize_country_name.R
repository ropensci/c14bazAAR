#### finalize_country_name ####

#' @name finalize_country_name
#' @title Chooses the country_name, that is most likely to be correct
#'
#' @description Picks the country name in a hierarchical order from the results
#' of the determine_country_by_coords and standardize_country_name functions,
#' followed by the original input of the database
#'
#' @param x an object of class c14_date_list
#'
#' @return an object of class c14_date_list
#' @export
#'
#' @rdname finalize_country_name
#'
finalize_country_name <- function(x) {
  UseMethod("finalize_country_name")
}

#' @rdname finalize_country_name
#' @export
finalize_country_name.default <- function(x) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname finalize_country_name
#' @export
finalize_country_name.c14_date_list <- function(x) {

  # check if the columns country_coord and country_thes are present
  necessary_vars <- c("country_coord", "country_thes")
  present <- necessary_vars %in% colnames(x)

  if (all(present)) {
    x %<>% dplyr::mutate(ID=seq(1,nrow(x),1))

    sf_x_problem <- x %>%
      dplyr::filter(is.na(.data$country_coord), !is.na(.data$lat), !is.na(.data$lon)) %>%
      sf::st_as_sf(coords = c("lon","lat"),
                   remove = FALSE,
                   crs = 4326) %>%
      sf::st_buffer(dist = .5) %>%
      sf::st_join(y = world) %>%
      dplyr::mutate(country_coord = as.character(.data$ADMIN.1)) %>%
      dplyr::select(names(x))

    sf_x_problem <- sf_x_problem[which(sf_x_problem$country_coord == sf_x_problem$country_thes),]

    x <- x %>%
      dplyr::filter(!is.element(.data$ID, sf_x_problem$ID)) %>%
      dplyr::bind_rows(., sf_x_problem) %>%
      dplyr::arrange(.data$ID) %>%
      dplyr::select(-.data$ID) %>%
      as.c14_date_list()
  }

  if (all(present)) {
    # add the column country_final
    x %<>% add_or_replace_column_in_df("country_final", NA, .after = "country_thes")

    # pick the most likely result hierarchically from country_coord, country_thes
    # and the original input data
    x %<>%
      dplyr::mutate(
        country_final = ifelse(test = !is.na(.data$country_coord),
                               yes = .data$country_coord,
                               no = ifelse(test = !is.na(.data$country_thes),
                                           yes = .data$country_thes,
                                           no = .data$country))) %>%
      as.c14_date_list()
    return(x)

  } else {
    stop(
      "The following variables (columns) are missing: ",
      paste(necessary_vars[!present], collapse = ", ")
    )
  }
}
