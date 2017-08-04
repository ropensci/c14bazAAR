#### thesaurify ####

#' @name thesaurify
#' @title Apply thesaurus
#'
#' @description Add columns country_cor & material_cor with simplified and unified terms
#'
#' @param x an object of class c14_date_list
#'
#' @return an object of class c14_date_list
#' @export
#'
#' @rdname thesaurify
#'
thesaurify <- function(x) {
  UseMethod("thesaurify")
}

#' @rdname thesaurify
#' @export
thesaurify.default <- function(x) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname thesaurify
#' @export
thesaurify.c14_date_list <- function(x) {

  # whitespaces
  x <- x %>%
    dplyr::mutate_if(
      is.character,
      stringr::str_trim
    )
  message("Removed leading and trailing whitespaces in all character columns.")

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
        .$country %in% c14databases::country_thesaurus$var,
        c14databases::country_thesaurus$cor[match(.$country, c14databases::country_thesaurus$var)],
        .$country
      ),
      material_cor = ifelse(
        .$material %in% c14databases::material_thesaurus$var,
        c14databases::material_thesaurus$cor[match(.$material, c14databases::material_thesaurus$var)],
        .$material
      )
    ) %>%
    as.c14_date_list()

  return(x)
}
