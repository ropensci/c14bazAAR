#' @name get_dates
#' @rdname db_getter_backend
#' @export
get_14SEA <- function(db_url = get_db_url("14SEA")) {

  check_if_packages_are_available("openxlsx")

  check_connection_to_url(db_url)

  # download data to temporary file
  tempo <- tempfile()
  utils::download.file(db_url, tempo, mode = "wb", quiet = TRUE)

  # read data
  SEA14 <- tempo %>%
    openxlsx::read.xlsx(
      na.strings = c("Combination fails", "nd", "-"),
      startRow = 2,
      colNames = FALSE,
      rowNames = FALSE
    ) %>%
    dplyr::mutate_if(
      sapply(., is.character),
      trimws
    ) %>%
    dplyr::transmute(
      labnr = .[[5]],
      c14age = .[[6]],
      c14std = .[[7]],
      c13val = .[[8]],
      material = .[[11]],
      country = .[[4]],
      region = .[[2]],
      site = .[[1]],
      lat = NA,
      lon = NA,
      period = .[[15]],
      feature = .[[13]],
      shortref = {
        combined_ref <- paste0(
          ifelse(!is.na(.[[16]]), .[[16]], ""),
          ifelse(!is.na(.[[16]]) & !is.na(.[[17]]), ", ", ""),
          ifelse(!is.na(.[[17]]), .[[17]], ""),
          ifelse(!is.na(.[[17]]) & !is.na(.[[18]]), ", ", ""),
          ifelse(!is.na(.[[18]]), .[[18]], ""),
          ifelse(!is.na(.[[18]]) & !is.na(.[[19]]), ", ", ""),
          ifelse(!is.na(.[[19]]), .[[19]], "")
        )
        ifelse(nchar(combined_ref) == 0, NA, combined_ref)
      },
      comment = .[[14]]
    ) %>%
    dplyr::mutate(
      sourcedb = "14SEA",
      sourcedb_version = get_db_version("14SEA")
    ) %>%
    as.c14_date_list()

  # delete temporary file
  unlink(tempo)

  return(SEA14)
}
