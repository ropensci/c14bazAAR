#' @rdname db_getter_backend
#' @export
get_agrichange <- function(db_url = get_db_url("agrichange")) {

  check_if_packages_are_available("readxl")
  check_connection_to_url(db_url)

  # download data
  temp <- tempfile(fileext = ".xlsx")
  utils::download.file(db_url, temp, mode = "wb", quiet = TRUE)

  # read data
  db_raw <- temp %>%
    readxl::read_excel(
      sheet = 1,
      col_names =  TRUE,
      col_types = "text",
      na = c("<<notfound>>"),
      trim_ws = TRUE
    )

  # delete temporary file
  unlink(temp)


  db_raw %>%
    dplyr::select(
      -c(
        1,
        2
        )
    )



  # final data preparation
  agrichange <- db_raw %>%
    dplyr::select(
      -c(
        1, # ID
        7, # cal 2sigma
        8, # mean
        10, # %C
        11, # %N
        12, # C/N
        14, # BP-SD
        15, # SoC,
        16, # Reliability,
        17, # ReliabilityWhy,
        19, # CultI,
        20,  # CultII,
        22, # Provenance,
        23, # Subfamily / Familiy
        24, # Genus / specie
        25, # Level,
        26, # Struc,
        27, # SU,
        30, # Alt,
        31, # Georegion,
        32, # Municipality,
        33, # Province,
        34, # Region,
        36, # Lat_muni,
        37, # Lon_muni,
        38, # Alt_muni,
        40  # Database_reference
      )
    ) %>%
    dplyr::transmute(
      labnr = .data[["LabCode"]],
      c14age = .data[["BP"]],
      c14std = .data[["SD"]],
      c13val = .[[7]], # d13
      method = .data[["Method"]],
      material = .data[["Sample"]],
      site = .data[["Site"]],
      country = .data[["Country"]],
      sitetype = .data[["TypeSite"]],
      lat = .data[["Lat"]],
      lon = .data[["Lon"]],
      shortref = .data[["Date_reference"]],
      comment = .data[["Observations"]]
    ) %>%
    dplyr::mutate(
      sourcedb = "agrichange",
      sourcedb_version = get_db_version("agrichange")
    ) %>%
    as.c14_date_list()

  return(agrichange)

}
