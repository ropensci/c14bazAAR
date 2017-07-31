country_thesaurus <- read.table(
  "data-raw/country_thesaurus.csv",
  header = TRUE,
  stringsAsFactors = FALSE,
  sep = ","
)
devtools::use_data(country_thesaurus, overwrite = TRUE)

material_thesaurus <- read.table(
  "data-raw/material_thesaurus.csv",
  header = TRUE,
  stringsAsFactors = FALSE,
  sep = ","
)
devtools::use_data(material_thesaurus, overwrite = TRUE)
