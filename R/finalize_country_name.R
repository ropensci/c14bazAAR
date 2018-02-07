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
  x %>% check_if_columns_are_present(necessary_vars)
  
  # add the column country_final
  x %<>% add_or_replace_column_in_df("country_final", NA, .after = "country_thes")
  
  # pick the most likely result hierarchically from country_coord, country_thes
  # and the original input data
  x %<>%
    dplyr::mutate(
      if (country_coord != NA) {
        country_final = country_coord
      } else if (country_thes ! NA) {
        country_final = country_thes
      } else {
        country_final = country
      }    ) %>%
    as.c14_date_list()
  
  return(x)
}