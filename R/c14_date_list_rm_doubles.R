#### rm_doubles ####

#' @name rm_doubles
#' @title Removes doubles
#'
#' @description Removes double entries in a c14_date_list by comparing the Labcodes
#'
#' @param x an object of class c14_date_list
#'
#' @return an object of class c14_date_list
#' @export
#'
#' @rdname rm_doubles
#'
rm_doubles <- function(x) {
  UseMethod("rm_doubles")
}

#' @rdname rm_doubles
#' @export
rm_doubles.default <- function(x) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname rm_doubles
#' @export
rm_doubles.c14_date_list <- function(x) {

  if (nrow(x) > 1000) {
    message("This may take several minutes...")
  }

  # setup progress bar
  pb <- utils::txtProgressBar(
    max = 100,
    style = 3
  )

  # add artificial id
  x <- x %>%
    dplyr::mutate(
      aid = 1:nrow(.)
    )

  utils::setTxtProgressBar(pb, 1)

  # search for double occurences
  doubles <- x %>%
    dplyr::select(
      .data[["labnr"]], .data[["aid"]]
    ) %>%
    dplyr::mutate(
      # equality partners
      partners = lapply(
        .data[["labnr"]],
        function(y){
          if(!is.na(y)){
            grep(tolower(y), tolower(x[["labnr"]]))
          } else {
            NA
          }
        }
      )
    ) %>%
    dplyr::mutate(
      # which dates are possible doubles
      doubles = sapply(
        .data[["partners"]],
        function(y){
          length(y) > 1
        }
      )
    )

  utils::setTxtProgressBar(pb, 80)

  doubles_selected <- doubles %>%
    # focus on doubles
    dplyr::filter(
      doubles == TRUE
    ) %>%
    # extract complete data for double groups
    dplyr::mutate(
      partners_df = lapply(
        .data[["partners"]],
        function(y) {
          x[y, ]
        }
      )
    )

  utils::setTxtProgressBar(pb, 85)

  essential_vars <- c("labnr", "site", "c14age", "c14std", "material", "country", "lat", "lon")

  # make decision for every double group
  to_be_removed <- doubles_selected %>% .[["partners_df"]] %>%
    lapply(
      function(y) {
        # if completly equal, throw away all but one
        if(nrow(unique(y)) == 1) {y[["aid"]][-1]}
        # if labnr equal, throw away the one with less essential info
        if (length(unique(y[["labnr"]])) == 1) {
          better <- which.min(apply(y[, essential_vars], 1, function(x){sum(is.na(x))}))
          y[["aid"]][-better]
        }
        # everything else, don't touch
      }
    ) %>% unlist %>% unique

  utils::setTxtProgressBar(pb, 100)
  close(pb)

  x[-to_be_removed, ] %>%
    return()
}
