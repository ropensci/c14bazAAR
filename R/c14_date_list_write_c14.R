#### write_c14 ####

#' @name write_c14
#' @title write \strong{c14_date_list}s to files
#'
#' @param x an object of class c14_date_list
#' @param format the output format: 'csv' (default) or 'xlsx'.
#' 'csv' calls \code{utils::write.csv()},
#' 'xlsx' calls \code{writexl::write_xlsx()}
#' @param ... passed to the actual writing functions
#'
#' @examples
#' csv_file <- tempfile(fileext = ".csv")
#' write_c14(
#'   example_c14_date_list,
#'   format = "csv",
#'   file = csv_file
#' )
#' \donttest{
#' xlsx_file <- tempfile(fileext = ".xlsx")
#' write_c14(
#'   example_c14_date_list,
#'   format = "xlsx",
#'   path = xlsx_file,
#' )
#' }
#'
#' @export
#'
#' @rdname write_c14
#'
write_c14 <- function(x, format = c("csv"), ...) {
  UseMethod("write_c14")
}

#' @rdname write_c14
#' @export
write_c14.default <- function(x, format = c("csv"), ...) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname write_c14
#' @export
write_c14.c14_date_list <- function(x, format = c("csv"), ...) {

  format <- match.arg(
    format,
    c("csv", "xlsx"),
    several.ok = FALSE
  )

  # remove list columns
  list_columns <- colnames(x)[(x %>% sapply(class)) == "list"]
  if (length(list_columns) > 0) {
    message(
      "The following list columns were removed: ",
      paste(list_columns, collapse = ", "),
      ". Unnest them to keep them in the output table."
    )
    x <- x %>% dplyr::select(-dplyr::all_of(list_columns))
  }

  # write
  switch(
    format,
    csv = {
      utils::write.csv(x, ...)
    },
    xlsx = {
      check_if_packages_are_available(c("writexl"))
      writexl::write_xlsx(x, ...)
    }
  )

}
