#### standardize_country_name ####

#' @name standardize_country_name
#' @title Apply country name standardization
#'
#' @description Add column country_thes with standardized country names
#'
#' @param x an object of class c14_date_list
#' @param codesets which country codesets should be searched beyond "country.name.en".
#' See \code{?countrycode::codelist} for more information.
#' @param ... additional arguments are passed to \code{stringdist::stringdist()}.
#' \code{stringdist()} is used for fuzzy string matching of the country names.
#'
#' @return an object of class c14_date_list
#' @export
#'
#' @rdname standardize_country_name
#'
standardize_country_name <- function(
  x,
  codesets = c("country.name.de", "iso3c"),
  ...
) {
  UseMethod("standardize_country_name")
}

#' @rdname standardize_country_name
#' @export
standardize_country_name.default <- function(
  x,
  codesets = c("country.name.de", "iso3c"),
  ...
) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname standardize_country_name
#' @export
standardize_country_name.c14_date_list <- function(
  x,
  codesets = c("country.name.de", "iso3c"),
  ...
) {

  x %<>% add_or_replace_column_in_df("country_thes", NA, .after = "country")

  x %<>%
    dplyr::mutate(
      country_thes = lookup_in_countrycode_codelist(.$country, codesets, ...)
    ) %>%
    as.c14_date_list()

  return(x)
}

######################################################################################
# helper functions
######################################################################################

#' lookup_in_countrycode_codelist
#'
#' @param x vector of country codes to look up in countrycode codelist
#' @param codesets which country codesets should be searched beyond "country.name.en"
#' @param ... additional arguments are passed to stringdist::stringdist()
#'
#' @return a vector with the correct english country names
lookup_in_countrycode_codelist <- function(x, codesets, ...){

  check_if_packages_are_available(c("countrycode", "stringdist"))

  codes <- unique(c("country.name.en", codesets))
  country_df <- countrycode::codelist[, codes]

  x %>% pbapply::pbsapply(
    FUN = function(db_word) {
      # if word is already the correct english term, then store NA
      if(db_word %in% country_df$country.name.en) {
        NA
      # else determine correct english term based on stringdist
      } else {
        find_correct_name_by_stringdist_comparison(db_word, country_df, ...)
      }
    }
  )

}

#' find_correct_name_by_stringdist_comparison
#'
#' @param db_word individual term for which to find a better name
#' @param country_df reference table
#' @param ... additional arguments are passed to stringdist::stringdist()
#'
#' @return a vector with the correct english country names
find_correct_name_by_stringdist_comparison <- function(db_word, country_df, ...) {
  country_df %>%
    dplyr::mutate_all(
      dplyr::funs(
        stringdist = stringdist::stringdist(db_word, ., ...)
      )
    ) %>%
    tidyr::gather(
      key = "code_type",
      value = "dist",
      -codes
    ) %>%
    dplyr::slice(
      which.min(.data$dist)
    ) %>%
    magrittr::extract2("country.name.en") %>%
    magrittr::extract(1)
}
