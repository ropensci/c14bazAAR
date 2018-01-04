# defining global variables
# ugly solution to avoid magrittr NOTE
# see http://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
globalVariables(".")
# intcal13 dataset from Bchron package
globalVariables("intcal13")



#' Dummy
#'
#' @importFrom rlang .data
#' @importFrom magrittr "%>%"
#' @importFrom magrittr "%<>%"
#' @importFrom rlang ":="
#'
#' @keywords internal
#'
dummy_func <- function() {
  "dummy"
}
