#' @rdname db_getter_backend
#' @export
get_14cpalaeolithic <- function(db_url = get_db_url("14cpalaeolithic")) {

  # db_url <- "https://ees.kuleuven.be/geography/projects/14c-palaeolithic/radiocarbon-palaeolithic-europe-database-v26-extract.xlsx"

  check_connection_to_url(db_url)

  # download data
  temp <- tempfile(fileext = ".xlsx")
  utils::download.file(url = db_url, destfile = temp, mode = "wb", quiet = TRUE)

  # read data
  db_raw <- openxlsx::read.xlsx(
    temp,
    sheet = 1
  ) %>%
    dplyr::mutate_if(
      sapply(., is.character),
      trimws
    )

  # remove files in file system
  unlink(temp)

  # final data preparation
  c14palaeolithic <- db_raw %>%
    base::replace(., . == "", NA) %>%
    dplyr::transmute(
      method = .data[["method"]],
      labnr = .data[["labref"]],
      c14age = .data[["age"]],
      c14std = .data[["sigma.+/-"]],
      site = .data[["sitename"]],
      period = .data[["cult.stage"]],
      material = .data[["sample"]],
      country = .data[["country"]],
      lat = .data[["coord_lat"]],
      lon = .data[["coord_long"]],
      shortref = .data[["bibliogr_ref"]]
    ) %>% dplyr::mutate(
      sourcedb = "14cpalaeolithic",
      sourcedb_version = get_db_version("14cpalaeolithic")
    ) %>%
    as.c14_date_list()

  # remove non-radiocarbon dates
  c14palaeolithic <- c14palaeolithic %>%
    dplyr::filter(.data$method %in% c("AMS", "Conv. 14C"))

  return(c14palaeolithic)
}
