#### remove_duplicates ####

#' @rdname duplicates
#' @export
remove_duplicates <- function(x, preferences = NULL, log = TRUE) {
  UseMethod("remove_duplicates")
}

#' @rdname duplicates
#' @export
remove_duplicates.default <- function(x, preferences = NULL, log = TRUE) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname duplicates
#' @export
remove_duplicates.c14_date_list <- function(x, preferences = NULL, log = TRUE) {

  # call functions if necessary columns are missing
  if("duplicate_group" %in% colnames(x) %>% `!`) {
    x %<>% mark_duplicates()
  }

  # start message:
  message(paste0("Removing duplicates... ", {if (nrow(x) > 10000) {"This may take several minutes."}}))

  # get all unique dates
  not_duplicates <- x %>%
    dplyr::filter(
      is.na(.data$duplicate_group)
    )

  # get all duplicates
  duplicates <- x %>%
    dplyr::filter(
      !is.na(.data$duplicate_group)
    )

  # combine the duplicates

  # 1. option: replace inconsistencies with NA
  if (is.null(preferences) | !("sourcedb" %in% colnames(duplicates))) {
    message(
      "You did not provide the argument 'preferences' or your c14_date_list ",
      "does not contain the necessary column 'sourcedb'. That means that duplicates ",
      "are removed in a way that obscures conflicting information. As a result of this ",
      "vital data for your analysis might get lost. "
    )
    message(
      "You can check '?duplicates' for more information or ignore this message."
    )
    summarised_duplicates <- duplicates %>%
      dplyr::group_by(.data$duplicate_group) %>%
      dplyr::summarise_all(
        .funs = dplyr::funs(compare_and_combine_data_frame_values(.))
      ) %>%
      dplyr::ungroup()
  }

  # 2. option: replace inconsistencies with the first value from the prefered database
  if (!is.null(preferences)) {
    preference_based_order <- unique(c(preferences, duplicates$sourcedb %>% unique))
    duplicates$sourcedb <- factor(duplicates$sourcedb, levels = preference_based_order)
    summarised_duplicates <- duplicates %>%
      dplyr::group_by(.data$duplicate_group) %>%
      dplyr::arrange(.data$sourcedb) %>%
      dplyr::filter(dplyr::row_number() == 1) %>%
      dplyr::ungroup()
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
    not_duplicates$duplicate_remove_log <- NA
  }

  # put not_duplicates and duplicates again together
  final_without_duplicates <- not_duplicates %>%
    rbind(summarised_duplicates)

  final_without_duplicates %>%
    as.c14_date_list() %>%
    return()
}

#### helper functions ####

#' stringify_data_frame
#'
#' @param x a data.frame
#'
#' @return a vector of strings describing the data.frame
#'
#' @keywords internal
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

#' compare_and_combine_data_frame_values
#'
#' @param x a data.frame
#'
#' @return a version of the data.frame where all inequalities are replaced by NA
#'
#' @keywords internal
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

