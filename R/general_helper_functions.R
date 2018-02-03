#' check_if_packages_are_available
#'
#' @param packages_ch packages that should be available
#'
#' @return NULL - called for side effect stop()
check_if_packages_are_available <- function(packages_ch) {
  if (
    packages_ch %>%
    sapply(function(x) {requireNamespace(x, quietly = TRUE)}) %>%
    all %>% `!`
  ) {
    stop(
      paste0(
        "R packages ",
        paste(packages_ch, collapse = ", "),
        " needed for this function to work. Please install with ",
        "install.packages(c('", paste(packages_ch, collapse = "', '"), "'))"
      ),
      call. = FALSE
    )
  }
}

#' add_or_replace_column_in_df
#'
#' @param x data.frame
#' @param column_name_s name of new column
#' @param column_content_mi content of new column
#' @param ... passed to tibble::add_column()
#'
#' @return data.frame with new column
add_or_replace_column_in_df <- function(x, column_name_s, column_content_mi, ...) {
  if (column_name_s %in% colnames(x) %>% all) {
    x[[column_name_s]] <- column_content_mi
  } else {
    x <- x %>%
      tibble::add_column(
        !!(column_name_s) := column_content_mi,
        ...
      )
  }
  return(x)
}
