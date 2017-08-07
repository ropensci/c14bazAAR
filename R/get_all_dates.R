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

  aDRAC <- c14databases::get_aDRAC()
  CALPAL <- c14databases::get_CALPAL()
  CONTEXT <- c14databases::get_CONTEXT()
  EUROEVOL <- c14databases::get_EUROEVOL()
  RADON <- c14databases::get_RADON()

  all_dates <- c14databases::fuse(
    aDRAC,
    CALPAL,
    CONTEXT,
    EUROEVOL,
    RADON
  )

  return(all_dates)
}
