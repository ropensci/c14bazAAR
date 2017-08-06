#### thesaurify ####

#' @name thesaurify
#' @title Apply thesaurus
#'
#' @description Add columns country_cor & material_cor with simplified and unified terms
#'
#' @param x an object of class c14_date_list
#' @param country_thesaurus_table a thesaurus table (default: c14databases::country_thesaurus)
#' @param material_thesaurus_table a thesaurus table (default: c14databases::material_thesaurus)
#'
#' @return an object of class c14_date_list
#' @export
#'
#' @rdname thesaurify
#'
thesaurify <- function(
  x,
  country_thesaurus_table = c14databases::country_thesaurus,
  material_thesaurus_table = c14databases::material_thesaurus
) {
  UseMethod("thesaurify")
}

#' @rdname thesaurify
#' @export
thesaurify.default <- function(
  x,
  country_thesaurus_table = c14databases::country_thesaurus,
  material_thesaurus_table = c14databases::material_thesaurus
) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname thesaurify
#' @export
thesaurify.c14_date_list <- function(
  x,
  country_thesaurus_table = c14databases::country_thesaurus,
  material_thesaurus_table = c14databases::material_thesaurus
) {

  # add or empty columns country_cor and material_cor
  if (c("country_cor", "material_cor") %in% colnames(x) %>% all) {
    x$country_cor <- NA
    x$material_cor <- NA
  } else {
    x <- x %>%
      tibble::add_column(
        country_cor = NA,
        .after = "country"
      ) %>%
      tibble::add_column(
        material_cor = NA,
        .after = "material"
      )
  }

  # apply thesauri and create new columns
  x <- x %>%
    dplyr::mutate(
      country_cor = ifelse(
        .$country %in% country_thesaurus_table$var,
        country_thesaurus_table$cor[match(.$country, country_thesaurus_table$var)],
        .$country
      ),
      material_cor = ifelse(
        .$material %in% material_thesaurus_table$var,
        material_thesaurus_table$cor[match(.$material, material_thesaurus_table$var)],
        .$material
      )
    ) %>%
    as.c14_date_list()

  return(x)
}
