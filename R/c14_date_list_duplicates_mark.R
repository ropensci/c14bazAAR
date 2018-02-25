#### mark_duplicates ####

#' @name mark_duplicates
#' @title Mark duplicates in a \strong{c14_date_list}
#'
#' @description Duplicates are found by comparision of \strong{labnr}s.
#' Only dates with exactly equal \strong{labnr}s are considered duplicates.
#' Duplicate groups are numbered (from 0) and these numbers linked to
#' the individual dates in the new column \strong{duplicate_group}.
#' Duplicates can be removed with \code{c14bazAAR::remove_duplicates()}.
#'
#' @param x an object of class c14_date_list
#'
#' @return an object of class c14_date_list with the additional
#' column \strong{duplicate_group}
#'
#' @examples
#' mark_duplicates(example_c14_date_list)
#'
#' @export
#'
#' @rdname mark_duplicates
#'
mark_duplicates <- function(x) {
  UseMethod("mark_duplicates")
}

#' @rdname mark_duplicates
#' @export
mark_duplicates.default <- function(x) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname mark_duplicates
#' @export
mark_duplicates.c14_date_list <- function(x) {

  x %>% check_if_columns_are_present("labnr")

  message(paste0("Marking duplicates... ", {if (nrow(x) > 1000) {"This may take several minutes."}}))

  message("-> Search for accordances in Lab Codes...")
  partners <- x[["labnr"]] %>% generate_list_of_equality_partners()

  message("-> Writing duplicate groups...")
  x %<>% add_equality_group_number(partners)

  x %>%
    as.c14_date_list() %>%
    return()
}

#### helper functions ####

#' generate_list_of_equality_partners
#'
#' @param x vector
#'
#' @return list of unique partners
#'
#' @keywords internal
generate_list_of_equality_partners <- function(x) {
  x %>% pbapply::pblapply(
    function(y){
      if(!is.na(y)){
        # core algorithm: search for dates which contain the
        # labnr string of another one
        # grep(y, x[["labnr"]], fixed = T, useBytes = T)
        # better: check for exact equality
        which(y == x)
      } else {
        NA
      }
    }
  ) %>%
    magrittr::extract(sapply(., function(x) {length(x)}) > 1) %>%
    unique() %>%
    return()
}

#' add_equality_group_number
#'
#' @param x c14_date_list
#' @param partner_list partner list produced by generate_list_of_equality_partners()
#'
#' @return c14_date_list with additional column duplicate_group
#'
#' @keywords internal
add_equality_group_number <- function(x, partner_list) {
  amount_duplicate_groups <- length(partner_list)
  pb <- utils::txtProgressBar(
    min = 1, max = amount_duplicate_groups,
    style = 3,
    width = 50,
    char = "+"
  )
  group_counter = 0
  x$duplicate_group <- NA
  for (p1 in 1:amount_duplicate_groups) {
    x$duplicate_group[partner_list[[p1]]] <- group_counter
    group_counter <- group_counter + 1
    utils::setTxtProgressBar(pb, p1)
  }
  close(pb)

  return(x)
}
