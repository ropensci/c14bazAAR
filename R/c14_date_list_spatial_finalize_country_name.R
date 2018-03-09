#### finalize_country_name ####

#' @rdname country_attribution
#' @export
finalize_country_name <- function(x) {
  UseMethod("finalize_country_name")
}

#' @rdname country_attribution
#' @export
finalize_country_name.default <- function(x) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname country_attribution
#' @export
finalize_country_name.c14_date_list <- function(x) {

  x %>% check_if_columns_are_present(c("country_coord", "country_thes"))

  # add the column country_final
  x %<>% add_or_replace_column_in_df("country_final", NA, .after = "country_thes")

  # pick the most likely result hierarchically from country_coord, country_thes
  # and the original input data
  x %<>%
    dplyr::mutate(
      country_final = ifelse(
        test = !is.na(.data$country_coord),
        yes  = .data$country_coord,
        no   = ifelse(
          test = !is.na(.data$country_thes),
          yes  = .data$country_thes,
          no   = .data$country
        )
      )
    ) %>%
    as.c14_date_list()

  return(x)

}
