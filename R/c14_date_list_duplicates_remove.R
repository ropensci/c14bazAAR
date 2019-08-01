#### remove_duplicates ####

#' @rdname duplicates
#' @export
remove_duplicates <- function(x, preferences = NULL, supermerge = FALSE, log = TRUE) {
  UseMethod("remove_duplicates")
}

#' @rdname duplicates
#' @export
remove_duplicates.default <- function(x, preferences = NULL, supermerge = FALSE, log = TRUE) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname duplicates
#' @export
remove_duplicates.c14_date_list <- function(x, preferences = NULL, supermerge = FALSE, log = TRUE) {

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
    ) %>%
      mark_duplicates()
  }

  # call functions if necessary duplicate_group column is missing
  if("duplicate_group" %in% colnames(x) %>% `!`) {
    x %<>% mark_duplicates()
  }

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

#### helper functions ####

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
