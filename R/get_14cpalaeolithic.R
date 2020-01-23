#' @rdname db_getter_backend
#' @export
get_14cpalaeolithic <- function(db_url = get_db_url("14cpalaeolithic")) {

  check_connection_to_url(db_url)

  db_url <-"https://ees.kuleuven.be/geography/projects/14c-palaeolithic/radiocarbon-palaeolithic-europe-database-v26-extract.xlsx"


  # download data
  temp <- tempfile(fileext=".xlsx")

  utils::download.file(url = db_url, destfile = temp, mode="wb")

  # Read each file and write it to csv
  lapply(temp, function(f) {
    df = openxlsx::read.xlsx(f, sheet=1)
    utils::write.csv(df, gsub("xlsx", "csv", f), row.names=FALSE)
  })

  db_path_xlsx <- unlist(strsplit(temp, split = ".", fixed = TRUE))
  db_path_csv <- paste(db_path_xlsx[1], ".csv", sep = "")

  # read data
  db_raw <- data.table::fread(
    db_path_csv,
    sep = ",",
    encoding = "UTF-8",
    colClasses = "character",
    showProgress = FALSE
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
      country = .data[["Country"]],
      lat = .data[["coord_lat"]],
      lon = .data[["coord_long"]],
      shortref = .data[["bibliogr_ref"]]
    ) %>% dplyr::mutate(
      sourcedb = "14cpalaeolithic",
      sourcedb_version = get_db_version("14cpalaeolithic")
    ) %>%
    as.c14_date_list()


  return(c14palaeolithic)
}
