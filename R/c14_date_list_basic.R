#### is ####

#' Check if an object is of class c14_date_list
#'
#' Check if an object is of class c14_date_list
#'
#' @param x an object
#' @param ... further arguments passed to or from other methods
#'
#' @return true if x is a c14_date_list, false otherwise
#'
#' @export
is.c14_date_list <- function(x, ...) {"c14_date_list" %in% class(x)}

##### as ####

#' Convert an object of class data.frame or tibble to class c14_date_list
#'
#' If an object is of class data.frame or tibble (tbl & tbl_df), it can be
#' converted to an object of class c14_date_list
#'
#' @param x a variable
#' @param ... further arguments passed to or from other methods
#'
#' @return an object of class c14_date_list
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
        `class<-`(c("c14_date_list", class(.))) %>%
        c14bazAAR::order_variables() %>%
        c14bazAAR::enforce_types() %>%
        c14bazAAR::clean() %>%
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


#### format ####

#' Encode a c14_date_list in a Common Format
#'
#' Format an c14_date_list for pretty printing
#'
#' @param x a c14_date_list
#' @param ... further arguments passed to or from other methods
#'
#' @return A string representation of the c14_date_list
#'
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

#' Print a c14_date_list
#'
#' Print a c14_date_list according to the format.c14_date_list
#'
#' @param x a c14_date_list
#' @param ... further arguments passed to or from other methods
#'
#' @export
print.c14_date_list <- function(x, ...) {
  # own format function
  cat(format(x, ...), "\n\n")
  # add table printed like a tibble
  x %>% `class<-`(c("tbl", "tbl_df", "data.frame")) %>% print
}
