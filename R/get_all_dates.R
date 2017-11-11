#' get all available data
#'
#' Downloads the current version of several databases and merges them to one c14_date_list
#'
#' @examples
#'
#' \dontrun{
#'   all_dates <- get_all_dates()
#' }
#'
#' @export
get_all_dates <- function() {

  # setup progress bar
  pb <- utils::txtProgressBar(
    max = 100,
    style = 3,
    width = 50,
    char = "+"
  )

  # define list of parser functions
  parser_functions <- c(
    c14bazAAR::get_aDRAC,
    c14bazAAR::get_CalPal,
    c14bazAAR::get_CONTEXT,
    c14bazAAR::get_EUROEVOL,
    c14bazAAR::get_RADON,
    c14bazAAR::get_AustArch,
    c14bazAAR::get_KITEeastAfrica
  )

  # loop to call all parser functions
  date_lists <- list()
  for (i in 1:length(parser_functions)) {
    # call parser function
    date_lists[[i]] <- parser_functions[[i]]()
    # increment progress bar
    utils::setTxtProgressBar(pb, 99 * i/length(parser_functions))
  }

  # fuse radiocarbon lists
  all_dates <- do.call(c14bazAAR::fuse, date_lists)

  # close progress bar
  utils::setTxtProgressBar(pb, 100)
  close(pb)

  return(all_dates)
}
