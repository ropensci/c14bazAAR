library(magrittr)

v <- readr::read_csv("data-raw/variable_reference_wide.csv")

v %>% tidyr::pivot_longer(
  cols = tidyselect::matches(colnames(v)[2:ncol(v)]),
  names_to = "database",
  values_to = "database_variable"
) %>%
  dplyr::arrange(database) %>%
  dplyr::filter(!c14bazAAR_variable %in% c("sourcedb", "sourcedb_version", "calprobdistr", "calrange", "sigma", "material_thes", "country_coord", "country_thes", "country_final", "coord_precision", "duplicate_group", "duplicate_remove_log")) %>%
  dplyr::filter(!(is.na(c14bazAAR_variable) & is.na(database_variable))) %>%
  readr::write_csv("data-raw/variable_reference_long.csv", na = "")
