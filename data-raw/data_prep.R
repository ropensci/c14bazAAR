country_thesaurus <- readr::read_csv(
  "data-raw/country_thesaurus.csv",
)
devtools::use_data(country_thesaurus, overwrite = TRUE)

material_thesaurus <- readr::read_csv(
  "data-raw/material_thesaurus.csv",
)
devtools::use_data(material_thesaurus, overwrite = TRUE)
