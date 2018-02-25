#### country_thesaurus ####

country_thesaurus <- readr::read_csv(
  "data-raw/country_thesaurus.csv",
  na = c("NA")
)
devtools::use_data(country_thesaurus, overwrite = TRUE)

#### material_thesaurus ####

material_thesaurus <- readr::read_csv(
  "data-raw/material_thesaurus.csv",
  na = c("NA")
)
devtools::use_data(material_thesaurus, overwrite = TRUE)

#### variable_reference ####

variable_reference <- readr::read_csv(
  "data-raw/variable_reference.csv",
  na = c("NA")
)
devtools::use_data(material_thesaurus, overwrite = TRUE)

#### example_c14_date_list ####

example_c14_date_list <- c14bazAAR::get_all_dates() %>%
  dplyr::sample_n(500) %>%
  as.c14_date_list()
devtools::use_data(example_c14_date_list, overwrite = TRUE)

