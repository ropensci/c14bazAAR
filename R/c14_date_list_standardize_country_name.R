#### standardize_country_name ####

#' @name standardize_country_name
#' @title Apply country name standardization
#'
#' @description Add column country_thes with standardized country names
#'
#' @param x an object of class c14_date_list
#' @param country_thesaurus data.frame with correct and variants of country names
#' @param codesets which country codesets should be searched beyond "country.name.en".
#' See \code{?countrycode::codelist} for more information
#' @param quiet suppress printed output
#' @param ... additional arguments are passed to \code{stringdist::stringdist()}.
#' \code{stringdist()} is used for fuzzy string matching of the country names
#'
#' @return an object of class c14_date_list
#' @export
#'
#' @rdname standardize_country_name
#'
standardize_country_name <- function(
  x,
  country_thesaurus = get_country_thesaurus(),
  codesets = c("country.name.de", "iso3c"),
  quiet = FALSE,
  ...
) {
  UseMethod("standardize_country_name")
}

#' @rdname standardize_country_name
#' @export
standardize_country_name.default <- function(
  x,
  country_thesaurus = get_country_thesaurus(),
  codesets = c("country.name.de", "iso3c"),
  quiet = FALSE,
  ...
) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname standardize_country_name
#' @export
standardize_country_name.c14_date_list <- function(
  x,
  country_thesaurus = get_country_thesaurus(),
  codesets = c("country.name.de", "iso3c"),
  quiet = FALSE,
  ...
) {

  x %>% check_if_columns_are_present("country")

  x %<>% add_or_replace_column_in_df("country_thes", NA, .after = "country")

  x %<>%
    dplyr::mutate(
      country_thes = lookup_in_countrycode_codelist(.$country, country_thesaurus, codesets, ...)
    ) %>%
    as.c14_date_list()

  if(!quiet) {
    print_lookup_decisions(x, country_thesaurus)
  }

  return(x)
}

######################################################################################
# helper functions
######################################################################################

#' lookup_in_countrycode_codelist
#'
#' @param x vector of country codes to look up in countrycode codelist
#' @param country_thesaurus data.frame with correct and variants of country names
#' @param codesets which country codesets should be searched beyond "country.name.en"
#' @param ... additional arguments are passed to stringdist::stringdist()
#'
#' @return a vector with the correct english country names
lookup_in_countrycode_codelist <- function(x, country_thesaurus, codesets, ...){

  check_if_packages_are_available(c("countrycode", "stringdist"))

  codes <- unique(c("country.name.en", codesets))
  country_df <- countrycode::codelist[, codes]

  x %>% pbapply::pbsapply(
    FUN = function(db_word) {
      # if a manual attribution is supplied then use this
      if (db_word %in% country_thesaurus$var) {
        country_thesaurus$cor[db_word == country_thesaurus$var]
      # if country name is NA or already the correct english term then store NA
      } else if(db_word %in% c(NA, country_df$country.name.en)) {
        NA
      # else determine correct english term based on stringdist
      } else {
        find_correct_name_by_stringdist_comparison(db_word, country_df, codes, ...)
      }
    }
  )

}

#' find_correct_name_by_stringdist_comparison
#'
#' @param db_word individual term for which to find a better name
#' @param country_df reference table
#' @param codes which country codesets are included in country_df
#' @param ... additional arguments are passed to stringdist::stringdist()
#'
#' @return a correct english country name
find_correct_name_by_stringdist_comparison <- function(db_word, country_df, codes, ...) {
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

#' print_lookup_decisions
#'
#' @param x a c14_date_list with country and country_thes
#' @param country_thesaurus data.frame with correct and variants of country names
#'
#' @return NULL, called for the print side effect
print_lookup_decisions <- function(x, country_thesaurus) {
  changes <- find_lookup_decisions(x, country_thesaurus)
  message("The following decisions were made: \n")
  for(i in 1:nrow(changes)) {
    message(
      ifelse(
        changes$thesaurus[i],
        crayon::green("thesaurus:   "),
        crayon::yellow("string match:")
      ),
      " ",
      changes$country[i], " -> ", changes$country_thes[i]
    )
  }
  message("\ ")
}

#' find_lookup_decisions
#'
#' @param x a c14_date_list with country and country_thes
#' @param country_thesaurus data.frame with correct and variants of country names
#'
#' @return a tibble with the country names and the new country_thes names
#' found by \code{find_correct_name_by_stringdist_comparison()}
find_lookup_decisions <- function(x, country_thesaurus) {
  x %>%
    dplyr::select(.data$country, .data$country_thes) %>%
    dplyr::filter(!is.na(.data$country_thes)) %>%
    unique %>%
    dplyr::arrange(.data$country) %>%
    # check if decision was based on thesaurus entry
    dplyr::mutate(
      thesaurus = .data$country %in% country_thesaurus$var
    )
}
