#### duplicates_mark ####

#' @name duplicates_mark
#' @title mark duplicates
#'
#' @description mark double entries in a c14_date_list by
#' comparing the Labcodes
#'
#' @param x an object of class c14_date_list
#'
#' @return an object of class c14_date_list with the additional column duplicate_group
#' @export
#'
#' @rdname duplicates_mark
#'
duplicates_mark <- function(x) {
  UseMethod("duplicates_mark")
}

#' @rdname duplicates_mark
#' @export
duplicates_mark.default <- function(x) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname duplicates_mark
#' @export
duplicates_mark.c14_date_list <- function(x) {

  # start message:
  message(paste0("Marking duplicates... ", {if (nrow(x) > 1000) {"This may take several minutes."}}))

  message("-> Search for accordances in Lab Codes...")
  # search for duplicate occurences
  x %<>%
    dplyr::mutate(
      # search for equality partners of labnr
      partners = pbapply::pblapply(
        .data[["labnr"]],
        function(y){
          if(!is.na(y)){
            # core algorithm: search for dates which contain the
            # labnr string of another one
            grep(y, x[["labnr"]], fixed = T, useBytes = T)
          } else {
            NA
          }
        }
      )
    )

  partner_list <- x %>%
    magrittr::extract2("partners") %>%
    magrittr::extract(sapply(., function(x) {length(x)}) > 1) %>%
    unique()

  message("-> Writing duplicate groups...")
  amount_duplicates <- length(partner_list)
  pb <- utils::txtProgressBar(min = 1, max = amount_duplicates, style = 3)
  group_counter = 0
  x$duplicate_group <- NA
  for (p1 in 1:amount_duplicates) {
    x$duplicate_group[partner_list[[p1]]] <- group_counter
    group_counter <- group_counter + 1
    utils::setTxtProgressBar(pb, p1)
  }
  close(pb)

  # %>%
  #   dplyr::mutate(
  #     # logical vector: which dates are possible duplicates
  #     # (TRUE only for the dates, whose labnr string appears
  #     # within another one)
  #     duplicate_group = sapply(
  #       .data[["partners"]],
  #       function(y){
  #         length(y) > 1
  #       }
  #     )
  #   )
  #
  # doubles_selected <- doubles %>%
  #   # reduce date selection to the ones with lists of equality
  #   # partners
  #   dplyr::filter(
  #     doubles == TRUE
  #   ) %>%
  #   # add a list column with data.frames:
  #   # complete info about the equality group dates
  #   dplyr::mutate(
  #     partners_df = lapply(
  #       .data[["partners"]],
  #       function(y) {
  #         x[y, ]
  #       }
  #     )
  #   )
  #
  # # define vector with colnames of essential variables
  # essential_vars <- c(
  #   "labnr", "site", "c14age", "c14std",
  #   "material", "country", "lat", "lon"
  # )
  #
  # message("-> Decide which values can be removed...")
  # # make decision for every double group
  # to_be_removed <- doubles_selected %>% .[["partners_df"]] %>%
  #   pbapply::pblapply(
  #     function(y) {
  #       # if dates in group completly equal, throw away all but one
  #       if(nrow(unique(y[, !names(y) %in% c("aid")])) == 1) {
  #         return(y[["aid"]][-1])
  #       }
  #       # if labnr equal:
  #       if (length(unique(y[["labnr"]])) == 1) {
  #         # search for dates with the most essential info
  #         missing_essential <- apply(
  #           y[, essential_vars], 1, function(x){sum(is.na(x))}
  #         )
  #         better <- which(missing_essential == min(missing_essential))
  #         # if no differences in amount of essential info,
  #         # then look at non essential info
  #         if(length(better) >= 1) {
  #           missing_non_essential <- apply(
  #             y[, !names(y) %in% essential_vars], 1, function(x){sum(is.na(x))}
  #           )
  #           better <- which(missing_non_essential == min(missing_non_essential))
  #         }
  #         # if still no difference, keep the first date
  #         if(length(better) >= 1) {
  #           better <- 1
  #           # not implemented idea: merge dates - NA for contradictory values
  #         }
  #         y[["aid"]][-better]
  #       }
  #       # everything else (labnr not exactly equal), don't touch
  #     }
  #   ) %>% unlist %>% unique
  #
  # # execute selection
  # if (mark) {
  #   x %>%
  #     # get rid of column aid
  #     dplyr::select(-.data[["aid"]]) %>%
  #     dplyr::mutate(
  #       low_qual_doubles = 1:nrow(x) %in% to_be_removed
  #     ) %>%
  #     as.c14_date_list() %>%
  #     return()
  # } else {
  #   x[-to_be_removed, ] %>%
  #     # get rid of column aid
  #     dplyr::select(-.data[["aid"]]) %>%
  #     as.c14_date_list() %>%
  #     return()
  # }
}
