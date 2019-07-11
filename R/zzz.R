# defining global variables
# ugly solution to avoid magrittr NOTE
# see http://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
globalVariables(".")


#' Dummy
#'
#' @importFrom rlang .data
#' @importFrom magrittr "%>%"
#' @importFrom magrittr "%<>%"
#' @importFrom rlang ":="
#'
#' @keywords internal
#' @noRd
dummy_func <- function() {
  "dummy"
}
