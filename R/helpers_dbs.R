#' Get information for c14 databases
#'
#' Looks for information for the c14 source databases in \link{db_info_table}.
#'
#' @param ... names of the databases
#' @param db_info_table db info reference table
#'
#' @rdname get_db_info
#' @export
get_db_url <- function(..., db_info_table = c14bazAAR::db_info_table) {
  db_name <- c(...)
  db_pos_list <- get_db_pos(db_name, db_info_table)
  val_list <- Map(
    function(x) { db_info_table$url[x] },
    db_pos_list
  )
  if (length(val_list) == 1) {
    return(Reduce(c, val_list))
  } else {
    return(val_list)
  }
}

#' @rdname get_db_info
#' @export
get_db_version <- function(..., db_info_table = c14bazAAR::db_info_table) {
  db_name <- c(...)
  db_pos_list <- get_db_pos(db_name, db_info_table)
  Map(
    function(x) {
      v <- db_info_table$version[x]
      v <- stats::na.omit(v)
      v[v == "today"] <- format(Sys.time(), "%Y-%m-%d")
      as.Date(v, format = "%Y-%m-%d")
    },
    db_pos_list
  ) %>% Reduce(c, .)
}

#' @keywords internal
#' @noRd
get_db_pos <- function(db_name, db_info_table){
  tibble::tibble(
    found = match(tolower(db_info_table$db), tolower(db_name)),
    pos = 1:nrow(db_info_table)
  ) %>%
    dplyr::filter(
      !is.na(.data[["found"]])
    ) %>%
    dplyr::arrange(
      .data[["found"]], .data[["pos"]]
    ) %>%
    dplyr::group_split(
      .data[["found"]]
    ) %>%
    Map(function(x) { x$pos }, .)
}
