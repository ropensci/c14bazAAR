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
    encoding = "UTF-8")

  db_sites <- data.table::fread(
    db_path[grepl("/siteTable.csv", db_path)],
    sep = ",",
    na.strings = "NULL",
    encoding = "UTF-8")

  db_culturelink <- data.table::fread(
    db_path[grepl("/cultureLink.csv", db_path)],
    sep = ",",
    na.strings = "NULL",
    encoding = "UTF-8")

  # build chain of cultural attributions
  db_culturelink_id <- unique(db_culturelink$Date_ID)
  db_culturelink_list <- list()
  for(i in 1:length(db_culturelink_id)){
    culture <- data.frame(Date_ID = db_culturelink_id[i],
                          Culture = paste(db_culturelink["Date_ID" == db_culturelink_id[i],
                                                         "Culture_ID"],
                                          collapse = ", "))
    db_culturelink_list[[i]] <- culture
  }
  db_culture <- do.call(rbind, db_culturelink_list)

  db_reflinks <- data.table::fread(
    db_path[grepl("/dateRefLink.csv", db_path)],
    sep = ",",
    na.strings = "NULL",
    encoding = "UTF-8")

  # build chain of reflinks for shortref field
  # TODO:
  # - as of now a very slow implementation: how can that be done faster?
  # - individual references within bibtex: how to integrate propper short references instead of bibtex keys?
  db_reflinks_id <- unique(db_reflinks$Date_ID)
  db_ref_list <- list()
  for(i in 1:length(db_reflinks_id)){
    ref <- data.frame(Date_ID = db_reflinks_id[i],
                      shortref = paste(db_reflinks["Date_ID" == db_reflinks_id[i],
                                                   "BibTexKey"],
                                       collapse = ", "))
    db_ref_list[[i]] <- ref
  }
  db_ref <- do.call(rbind, db_ref_list)

  # build raw data based on schema

  # add in sites data
  db_raw <- merge(x = db_dates,
                  y = db_sites,
                  by = "Site_ID")

  # add in cultural attribution
  db_raw <- merge(x = db_raw,
                  y = db_culture,
                  by = "Date_ID",
                  all.x = T)

  # add in references
  db_raw <- merge(x = db_raw,
                  y = db_ref,
                  by = "Date_ID",
                  all.x = T)

  # remove files in file system
  unlink(temp)
  file.remove(db_path)

  medafricarbon <- db_raw %>%
    base::replace(., . == "", NA) %>%
    dplyr::transmute(
      method = .data[["Date_Method"]],
      labnr = .data[["Lab_ID"]],
      c14age = .data[["CRA"]],
      c14std = .data[["Error"]],
      site = .data[["Site_Name"]],
      sitetype = .data[["Site_Type"]],
      feature = .data[["Site_Context"]],
      #culture = .data[["Culture"]],
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
