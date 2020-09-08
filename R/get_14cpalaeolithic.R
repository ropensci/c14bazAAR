#' @rdname db_getter_backend
#' @export
get_14cpalaeolithic <- function(db_url = get_db_url("14cpalaeolithic")) {

  check_connection_to_url(db_url)

  # download data
  temp <- tempfile(fileext = ".xlsx")
  utils::download.file(url = db_url, destfile = temp, mode = "wb", quiet = TRUE)

  # read data
  db_raw <- temp %>%
    readxl::read_excel(
      sheet = 1,
      col_types = "text",
      na = "",
      trim_ws = TRUE
    )

  # remove files in file system
  unlink(temp)

  # final data preparation
  c14palaeolithic <- db_raw %>%
    dplyr::transmute(
      method = .data[["method"]],
      labnr = .data[["labref"]],
      c14age = .data[["age"]],
      c14std = .data[["sigma +/-"]],
      site = .data[["sitename"]],
      period = .data[["cult stage"]],
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
    dplyr::filter(.data[["method"]] %in% c("AMS", "Conv. 14C"))

  return(c14palaeolithic)
}
