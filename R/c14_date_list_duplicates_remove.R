#### remove_duplicates ####

#' @name duplicates
#' @title Remove duplicates in a \strong{c14_date_list}
#'
#' @description Duplicates are found by comparison of \strong{labnr}s.
#' Only dates with exactly equal \strong{labnr}s are considered duplicates.
#' Duplicate groups are numbered (from 0) and these numbers linked to
#' the individual dates in a internal column \strong{duplicate_group}.
#' If you only want to see this grouping without removing anything use the \code{mark_only} flag.
#' \code{c14bazAAR::remove_duplicates()} can remove duplicates with three different strategies
#' according to the value of the arguments \code{preferences} and \code{supermerge}:
#' \enumerate{
#'   \item Option 1: By merging all dates in a \strong{duplicate_group}. All non-equal variables
#'   in the duplicate group are turned to \code{NA}. This is the default option.
#'   \item Option 2: By selecting individual database entries in a \strong{duplicate_group}
#'   according to a trust hierarchy as defined by the parameter \code{preferences}.
#'   In case of duplicates within one database the first occurrence in the table (top down)
#'   is selected. All databases not mentioned in \code{preferences} are dropped.
#'   \item Option 3: Like option 2, but in this case the different datasets in a
#'   \strong{duplicate_group} are merged column by column to
#'   create a superdataset with a maximum of information. The column \strong{sourcedb} is
#'   dropped in this case to indicate that multiple databases have been merged. Data
#'   citation is a lot more difficult with this option. It can be activated with \code{supermerge}.
#' }
#' The option \code{log} allows to add a new column \strong{duplicate_remove_log}
#' that documents the variety of values provided by all databases for this
#' duplicated date.
#'
#' @param x an object of class c14_date_list
#' @param preferences character vector with the order of source databases by
#' which the deduping should be executed. If e.g. preferences = c("radon", "calpal")
#' and a certain date appears in radon and euroevol, then only the radon entry remains.
#' Default: NULL. With preferences = NULL all overlapping, conflicting information in
#' individual columns of one duplicated date is removed. See Option 2 and 3.
#' @param supermerge boolean. Should the duplicated datasets be merged on the column level?
#' Default: FALSE. See Option 3.
#' @param log logical. If log = TRUE, an additional column is added that contains a string
#' documentation of all variants of the information for one date from all conflicting
#' databases. Default = TRUE.
#' @param mark_only boolean. Should duplicates not be removed, but only indicated? Default: FALSE.
#'
#' @return an object of class c14_date_list with the additional
#' columns \strong{duplicate_group} or \strong{duplicate_remove_log}
#'
#' @rdname duplicates
#'
#' @examples
#' library(magrittr)
#'
#' test_data <- tibble::tribble(
#'   ~sourcedb, ~labnr,  ~c14age, ~c14std,
#'  "A",       "lab-1", 1100,    10,
#'  "A",       "lab-1", 2100,    20,
#'  "B",       "lab-1", 3100,    30,
#'  "A",       "lab-2", NA,      10,
#'  "B",       "lab-2", 2200,    20,
#'  "C",       "lab-3", 1300,    10
#' ) %>% as.c14_date_list()
#'
#' # mark duplicates
#' test_data %>% find_and_mark_duplicates()
#'
#' # remove duplicates with option 1:
#' test_data %>% remove_duplicates()
#'
#' # remove duplicates with option 2:
#' test_data %>% remove_duplicates(
#'   preferences = c("A", "B")
#' )
#'
#' # remove duplicates with option 3:
#' test_data %>% remove_duplicates(
#'   preferences = c("A", "B"),
#'   supermerge = TRUE
#' )
#'
#' @export
remove_duplicates <- function(
  x,
  preferences = NULL,
  supermerge = FALSE,
  log = TRUE,
  mark_only = FALSE
) {
  UseMethod("remove_duplicates")
}

#' @rdname duplicates
#' @export
remove_duplicates.default <- function(
  x,
  preferences = NULL,
  supermerge = FALSE,
  log = TRUE,
  mark_only = FALSE
) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname duplicates
#' @export
remove_duplicates.c14_date_list <- function(
  x,
  preferences = NULL,
  supermerge = FALSE,
  log = TRUE,
  mark_only = FALSE
) {

  # set usage option
  if (is.null(preferences) | !("sourcedb" %in% colnames(x))) {
    # 1. option: replace inconsistencies with NA
    removal_option <- 1
    message(
      "You did not provide the argument 'preferences' or your c14_date_list ",
      "does not contain the necessary column 'sourcedb'. That means that duplicates ",
      "are removed in a way that obscures conflicting information. As a result of this ",
      "vital data for your analysis might get lost. "
    )
    message(
      "Please check '?duplicates' for more information."
    )
  } else if (!supermerge & !is.null(preferences) & "sourcedb" %in% colnames(x)) {
    # 2. option: replace inconsistencies with the first value from the prefered database
    removal_option <- 2
  } else if (supermerge & !is.null(preferences) & "sourcedb" %in% colnames(x)) {
    # 3. option: supermerge
    removal_option <- 3
  }

  # filter dataset to database selection
  if (removal_option == 2 | removal_option == 3) {
    x %<>% dplyr::filter(
      .data$sourcedb %in% preferences
    )
  }

  # mark duplicates if not already done
  if("duplicate_group" %in% colnames(x) %>% `!`) {
    x %<>% find_and_mark_duplicates()
  }

  # if only marking was requested
  if (mark_only) { return(x) }

  # if if there are no duplicates, then stop. There's nothing to remove
  if(all(is.na(x[["duplicate_group"]]))) {
    message("No duplicates found.")
    return(x)
  }

  # start message:
  message(paste0("Removing duplicates... ", {if (nrow(x) > 10000) {"This may take several minutes."}}))

  # get all unique dates
  not_duplicates <- x %>%
    dplyr::filter(
      is.na(.data$duplicate_group)
    )

  # get all duplicates and order them by the duplicate group number
  duplicates <- x %>%
    dplyr::filter(
      !is.na(.data$duplicate_group)
    ) %>%
    dplyr::arrange(
      .data$duplicate_group
    )

  # combine the duplicates

  # 1. option
  if (removal_option == 1) {
    summarised_duplicates <- duplicates %>%
      split(., .$duplicate_group) %>%
      pbapply::pblapply(
        .,
        function(x) {
          dplyr::summarise_all(
            x,
            .funs = ~compare_and_combine_data_frame_values(.)
          )
        }
      ) %>%
      do.call(rbind, .) %>%
      dplyr::arrange(.data$duplicate_group)
  }

  # 2. option
  if (removal_option == 2) {
    preference_based_order <- unique(c(preferences, duplicates$sourcedb %>% unique))
    duplicates$sourcedb_factor <- factor(duplicates$sourcedb, levels = preference_based_order)
    summarised_duplicates <- duplicates %>%
      dplyr::group_by(.data$duplicate_group) %>%
      dplyr::arrange(.data$sourcedb_factor) %>%
      dplyr::filter(dplyr::row_number() == 1) %>%
      dplyr::ungroup() %>%
      dplyr::select(-.data$sourcedb_factor) %>%
      dplyr::arrange(.data$duplicate_group)
  }

  # 3. option
  if (removal_option == 3) {
    summarised_duplicates <- duplicates %>%
      dplyr::mutate(
        sourcedb_order = match(.data$sourcedb, preferences)
      ) %>%
      split(., .$duplicate_group) %>%
      pbapply::pblapply(
        .,
        function(x) {
          dplyr::summarise_all(
            x,
            .funs = ~supermerge_data_frame_values(., order = x$sourcedb_order)
          )
        }
      ) %>%
      do.call(rbind, .) %>%
      dplyr::select(
        -.data$sourcedb_order,
        -.data$sourcedb
      ) %>%
      dplyr::arrange(.data$duplicate_group)

    not_duplicates <- not_duplicates %>% dplyr::select(-.data$sourcedb)
  }

  # optional: add log string
  if (log) {
    # create log string: stringify variation in duplicates
    log_string <- duplicates %>%
      plyr::dlply("duplicate_group") %>%
      lapply(FUN = stringify_data_frame) %>%
      unlist
    # duplicates
    summarised_duplicates <- summarised_duplicates %>%
      dplyr::mutate(
        duplicate_remove_log = if(length(log_string) != 0) {
          log_string
        } else {
          NA_character_
        }
      )
    # not_duplicates
    if (nrow(not_duplicates) > 0) {
      not_duplicates$duplicate_remove_log <- NA
    }
  }

  # put not_duplicates and duplicates again together
  final_without_duplicates <- not_duplicates %>%
    rbind(summarised_duplicates)

  final_without_duplicates %>%
    dplyr::select(
      -.data$duplicate_group
    ) %>%
    as.c14_date_list() %>%
    return()
}

#' @rdname duplicates
#' @export
mark_duplicates <- function(x) {
  stop(
    "This function is deprecated. remove_duplicates() includes this functionality now. ",
    "Please use remove_duplicates() with mark_only = TRUE if you only want to ",
    "retrieve the duplicate_group column. ",
    "Check '?duplicates' for more information."
  )
}

#### helper functions ####

#' @keywords internal
#' @noRd
find_and_mark_duplicates <- function(x) {

  x %>% check_if_columns_are_present("labnr")

  message(paste0("Marking duplicates... ", {if (nrow(x) > 10000) {"This may take several minutes."}}))

  message("-> Search for accordances in Lab Codes...")
  partners <- x[["labnr"]] %>% generate_list_of_equality_partners()

  message("-> Writing duplicate groups...")
  x %<>% add_equality_group_number(partners)

  x %>%
    as.c14_date_list() %>%
    return()
}

#' generate_list_of_equality_partners
#'
#' @param x vector
#'
#' @return list of unique partners
#'
#' @keywords internal
#' @noRd
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
#' @noRd
add_equality_group_number <- function(x, partner_list) {
  x$duplicate_group <- NA

  if(length(partner_list) > 0) {
    amount_duplicate_groups <- length(partner_list)
    pb <- utils::txtProgressBar(
      min = 0, max = amount_duplicate_groups,
      style = 3,
      width = 50,
      char = "+"
    )
    group_counter = 0
    for (p1 in 1:amount_duplicate_groups) {
      x$duplicate_group[partner_list[[p1]]] <- group_counter
      group_counter <- group_counter + 1
      utils::setTxtProgressBar(pb, p1)
    }
    close(pb)
  }

  return(x)
}

#' @keywords internal
#' @noRd
stringify_data_frame <- function(x) {
  # remove all columns that are not character or numeric
  y <- x[, sapply(x, class) %in% c("character", "numeric", "double", "integer", "factor")]
  # create string representing the content of the data.frame
  sapply(colnames(y), function(x) {
    paste0(x, ": ", paste(unique(y[[x]]), collapse = "|")) }
  ) %>%
    paste(collapse = ", ") %>%
    return()
}

#' @keywords internal
#' @noRd
compare_and_combine_data_frame_values <- function(x) {
  # remove NA values
  y <- x[!is.na(x)]
  # if only NA, than return NA
  if(length(y) == 0) { return(x[1]) }
  # if all values are the same, than return this value
  if(all(y[1] == y)) {
    return(y[1])
  # else return NA
  } else {
    if(class(y) == "character") {
      return(NA_character_)
    } else {
      return(NA)
    }
  }
}

#' @keywords internal
#' @noRd
supermerge_data_frame_values <- function(x, order_vector) {
  # if all values are NA, than return NA
  if (all(is.na(x))) {
    if(class(x) == "character") {
      return(NA_character_)
    } else {
      return(NA)
    }
  # if all values are equal, than return that value
  } else if (length(unique(stats::na.omit(x))) == 1) {
    return(unique(stats::na.omit(x)))
  # else return the value with the highest rank
  } else {
    ordered <- x[order(order_vector)]
    return(ordered[which(!is.na(ordered))[1]])
  }
}
