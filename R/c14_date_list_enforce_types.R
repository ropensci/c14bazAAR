#### enforce variable types ####

#' @name enforce_types
#' @title Enforce variable types
#'
#' @description Enforce variable types in a c14_date_list and remove everything that doesn't fit
#'
#' @param x an object of class c14_date_list
#'
#' @return an object of class c14_date_list
#' @export
#'
#' @rdname enforce_types
#'
enforce_types <- function(x) {
  UseMethod("enforce_types")
}

#' @rdname enforce_types
#' @export
enforce_types.default <- function(x) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname enforce_types
#' @export
enforce_types.c14_date_list <- function(x) {

  # define variable type lists
  chr_cols <- c(
    "sourcedb", "method", "labnr", "site", "sitetype", "feature", "period",
    "culture", "material", "material_the", "species", "region", "country",
    "country_coord", "country_the", "spatial_quality", "shortref",
    "comment"
  )
  int_cols <- c("c14age", "c14std", "calage", "calstd")
  dbl_cols <- c("c13val", "lat", "lon")

  # transform (invalid values become NA)
  withCallingHandlers({
    x <- x %>%
      dplyr::mutate_if(colnames(.) %in% chr_cols, as.character) %>%
      dplyr::mutate_if(colnames(.) %in% int_cols, as.integer) %>%
      dplyr::mutate_if(colnames(.) %in% dbl_cols, as.double) %>%
      `class<-`(c("c14_date_list", class(.)))
    },
    warning = function(w){
      if(grepl("NAs introduced by coercion", w$message)){
        warning("There are bad values in this database (e.g. text in a number field). They are replaced by NA:")
      }
    }
  )

  return(x)
}
