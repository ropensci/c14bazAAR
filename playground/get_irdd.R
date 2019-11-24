#get_IRDD <- function(db_url = get_db_url("IRDD")) {

  db_url <- "https://zenodo.org/record/3367518/files/Chapple%2C%20RM%202019%20Catalogue%20of%20radiocarbon%20determinations%20%26%20dendrochronology%20dates%20%28August%202019%20Release%29.xlsx"

  check_if_packages_are_available("openxlsx")

  check_connection_to_url(db_url)

  # download data to temporary file
  tempo <- tempfile()
  utils::download.file(db_url, tempo, mode = "wb", quiet = TRUE)

  # read data
  IRDD <- tempo %>%
    openxlsx::read.xlsx(
      sheet = 3,
      startRow = 2,
      colNames = FALSE,
      rowNames = FALSE
    ) %>%
    dplyr::mutate_if(
      sapply(., is.character),
      trimws
    ) %>%
    dplyr::transmute(
      labnr = .[[7]],
      c14age = .[[4]],
      c14std = .[[6]],
      c13val = .[[25]],
      material = .[[26]],
      # country = .[[4]],
      # region = .[[2]],
      # site = .[[1]],
      lat = .[[19]],
      lon = .[[20]],
      # period = .[[15]],
      # feature = .[[13]],
      shortref = .[[15]]
      #comment = .[[14]]
    ) %>%
    dplyr::mutate(
      sourcedb = "IR-DD"
    ) %>%
    as.c14_date_list()

  # delete temporary file
  unlink(tempo)

#  return(IRDD)
#}
