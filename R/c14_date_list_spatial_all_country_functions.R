#### employ_coordinate_information ####

#' @name country_attribution
#' @title Functions to improve the country attribution in a \strong{c14_date_list}
#'
#' @description \code{c14bazAAR} provides several functions to check and improve the
#' spatial attribution of the individual dates in a \strong{c14_date_list} to a country. \cr \cr
#' \code{c14bazAAR::standardize_country_name()} adds column \strong{country_thes} with
#' standardized country names. Most source databases come with a column \strong{country}
#' that contains a character name of the origin country for each date. Unfortunately the
#' different source databases don't rely on a unified naming convention and therefore use
#' various terms to represent the same country (for example: United Kingdom, Great Britain,
#' GB, etc.). This function aims to standardize the country naming scheme. To achieve this,
#' it compares the names to values in an external (\code{countrycode::codelist})
#' and an internal (\code{c14bazAAR::country_thesaurus}) reference list. The latter needs
#' manual curation to catch semantic and spelling errors in the source databases. \cr \cr
#' \code{c14bazAAR::determine_country_by_coordinate()} adds the column \strong{country_coord}
#' with standardized country attribution based on the coordinate information of the dates.
#' Due to the inconsistencies in the \strong{country} column in many c14 source databases
#' it's often necessary to rely on the coordinate position (\strong{lat} & \strong{lon})
#' for reliable country attribution information. \cr \cr
#' \code{finalize_country_name()} picks the country name in a hierarchical order from the results
#' of \code{c14bazAAR::determine_country_by_coordinate()} and
#' \code{c14bazAAR::standardize_country_name()} functions, followed by the original input
#' of the database. The result is added to the input date list with the column
#' \strong{country_final}. \cr \cr
#' \code{c14bazAAR::all_country_functions()} finally is a wrapper to call all three functions
#' \code{c14bazAAR::determine_country_by_coordinate()},
#' \code{c14bazAAR::standardize_country_name()} and
#' \code{finalize_country_name()}
#' at once.
#'
#' @param x an object of class c14_date_list
#' @param country_thesaurus data.frame with correct and variants of country names
#' @param codesets which country codesets should be searched for in \code{countrycode::codelist}
#' beyond \strong{country.name.en}? See \code{?countrycode::codelist} for more information
#' @param quiet suppress printed output
#' @param ... additional arguments are passed to \code{stringdist::stringdist()}.
#' \code{stringdist()} is used for fuzzy string matching of the country names in
#' \code{countrycode::codelist}
#'
#' @return an object of class c14_date_list with the additional columns \strong{country_thes},
#' \strong{country_coord} and/or \strong{country_final}
#'
#' @rdname country_attribution
#' @export
all_country_functions <- function(x) {
  UseMethod("all_country_functions")
}

#' @rdname country_attribution
#' @export
all_country_functions.default <- function(x) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname country_attribution
#' @export
all_country_functions.c14_date_list <- function(x) {
  x %>%
    c14bazAAR::coordinate_precision() %>%
    c14bazAAR::determine_country_by_coordinate() %>%
    c14bazAAR::standardize_country_name() %>%
    c14bazAAR::finalize_country_name() %>%
    return()
}
