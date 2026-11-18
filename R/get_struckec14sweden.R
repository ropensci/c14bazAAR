#' @rdname db_getter_backend
#' @export
get_struckec14sweden <- function(db_url = get_db_url("struckec14sweden")) {

  check_connection_to_url(db_url)

  # download and unzip data
  temp <- tempfile()
  utils::download.file(db_url, temp, quiet = TRUE)

  db_path <- utils::unzip(
    temp,
    file.path("StruckeC14_Sweden.csv"),
    exdir = tempdir()
  )

  # read data
  db_raw <- data.table::fread(
    db_path,
    sep = ";",
    encoding = "UTF-8",
    colClasses = "character",
    showProgress = FALSE
  )

  # remove files in file system
  unlink(temp)
  file.remove(db_path)

  # final data preparation
  struckec14sweden <- db_raw %>%

    # build shortref based on last five columns ()
    dplyr::mutate(
      shortref = do.call(
        paste,
        c(dplyr::pick((ncol(db_raw) - 4):(ncol(db_raw))), sep = " - "))) %>%
    base::replace(., . == "", NA) %>%
    dplyr::transmute(
      labnr = .data[["lab_id"]],
      c14age = .data[["c14_age_bp"]],
      c14std = .data[["c14_error"]],
      c13val = .data[["d13C"]],
      site = .data[["place_name"]],
      sitetype = .data[["site_type"]],
      material = .data[["material"]],
      species = .data[["species"]],
      region = .data[["landskap"]],
      lat = .data[["latitude"]],
      lon = .data[["longitude"]],
      shortref = .data[["shortref"]],
      comment = .data[["comment"]]
    ) %>%
    add_sourcedb_columns("struckec14sweden") %>%
    as.c14_date_list()

  return(struckec14sweden)
}
