#' @rdname db_getter_backend
#' @export
get_irdd <- function(db_url = get_db_url("irdd")) {

  check_if_packages_are_available("readxl")
  check_connection_to_url(db_url)

  # download data
  temp <- tempfile(fileext = ".xlsx")
  utils::download.file(db_url, temp, mode = "wb", quiet = TRUE)

  # read data
  placeholder_column_names <- paste("col", 1:39, sep = "")
  db_raw <- temp %>%
    readxl::read_excel(
      sheet = 3,
      col_names =  FALSE,
      col_types = "text",
      na = c("?"),
      skip = 1,
      trim_ws = TRUE,
      .name_repair = ~placeholder_column_names
    )

  # delete temporary file
  unlink(temp)

  # final data preparation
  irdd <- db_raw %>% dplyr::transmute(
      labnr = .[[7]],
      c14age = .[[4]],
      c14std = .[[6]],
      site = .[[2]],
      sitetype = .[[15]],
      material = .[[28]],
      lat = .[[20]],
      lon = .[[21]],
      shortref = .[[16]],
      comment = .[[17]]
    ) %>%
    dplyr::mutate(
      sourcedb = "irdd",
      sourcedb_version = get_db_version("irdd")
    ) %>%
    as.c14_date_list()

  return(irdd)
}
