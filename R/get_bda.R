#' @rdname db_getter_backend
#' @export
get_bda <- function(db_url = get_db_url("bda")) {

  check_connection_to_url(db_url)

  temp <- tempfile(fileext = ".zip")
  td <- tempdir()

  utils::download.file(
    db_url,
    temp,
    mode="wb",
    quiet = TRUE
  )

  utils::unzip(temp, files="BDA-Table_Dates.xlsx", exdir=td, overwrite=TRUE)
  c14dates <- readxl::read_excel(
    paste0(td,"/BDA-Table_Dates.xlsx"),
    col_types = "text"
  )
  utils::unzip(temp, files="BDA-Table_Occupations.xlsx", exdir=td, overwrite=TRUE)
  c14occupa <- readxl::read_excel(
    paste0(td,"/BDA-Table_Occupations.xlsx"),
    col_types = "text"
  )
  utils::unzip(temp, files="BDA-Table_Sites.xlsx", exdir=td, overwrite=TRUE)
  c14sites <- readxl::read_excel(
    paste0(td,"/BDA-Table_Sites.xlsx"),
    col_types = "text"
  )

  names(c14dates) <- gsub("\u00E9", "e", names(c14dates))
  names(c14occupa) <- gsub("\u00E9", "e", names(c14occupa))
  names(c14sites) <- gsub("\u00E9", "e", names(c14sites))

  c14merged <- c14dates %>%
    dplyr::left_join(
      c14sites, by = c("id_site_associe" = "id_sites")
    ) %>%
    dplyr::left_join(
      c14occupa, by = c("id_occupation_liee" = "id_occupations_2019"),
      na_matches = "never"
    )

  # sum(duplicated(c14merged$Code_labo))

  bda <- c14merged %>%
    dplyr::transmute(
      method = .data[["Methode"]],
      labnr = .data[["Code_labo"]],
      c14age = .data[["Mesure"]],
      c14std = .data[["Ecartype"]],
      c13val = .data[["delta13"]],
      site = .data[["Nom_site"]],
      sitetype = .data[["Nature_site"]],
      feature = .data[["num_couche"]],
      period = .data[["periode"]],
      culture = .data[["culture"]],
      material = .data[["Materiel_date"]],
      species = .data[["Materiel_date_precision"]],
      region = .data[["Region"]],
      country = .data[["Pays"]],
      lat = .data[["Latitude"]],
      lon = .data[["Longitude"]],
      shortref = .data[["Ref_biblio"]],
      comment = .data[["Fiabilite.x"]],
    ) %>% dplyr::mutate(
      sourcedb = "bda",
      sourcedb_version = get_db_version("bda")
    ) %>%
    as.c14_date_list()

  # sum(duplicated(bda$labnr))

  # the duplicates come from a cleaning of labnrs in as.c14_date_list()
  # bda %>%
  #   dplyr::mutate(labnr_old = c14merged$Code_labo, .after = "labnr") %>%
  #   dplyr::arrange(labnr) %>% dplyr::group_by(labnr) %>%
  #   dplyr::filter(dplyr::n() > 1) %>% View()

  return(bda)
}
