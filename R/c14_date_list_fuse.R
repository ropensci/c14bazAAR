#### fuse ####

#' @name fuse
#' @title fuse date tables
#'
#' @description rowbind multiple c14_date_lists
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
    stop("x is not an object of class c14_date_list")
  }

  # actual bind
  dplyr::bind_rows(...) %>%
    return()
}
