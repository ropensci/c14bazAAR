#' @rdname db_getter_backend
#' @export
get_p3k14c <- function(db_url = get_db_url("p3k14c")) {

  check_connection_to_url(db_url)

  # download and unzip data
  temp <- tempfile()
  utils::download.file(db_url, temp, quiet = TRUE)
  load(temp)

  p3k14c_data$d13C[p3k14c_data$d13C == 0.0] <- NA
  p3k14c_data$d13C <- as.numeric(p3k14c_data$d13C)

  p3k14c <- p3k14c_data %>%
    dplyr::transmute(
      labnr = .data[["LabID"]],
      c14age = .data[["Age"]],
      c13val = .data[["d13C"]],
      c14std = .data[["Error"]],
      material = .data[["Material"]],
      species = .data[["Taxa"]],
      site = .data[["SiteName"]],
      country = .data[["Country"]],
      lat = .data[["Lat"]],
      lon = .data[["Long"]],
      shortref = .data[["Reference"]]
    ) %>%
    dplyr::mutate(
      sourcedb = "p3k14c",
      sourcedb_version = get_db_version("p3k14c")
    ) %>%
    as.c14_date_list()

  return(p3k14c)
}
