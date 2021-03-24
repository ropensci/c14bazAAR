#' Database lookup table
#'
#' Lookup table for general source database information.
#'
#' @format a data.frame. Columns:
#' \itemize{
#'  \item{db: database name}
#'  \item{version: database version}
#'  \item{url_num: url number (some databases are spread over multiple files)}
#'  \item{url: file url where the database can be downloaded}
#' }
#'
#' @family lookup_tables
#' @name db_info_table
NULL

#' Country thesaurus
#'
#' Lookup table for country names.
#'
#' @format a data.frame. Columns:
#' \itemize{
#'  \item{cor: fixed name}
#'  \item{var: variations}
#' }
#'
#' @family lookup_tables
#' @name country_thesaurus
NULL

#' Material thesaurus
#'
#' Lookup table for material categories.
#'
#' @format a data.frame. Columns:
#' \itemize{
#'  \item{cor: fixed name}
#'  \item{var: variations}
#' }
#'
#' @family lookup_tables
#' @name material_thesaurus
NULL

#' Example c14_date_list
#'
#' c14_date_list for tests and example code.
#'
#' @format a c14_date_list.
#' See data_raw/variable_definition.csv for an explanation of
#' the variable meaning.
#'
#' @family c14_date_lists
#' @name example_c14_date_list
NULL
