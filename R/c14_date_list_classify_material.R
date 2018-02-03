#### classify_material ####

#' @name classify_material
#' @title Apply material classification
#'
#' @description Add column material_thes with simplified and unified terms
#'
#' @param x an object of class c14_date_list
#' @param material_thesaurus_df a thesaurus table (default: c14bazAAR::material_thesaurus)
#'
#' @return an object of class c14_date_list
#' @export
#'
#' @rdname classify_material
#'
classify_material <- function(
  x,
  material_thesaurus_df = c14bazAAR::material_thesaurus
) {
  UseMethod("classify_material")
}

#' @rdname classify_material
#' @export
classify_material.default <- function(
  x,
  material_thesaurus_df = c14bazAAR::material_thesaurus
) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname classify_material
#' @export
classify_material.c14_date_list <- function(
  x,
  material_thesaurus_df = c14bazAAR::material_thesaurus
) {

  x %<>% add_or_replace_column_in_df("material_thes", NA, .after = "material")

  x %<>%
    dplyr::mutate(
      material_thes = lookup_in_thesaurus_table(.$material, material_thesaurus_df)
    ) %>%
    as.c14_date_list()

  return(x)
}

#' lookup_in_thesaurus_table
#'
#' @param x vector of values to look up in thesaurus
#' @param thesaurus_df reference table that contains variants and correct values
#'
#' @return a vector with the correct values
lookup_in_thesaurus_table <- function(x, thesaurus_df){
  ifelse(
    x %in% thesaurus_df$var,
    thesaurus_df$cor[match(x, thesaurus_df$var)],
    x
  ) %>%
    return()
}
