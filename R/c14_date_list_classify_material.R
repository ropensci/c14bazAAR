#### classify_material ####

#' @name classify_material
#' @title Apply material classification on a \strong{c14_date_list}
#'
#' @description Add column \strong{material_thes} with simplified and unified terms for
#' material categories. The classification is manually curated and therefore maybe not
#' up-to-date. It's stored in a
#' \href{https://github.com/ropensci/c14bazAAR/blob/master/data-raw/material_thesaurus.csv}{material_thesaurus}
#' list, and downloaded directly from github with \code{c14bazAAR::get_material_thesaurus()}.
#' With this setup you can also easily apply own thesaurus tables.
#'
#' @param x an object of class c14_date_list
#' @param material_thesaurus a thesaurus table
#' @param quiet suppress decision log output
#'
#' @return an object of class c14_date_list with the additional column \strong{material_thes}
#'
#' @examples
#' classify_material(
#'   example_c14_date_list,
#'   quiet = TRUE
#' )
#'
#' @export
#'
#' @rdname classify_material
#'
classify_material <- function(
  x,
  material_thesaurus = c14bazAAR::get_material_thesaurus(),
  quiet = FALSE
) {
  UseMethod("classify_material")
}

#' @rdname classify_material
#' @export
classify_material.default <- function(
  x,
  material_thesaurus = c14bazAAR::get_material_thesaurus(),
  quiet = FALSE
) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname classify_material
#' @export
classify_material.c14_date_list <- function(
  x,
  material_thesaurus = c14bazAAR::get_material_thesaurus(),
  quiet = FALSE
) {

  x %>% check_if_columns_are_present("material")

  x %<>% add_or_replace_column_in_df("material_thes", NA_character_, .after = "material")

  message(paste0("Classifying material... ", {if (nrow(x) > 10000) {"This may take several minutes."}}))

  x %<>%
    dplyr::mutate(
      material_thes = lookup_in_thesaurus_table(.$material, material_thesaurus)
    )

  if(!quiet) {
    print_lookup_decisions(x, "material", "material_thes", material_thesaurus)
  }

  return(x)
}

#' lookup_in_thesaurus_table
#'
#' @param x vector of values to look up in thesaurus
#' @param thesaurus_df reference table that contains variants and correct values
#'
#' @return a vector with the correct values
#'
#' @keywords internal
#' @noRd
lookup_in_thesaurus_table <- function(x, thesaurus_df){
  x_cleaned <- x
  x_cleaned <- gsub("\"", "", x_cleaned)
  x_cleaned <- gsub("[\r\n]", "", x_cleaned)
  x_cleaned <- iconv(x_cleaned, "UTF-8", "UTF-8", sub = '')
  thesaurus_df$var_cleaned <- thesaurus_df$var
  thesaurus_df$var_cleaned <- gsub("\"", "", thesaurus_df$var_cleaned)
  thesaurus_df$var_cleaned <- gsub("[\r\n]", "", thesaurus_df$var_cleaned)
  ifelse(
    x_cleaned %in% thesaurus_df$var_cleaned,
    thesaurus_df$cor[match(x, thesaurus_df$var_cleaned)],
    x
  ) %>%
    return()
}
