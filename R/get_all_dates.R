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

  aDRAC <- c14bazAAR::get_aDRAC()
  CALPAL <- c14bazAAR::get_CALPAL()
  CONTEXT <- c14bazAAR::get_CONTEXT()
  EUROEVOL <- c14bazAAR::get_EUROEVOL()
  RADON <- c14bazAAR::get_RADON()

  all_dates <- c14bazAAR::fuse(
    aDRAC,
    CALPAL,
    CONTEXT,
    EUROEVOL,
    RADON
  )

  return(all_dates)
}
