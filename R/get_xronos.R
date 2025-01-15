#' @rdname db_getter_backend
#' @export
get_xronos <- function(db_url = get_db_url("xronos")) {

  check_connection_to_url("https://www.xronos.ch")

  resp <- httr::GET(db_url)

  xronos_data <- httr::content(resp, as = "parsed") %>% unique() %>% tidyr::tibble()

  periods_parsed <- parse_json_lists(xronos_data[["periods"]])
  reference_parsed <- parse_json_lists(xronos_data[["reference"]])

  xronos <- xronos_data %>%
    dplyr::transmute(
      labnr = .data[["labnr"]],
      c14age = .data[["bp"]],
      c14std = .data[["std"]],
      c13val = .data[["delta_c13"]],
      material = .data[["material"]],
      species = .data[["species"]],
      country = .data[["country"]],
      site = .data[["site"]],
      sitetype = .data[["site_type"]],
      feature = .data[["feature"]],
      period = periods_parsed,
      shortref = reference_parsed,
      lat = .data[["lat"]],
      lon = .data[["lng"]]) %>%
    dplyr::mutate(
      sourcedb = "xronos",
      sourcedb_version = get_db_version("xronos")
    ) %>%
    c14bazAAR::as.c14_date_list()

  return(xronos)
}

# helper function to parse JSON to a ;-separated string list
parse_json_lists <- function(y) {
  purrr::map_chr(y,
    \(x) {
      if (x != "[]") {
        jsonlite::fromJSON(x, simplifyDataFrame = FALSE) %>%
          purrr::map(\(x) ifelse(x == "", NA_character_, x)) %>%
          purrr::reduce(\(x,y) { stringr::str_flatten(c(x,y), collapse = ";", na.rm = T)}) %>%
          unlist()
      } else ""
    }
  )
}
