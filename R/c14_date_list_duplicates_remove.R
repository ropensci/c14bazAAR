#### remove_duplicates ####

#' @name remove_duplicates
#' @title mark duplicates
#'
#' @description remove double entries in a c14_date_list by
#' comparing the Labcodes
#'
#' @param x an object of class c14_date_list
#'
#' @return an object of class c14_date_list with the additional column duplicate_remove_log
#' @export
#'
#' @rdname remove_duplicates
#'
remove_duplicates <- function(x) {
  UseMethod("remove_duplicates")
}

#' @rdname remove_duplicates
#' @export
remove_duplicates.default <- function(x) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname remove_duplicates
#' @export
remove_duplicates.c14_date_list <- function(x) {

  x %>% check_if_columns_are_present("duplicate_group")

  # start message:
  message(paste0("Removing duplicates... ", {if (nrow(x) > 1000) {"This may take several minutes."}}))

  message("-> Search for accordances in Lab Codes...")

  x %>%
    dplyr::filter(
      !is.na(.data$duplicate_group)
    ) %>%
    dplyr::group_by(.data$duplicate_group) %>%
    dplyr::summarise_all(
      .funs = dplyr::funs(compare_and_combine(.))
    )

  return(x)

}

#### helper functions ####

compare_and_combine <- function(x) {
  # remove NA values
  y <- x[!is.na(x)]
  # if nothing else present, than return NA
  if(length(y) == 0) { return(x[1]) }
  # if all values are the same, than return this value
  if(all(y[1] == y)) {
    return(y[1])
  } else {
    if(class(y) == "character") {
      return(NA_character_)
    } else {
      return(NA)
    }
  }
  # # else return 3
  # return(NA)
}
