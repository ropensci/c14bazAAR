#' Country Thesaurus
#'
#' A small thesaurus for country names.
#'
#' @format A tibble with 2 variables.
#' \itemize{
#'   \item \bold{cor} fixed name
#'   \item \bold{var} variations
#' }
#'
#' @family thesauri
#'
#' @name country_thesaurus
NULL

#' Material Thesaurus
#'
#' A small thesaurus for material classes.
#'
#' @format A tibble with 2 variables.
#' \itemize{
#'   \item \bold{cor} fixed name
#'   \item \bold{var} variations
#' }
#'
#' @family thesauri
#'
#' @name material_thesaurus
NULL

#' Variable Reference
#'
#' The parameter reference list of c14bazAAR: Which variables in
#' a c14_date_list equal the ones in the source databases and what
#' do they mean. Also contains a full list of the variables in the
#' source databases.
#'
#' @format A tibble.
#' \itemize{
#'   \item \bold{c14bazAAR} name of variable in c14bazAAR
#'   \item \bold{type} data type of variable in R
#'   \item \bold{definition} meaning of variable
#'   \item \bold{priority} priority of variable
#'   \item \bold{order} position of variable in a c14_date_list
#'   \item \bold{...} variables in source databases
#' }
#'
#' @family metainformation
#'
#' @name variable_reference
NULL

#' Example c14_date_list
#'
#' c14_date_list with 200 random dates for tests and example code.
#'
#' @format A c14_date_list. See variable_reference for an explanation of
#' the variable meaning.
#'
#' @family c14_date_lists
#'
#' @name example_c14_date_list
NULL
