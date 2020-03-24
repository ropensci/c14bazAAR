#' @rdname db_getter_backend
#' @export
get_medafricarbon <- function(db_url = get_db_url("medafricarbon")) {

  check_connection_to_url(db_url)

  # download and unzip data
  temp <- tempfile()
  utils::download.file(db_url, temp, quiet = TRUE)

  db_path <- utils::unzip(
    temp,
    exdir = tempdir()
  )

  # read in individual tables
  db_dates <- data.table::fread(
    db_path[grepl("/dateTable.csv", db_path)],
    sep = ",",
    na.strings = "NULL",
    encoding = "UTF-8"
  )

  db_sites <- data.table::fread(
    db_path[grepl("/siteTable.csv", db_path)],
    sep = ",",
    na.strings = "NULL",
    encoding = "UTF-8"
  )

  db_culturelink <- data.table::fread(
    db_path[grepl("/cultureLink.csv", db_path)],
    sep = ",",
    na.strings = "NULL",
    encoding = "UTF-8"
  )

  # build chain of cultural attributions
  db_culture <- db_culturelink %>%
    dplyr::select(.data[["Culture_ID"]], .data[["Date_ID"]]) %>%
      dplyr::group_by(.data[["Date_ID"]]) %>%
      dplyr::summarise(
        culture = paste(.data[["Culture_ID"]], collapse = ", ")
      )

  db_reflinks <- data.table::fread(
    db_path[grepl("/dateRefLink.csv", db_path)],
    sep = ",",
    na.strings = "NULL",
    encoding = "UTF-8"
  )

  # build chain of reflinks for shortref field
  db_ref <- db_reflinks %>%
    dplyr::select(.data[["BibTexKey"]], .data[["Date_ID"]]) %>%
    dplyr::group_by(.data[["Date_ID"]]) %>%
    dplyr::summarise(
      shortref = paste(.data[["BibTexKey"]], collapse = ", ")
    )

  # remove files in file system
  unlink(temp)
  file.remove(db_path)

  # build raw data based on schema
  medafricarbon <- db_dates %>%
    dplyr::left_join(db_sites, by = "Site_ID") %>%
    dplyr::left_join(db_culture, by = "Date_ID") %>%
    dplyr::left_join(db_ref, by = "Date_ID") %>%
    base::replace(., . == "", NA) %>%
    dplyr::transmute(
      method = .data[["Date_Method"]],
      labnr = .data[["Lab_ID"]],
      c14age = .data[["CRA"]],
      c14std = .data[["Error"]],
      c13val = .data[["DC13"]],
      site = .data[["Site_Name"]],
      sitetype = .data[["Site_Type"]],
      feature = .data[["Site_Context"]],
      culture = .data[["culture"]],
      material = .data[["Material"]],
      region = .data[["Admin_Region"]],
      country = .data[["Country"]],
      lat = .data[["Decimal_Degrees_Lat"]],
      lon = .data[["Decimal_Degrees_Long"]],
      shortref = .data[["shortref"]],
      comment = .data[["Notes"]]
    ) %>% dplyr::mutate(
      sourcedb = "medafricarbon",
      sourcedb_version = get_db_version("medafricarbon")
    ) %>%
    as.c14_date_list()

  return(medafricarbon)
}
