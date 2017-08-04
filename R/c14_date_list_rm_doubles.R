#### rm_doubles ####

#' @name rm_doubles
#' @title Removes doubles
#'
#' @description Removes double entries in a c14_date_list by
#' comparing the Labcodes
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

  # add artificial id for later subsetting
  x <- x %>%
    dplyr::mutate(
      aid = 1:nrow(.)
    )

  labnr_low <- tolower(x[["labnr"]])
  message("Search for accordances in Lab Codes...")
  # search for double occurences
  doubles <- x %>%
    dplyr::select(
      .data[["labnr"]], .data[["aid"]]
    ) %>%
    dplyr::mutate(
      # search for equality partners of labnr
      partners = pbapply::pblapply(
        tolower(.data[["labnr"]]),
        function(y){
          if(!is.na(y)){
            # core algorithm: search for dates which contain the
            # labnr string of another one
            grep(y, labnr_low)
          } else {
            NA
          }
        }
      )
    ) %>%
    dplyr::mutate(
      # logical vector: which dates are possible doubles
      # (TRUE only for the dates, whose labnr string appears
      # within another one)
      doubles = sapply(
        .data[["partners"]],
        function(y){
          length(y) > 1
        }
      )
    )

  doubles_selected <- doubles %>%
    # reduce date selection to the ones with lists of equality
    # partners
    dplyr::filter(
      doubles == TRUE
    ) %>%
    # add a list column with data.frames:
    # complete info about the equality group dates
    dplyr::mutate(
      partners_df = lapply(
        .data[["partners"]],
        function(y) {
          x[y, ]
        }
      )
    )

  # define vector with colnames of essential variables
  essential_vars <- c(
    "labnr", "site", "c14age", "c14std",
    "material", "country", "lat", "lon"
  )

  message("Decide which values can be removed...")
  # make decision for every double group
  to_be_removed <- doubles_selected %>% .[["partners_df"]] %>%
    pbapply::pblapply(
      function(y) {
        # if dates in group completly equal, throw away all but one
        if(nrow(unique(y[, !names(y) %in% c("aid")])) == 1) {
          return(y[["aid"]][-1])
        }
        # if labnr equal:
        if (length(unique(y[["labnr"]])) == 1) {
          # search for dates with the most essential info
          missing_essential <- apply(
            y[, essential_vars], 1, function(x){sum(is.na(x))}
          )
          better <- which(missing_essential == min(missing_essential))
          # if no differences in amount of essential info,
          # then look at non essential info
          if(length(better) >= 1) {
            missing_non_essential <- apply(
              y[, !names(y) %in% essential_vars], 1, function(x){sum(is.na(x))}
            )
            better <- which(missing_non_essential == min(missing_non_essential))
          }
          # if still no difference, keep the first date
          if(length(better) >= 1) {
            better <- 1
            # not implemented idea: merge dates - NA for contradictory values
          }
          y[["aid"]][-better]
        }
        # everything else (labnr not exactly equal), don't touch
      }
    ) %>% unlist %>% unique

  # execute selection
  x[-to_be_removed, ] %>%
    # get rid of column aid
    dplyr::select(-.data[["aid"]]) %>%
    as.c14_date_list() %>%
    return()
}
