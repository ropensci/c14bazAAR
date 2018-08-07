#### fuse ####

#' @name fuse
#' @title Fuse multiple \strong{c14_date_list}s
#'
#' @description This function combines \strong{c14_date_list}s with
#' \code{dplyr::bind_rows()}. \cr
#' This is not a joining operation and it therefore
#' might introduce duplicates. See \code{c14bazAAR::mark_duplicates()}
#' and \code{c14bazAAR::remove_duplicates()} for a way to find and remove
#' them.
#'
#' @param ... objects of class c14_date_list
#'
#' @return an object of class c14_date_list
#' @export
#'
#' @rdname fuse
#'
fuse <- function(...) {
  UseMethod("fuse")
}

#' @rdname fuse
#' @export
fuse.default <- function(...) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname fuse
#' @export
fuse.c14_date_list <- function(...) {

  # check class of input objects
  issesnu <- list(...) %>%
    sapply(FUN = is.c14_date_list) %>%
    all %>%
    `!`

  if(issesnu) {
    stop("One of the input objects is not of class c14_date_list.")
  }

  # actual bind
  dplyr::bind_rows(...) %>%
    as.c14_date_list() %>%
    return()
}
