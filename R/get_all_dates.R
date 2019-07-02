#### get_all_dates ####

# name (get_dates) of documentation group has to be adjusted in alphabetically first element get_14SEA()
#' @title Download radiocarbon source databases and convert them to a \strong{c14_date_list}
#'
#' @description This functions download source databases and adjust their variables to conform to the
#' definition in \code{c14bazAAR::variable_reference}. That includes renaming and arranging
#' the variables (with \code{c14bazAAR::order_variables()}) as well as type conversion
#' (with \code{c14bazAAR::enforce_types()}) -- so all the steps undertaken by
#' \code{as.c14_date_list()}. \cr
#' All databases require different downloading and data wrangling steps. Therefore
#' there's a custom getter function for each of them. \cr
#' \code{get_all_dates()} is a wrapper to download all dates from all databases and
#' \code{c14bazAAR::fuse()} the results.
#'
#' @param db_url weblink to c14 archive file. \code{c14bazAAR::get_db_url()} fetches the
#' current URL of the data source
#'
#' @rdname db_getter
#'
#' @examples
#'
#' \dontrun{
#'   aDRAC <- get_aDRAC()
#'   all_dates <- get_all_dates()
#' }
#'
#' @export
get_all_dates <- function() {

  message("Trying to download all dates...")

  # setup progress bar
  pb <- utils::txtProgressBar(
    max = 100,
    style = 3,
    width = 50,
    char = "+"
  )

  # define list of parser functions
  parser_functions <- get_all_parser_functions()

  # loop to call all parser functions
  date_lists <- list()
  for (i in 1:length(parser_functions)) {
    # call parser function
    date_lists[[i]] <- tryCatch(parser_functions[[i]](),error=function(e) e)
    # increment progress bar
    utils::setTxtProgressBar(pb, 99 * i/length(parser_functions))
  }

  error_ind <- sapply(date_lists,function(x) !('c14_date_list' %in% class(x)))
  errors <- date_lists[error_ind]
  date_lists <- date_lists[!error_ind]

  if(any(error_ind)) {
    warning(paste("There were errors:\n\n",paste(sapply(errors,function(x) x$message), collapse = "\n"),"\n\nNot all data might have been downloaded accurately!",sep=""))
  }

  # fuse radiocarbon lists
  all_dates <- do.call(c14bazAAR::fuse, date_lists)

  # close progress bar
  utils::setTxtProgressBar(pb, 100)
  close(pb)

  return(all_dates)
}

#' get_all_parser_functions
#'
#' @return vector with all parser functions in c14bazAAR
#'
#' @keywords internal
get_all_parser_functions <- function() {
  c(
    c14bazAAR::get_14SEA,
    c14bazAAR::get_aDRAC,
    c14bazAAR::get_AustArch,
    c14bazAAR::get_CalPal,
    c14bazAAR::get_CONTEXT,
    c14bazAAR::get_EUBAR,
    c14bazAAR::get_EUROEVOL,
    c14bazAAR::get_RADON,
    c14bazAAR::get_RADONB,
    c14bazAAR::get_KITEeastAfrica,
    c14bazAAR::get_Palmisano
  ) %>%
    return()
}
