#' @rdname db_getter_backend
#' @export
get_nerd <- function(db_url = get_db_url("nerd")) {

  check_connection_to_url(db_url)

  nerd <- db_url %>%
    data.table::fread(
      drop = c(
        "DateID",
        "SiteID",
        "LocQual"
      ),
      colClasses = "character",
      showProgress = FALSE,
      na.strings = c("datatable.na.strings", "", "NA")
    ) %>%
    dplyr::transmute(
      labnr = paste_ignore_na(.data[["LabID"]], .data[["OthLabID"]]),
      c14age = .data[["CRA"]],
      c14std = .data[["Error"]],
      c13val = .data[["DC13"]],
      material = .data[["Material"]],
      species = .data[["Species"]],
      site = .data[["SiteName"]],
      sitetype = .data[["SiteType"]],
      country = .data[["Country"]],
      feature = .data[["SiteContext"]],
      lat = .data[["Latitude"]],
      lon = .data[["Longitude"]],
      comment = paste_ignore_na(.data[["Problems"]], .data[["Comments"]], sep = " "),
      shortref = .data[["Source"]]
    ) %>%
    add_sourcedb_columns("nerd") %>%
    as.c14_date_list()

  return(nerd)
}
