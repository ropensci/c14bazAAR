#' Checks if a variable is of class c14_date_list
#'
#' Checks if a variable is of class c14_date_list
#'
#' @param x a variable
#' @param ... further arguments passed to or from other methods.
#'
#' @return true if x is a c14_date_list, false otherwise
#'
#' @export
is.c14_date_list <- function(x, ...) {"c14_date_list" %in% class(x)}

#' Encode a c14_date_list in a Common Format
#'
#' Format an c14_date_list for pretty printing.
#'
#' @param x a c14_date_list
#' @param ... further arguments passed to or from other methods.
#'
#' @return A string representation of the c14_date_list.
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
      round(max(x[["c14age"]]), -2), " \u2015 ", round(min(x[["c14age"]]), -2)
    )
  }
  if("calage" %in% colnames(x)) {
    out_str$range_cal <- paste0(
      "\t", "calBP", "\t", "\t",
      round(max(x[["calage"]]), -2), " \u2015 ", round(min(x[["calage"]]), -2)
    )
  }
  return_value <- paste(out_str, collapse = "\n", sep = "")
  invisible(return_value)
}

#' Print a c14_date_list
#'
#' Print a c14_date_list according to the format.c14_date_list
#'
#' @param x a c14_date_list
#' @param ... further arguments passed to or from other methods.
#'
#' @export
print.c14_date_list <- function(x, ...) {
  # own format function
  cat(format(x, ...), "\n\n")
  # add table printed like a tibble
  x %>% `class<-`(c("tbl", "tbl_df", "data.frame")) %>% print
}
