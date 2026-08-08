#' @rdname db_getter_backend
#' @export
get_14cpalaeolithic <- function(db_url = get_db_url("14cpalaeolithic")) {

  rlang::check_installed("readxl")
  check_connection_to_url(db_url)

  # download data
  temp <- tempfile(fileext = ".xlsx")
  utils::download.file(db_url, destfile = temp, mode = "wb", quiet = TRUE)

  # read data
  db_raw <- temp %>%
    readxl::read_excel(
      sheet = 1,
      skip = 1,
      col_types = "text",
      na = "",
      trim_ws = TRUE
    )

  # delete temporary file
  unlink(temp)

  # remove non-radiocarbon dates
  db_raw_c14 <- db_raw %>%
    dplyr::filter(.data[["Method"]] %in% c("AMS", "14C"))

  # final data preparation
  c14palaeolithic <- db_raw_c14 %>%
    dplyr::transmute(
      c14age   = .data[["Age"]],
      c14std   = .data[["pm"]],
      country  = .data[["country"]],
      feature  = .data[["ayer_id"]],
      labnr    = .data[["labref"]],
      lat      = .data[["Lat"]],
      lon      = .data[["Long"]],
      material = .data[["sample"]],
      method   = .data[["Method"]],
      period   = .data[["Cult stage"]],
      shortref = .data[["bi_bibliogr_ref"]],
      site     = .data[["sitename"]],
      comment  = .data[["reliabilithy"]]
    ) %>%
    add_sourcedb_columns("14cpalaeolithic") %>%
    as.c14_date_list()

  # patch obvious data entry mistakes
  c14palaeolithic_patched <- c14palaeolithic %>%
    dplyr::mutate(
      c14age = dplyr::case_when(
        labnr == "UCIAMS-286509" ~ 40900,
        labnr == "VERA-8488" ~ 42081,
        .default = c14age
      ),
      c14std = dplyr::case_when(
        labnr == "UCIAMS-286509" ~ 1400,
        labnr == "VERA-8488" ~ 984,
        .default = c14std
      )
    )

  return(c14palaeolithic_patched)
}
