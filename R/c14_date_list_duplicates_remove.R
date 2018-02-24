#### remove_duplicates ####

#' @name remove_duplicates
#' @title remove duplicates
#'
#' @description remove double entries in a c14_date_list
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

  # stringify variation in duplicates: log string
  stringified_differences <- duplicates %>%
    plyr::dlply("duplicate_group") %>%
    purrr::map_chr(.f = stringify_data_frame)

  # combine the duplicates and add the log string
  summarised_duplicates <- duplicates %>%
    dplyr::group_by(.data$duplicate_group) %>%
    dplyr::summarise_all(
      .funs = dplyr::funs(compare_and_combine(.))
    ) %>%
    dplyr::mutate(
      duplicate_remove_log = stringified_differences
    )

  # put not_duplicates and duplicates again together
  not_duplicates$duplicate_remove_log <- NA
  final_without_duplicates <- not_duplicates %>%
    rbind(summarised_duplicates)

  return(final_without_duplicates)
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

compare_and_combine <- function(x) {
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
