#' check_if_packages_are_available
#'
#' @param packages_ch packages that should be available
#'
#' @return NULL - called for side effect stop()
#'
#' @keywords internal
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
#'
#' @keywords internal
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

#' check_if_columns_are_present
#'
#' @param x c14_date_list
#' @param columns name of columns column
#'
#' @return NULL - called for side effect stop()
#'
#' @keywords internal
check_if_columns_are_present <- function(x, columns) {
  if(columns %in% colnames(x) %>% all %>% `!`) {
    stop(
      paste0(
        "Columns ",
        paste(columns, collapse = ", "),
        " needed in your c14_date_list for this function to work."
      ),
      call. = FALSE
    )
  }
}

#' clean dataset
#'
#' @description Apply some data cleaning steps to a c14_date_list
#'
#' @param x an object of class c14_date_list
#'
#' @return an object of class c14_date_list
#'
#' @keywords internal
clean_latlon <- function(x) {

  if(all(c("lat", "lon") %in% colnames(x))) {

    # lat&lon not available but zero
    x[which(x[["lon"]] == 0 & x[["lat"]] == 0), c("lon", "lat")] <- NA

    # lat&long not on this earth
    x[which(x[["lon"]] > 180 | x[["lon"]] < -180 | x[["lat"]] > 90 | x[["lat"]] < -90), c("lon", "lat")] <- NA

  }

  return(x)
}

#' check_connection_to_url
#'
#' @param db_url url string
#'
#' @return logical
#'
#' @keywords internal
check_connection_to_url <- function(db_url) {
  if (!RCurl::url.exists(db_url)) {stop(paste(db_url, "is not available. No internet connection?"))}
}
