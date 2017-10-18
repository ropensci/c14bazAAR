#### thesaurify ####

#' @name thesaurify
#' @title Apply thesaurus
#'
#' @description Add columns country_thes & material_thes with simplified and unified terms
#'
#' @param x an object of class c14_date_list
#' @param country_thesaurus_table a thesaurus table (default: c14bazAAR::country_thesaurus)
#' @param material_thesaurus_table a thesaurus table (default: c14bazAAR::material_thesaurus)
#'
#' @return an object of class c14_date_list
#' @export
#'
#' @rdname thesaurify
#'
thesaurify <- function(
  x,
  country_thesaurus_table = c14bazAAR::country_thesaurus,
  material_thesaurus_table = c14bazAAR::material_thesaurus
) {
  UseMethod("thesaurify")
}

#' @rdname thesaurify
#' @export
thesaurify.default <- function(
  x,
  country_thesaurus_table = c14bazAAR::country_thesaurus,
  material_thesaurus_table = c14bazAAR::material_thesaurus
) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname thesaurify
#' @export
thesaurify.c14_date_list <- function(
  x,
  country_thesaurus_table = c14bazAAR::country_thesaurus,
  material_thesaurus_table = c14bazAAR::material_thesaurus
) {

  # add or empty columns country_thes and material_thes
  if (c("country_thes", "material_thes") %in% colnames(x) %>% all) {
    x$country_thes <- NA
    x$material_thes <- NA
  } else {
    x <- x %>%
      tibble::add_column(
        country_thes = NA,
        .after = "country"
      ) %>%
      tibble::add_column(
        material_thes = NA,
        .after = "material"
      )
  }

  # apply thesauri and create new columns
  x <- x %>%
    dplyr::mutate(
      country_thes = ifelse(
        .$country %in% country_thesaurus_table$var,
        country_thesaurus_table$cor[match(.$country, country_thesaurus_table$var)],
        .$country
      ),
      material_thes = ifelse(
        .$material %in% material_thesaurus_table$var,
        material_thesaurus_table$cor[match(.$material, material_thesaurus_table$var)],
        .$material
      )
    ) %>%
    as.c14_date_list()

  return(x)
}
