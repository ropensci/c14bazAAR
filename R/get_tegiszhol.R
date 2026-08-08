#' @rdname db_getter_backend
#' @export
get_tegiszhol <- function(db_url = get_db_url("tegiszhol")) {

  check_connection_to_url(db_url)

  # read data
  tegiszhol <- db_url %>%
    data.table::fread(
      colClasses = "character",
      showProgress = FALSE,
      encoding = "UTF-8"
    ) %>%
    base::replace(., . == "", NA) %>%
    dplyr::transmute(
      labnr = .data[["labnr"]],
      c14age = .data[["c14age"]],
      c14std = .data[["c14std"]],
      c13val = .data[["c13val"]],
      site = .data[["site"]],
      sitetype = .data[["sitetype"]],
      feature = .data[["feature"]],
      material = .data[["material"]],
      species = .data[["species"]],
      country = .data[["country"]],
      region = .data[["region"]],
      lat = .data[["lat"]],
      lon = .data[["lon"]],
      period = .data[["period"]],
      culture = .data[["culture"]],
      shortref = .data[["shortref"]],
      comment = .data[["comment"]],
      method = .data[["method"]]
    ) %>%
    add_sourcedb_columns("tegiszhol") %>%
    as.c14_date_list()

  return(tegiszhol)
}
