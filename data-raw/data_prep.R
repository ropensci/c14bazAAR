#### country_thesaurus ####

country_thesaurus <- readr::read_csv(
  "data-raw/country_thesaurus.csv",
  na = c("NA")
)
usethis::use_data(country_thesaurus, overwrite = TRUE)

#### material_thesaurus ####

material_thesaurus <- readr::read_csv(
  "data-raw/material_thesaurus.csv",
  na = c("NA")
)
usethis::use_data(material_thesaurus, overwrite = TRUE)

#### variable_reference ####

variable_reference <- readr::read_csv(
  "data-raw/variable_reference.csv",
  na = c("NA")
)
usethis::use_data(variable_reference, overwrite = TRUE)

#### example_c14_date_list ####

all_dates <- c14bazAAR::get_all_dates()
example_c14_date_list <- all_dates %>%
  dplyr::sample_n(1000) %>%
  dplyr::mutate_if(is.character, function(x) {gsub("[^\x20-\x7E]", "", x)})
usethis::use_data(example_c14_date_list, overwrite = TRUE)

