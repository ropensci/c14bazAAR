##### as ####

#' @name c14_date_list
#'
#' @title \strong{c14_date_list}
#'
#' @description The \strong{c14_date_list} is the central data structure of the
#' \code{c14bazAAR} package. It's a tibble with set of custom methods and
#' variables. Please see \code{c14bazAAR::variable_reference} for a description
#' of the variables. Further available variables are ignored. \cr
#' If an object is of class data.frame or tibble (tbl & tbl_df), it can be
#' converted to an object of class \strong{c14_date_list}. The only requirement
#' is that it contains the essential columns \strong{c14age} and \strong{c14std}.
#' The \code{as} function adds the string "c14_date_list" to the classes vector
#' of the object and applies \code{order_variables()}, \code{enforce_types()} and
#' the helper function \code{clean_latlon()} to it.
#'
#' @param x an object
#' @param ... further arguments passed to or from other methods
#'
#' @rdname c14_date_list
#'
#' @examples
#' # c14_date_list can be crafted manually:
#' as.c14_date_list(data.frame(c14age = c(2000, 2500), c14std = c(30, 35)))
#'
#' # The c14_date_list class is stripped if
#' # you apply functions to a c14_date_list
#' # that return tibbles or data.frames.
#' # You have to add the class again afterwards:
#' library(magrittr)
#' example_c14_date_list %>%
#'   dplyr::filter(sourcedb == "CALPAL") %>%
#'   as.c14_date_list()
#'
#' is.c14_date_list(5) # FALSE
#' is.c14_date_list(example_c14_date_list) # TRUE
#'
#' print(example_c14_date_list)
#'
#' @export
as.c14_date_list <- function(x, ...) {

  # define expectations
  necessary_vars <- c("c14age","c14std")

  # check input data type
  if("data.frame" %in% class(x) | all(c("tbl", "tbl_df") %in% class(x))){
    # check if necessary vals are present
    present <- necessary_vars %in% colnames(x)
    if (all(present)) {
      # do the actual conversion!
      x %>%
        tibble::new_tibble(., nrow = nrow(.), class = "c14_date_list") %>%
        c14bazAAR::order_variables() %>%
        c14bazAAR::enforce_types() %>%
        clean_latlon() %>%
        clean_labnr() %>%
        return()
    } else {
      stop(
        "The following variables (columns) are missing: ",
        paste(necessary_vars[!present], collapse = ", ")
      )
    }
  } else {
    stop("x is not an object of class data.frame or tibble")
  }

}

#### is ####

#' @rdname c14_date_list
#' @export
is.c14_date_list <- function(x, ...) {"c14_date_list" %in% class(x)}

#### format ####

#' @rdname c14_date_list
#' @export
format.c14_date_list <- function(x, ...) {
  out_str <- list()
  out_str$header <- paste0("\tRadiocarbon date list")
  out_str$dates <- paste0("\t", "dates", "\t", "\t", nrow(x))
  if("site" %in% colnames(x)) {
    out_str$sites <- paste0("\t", "sites", "\t", "\t", length(unique(x[["site"]])))
  }
  if("country" %in% colnames(x)) {
    out_str$country <- paste0("\t", "countries", "\t", length(unique(x[["country"]])))
  }
  if("c14age" %in% colnames(x)) {
    out_str$range_uncal <- paste0(
      "\t", "uncalBP", "\t", "\t",
      round(max(x[["c14age"]], na.rm = TRUE), -2), " \u2015 ", round(min(x[["c14age"]], na.rm = TRUE), -2)
    )
  }
  if("calage" %in% colnames(x)) {
    out_str$range_cal <- paste0(
      "\t", "calBP", "\t", "\t",
      round(max(x[["calage"]], na.rm = TRUE), -2), " \u2015 ", round(min(x[["calage"]], na.rm = TRUE), -2)
    )
  }
  return_value <- paste(out_str, collapse = "\n", sep = "")
  invisible(return_value)
}

#### print ####

#' @rdname c14_date_list
#' @export
print.c14_date_list <- function(x, ...) {
  # own format function
  cat(format(x, ...), "\n\n")
  # add table printed like a tibble
  x %>% `class<-`(c("tbl", "tbl_df", "data.frame")) %>% print
}

#### accessor functions ####

