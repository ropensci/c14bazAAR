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

  unzip(temp, files="BDA-Table_Dates.xlsx", exdir=td, overwrite=TRUE)
  c14dates <- readxl::read_excel(paste0(td,"/BDA-Table_Dates.xlsx"))
  unzip(temp, files="BDA-Table_Occupations.xlsx", exdir=td, overwrite=TRUE)
  c14occupa <- readxl::read_excel(paste0(td,"/BDA-Table_Occupations.xlsx"))
  unzip(temp, files="BDA-Table_Sites.xlsx", exdir=td, overwrite=TRUE)
  c14sites <- readxl::read_excel(paste0(td,"/BDA-Table_Sites.xlsx"))

  bda <- c14dates %>%
    dplyr::left_join(c14sites, by = c("id_site_associé" = "id_sites")) %>%
    dplyr::left_join(c14occupa, by = c("id_occupation_liée" = "id_occupations_2019")) %>%
    dplyr::transmute(
      method = .data[["Méthode"]],
      labnr = .data[["Code_labo"]],
      c14age = .data[["Mesure"]],
      c14std = .data[["Ecartype"]],
      c13val = .data[["delta13"]],
      site = .data[["Nom_site"]],
      sitetype = .data[["Nature_site"]],
      feature = .data[["num_couche"]],
      period = .data[["période"]],
      culture = .data[["culture"]],
      material = .data[["Matériel_daté"]],
      species = .data[["Matériel_daté_précision"]],
      region = .data[["Région"]],
      country = .data[["Pays"]],
      lat = .data[["Latitude"]],
      lon = .data[["Longitude"]],
      shortref = .data[["Ref_biblio"]],
      comment = .data[["Fiabilité.x"]],
    ) %>% dplyr::mutate(
      sourcedb = "bda",
      sourcedb_version = get_db_version("bda")
    ) %>%
    as.c14_date_list()

  return(bda)
}
