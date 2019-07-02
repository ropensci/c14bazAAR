#### example_c14_date_list ####

all_dates <- c14bazAAR::get_all_dates()
example_c14_date_list <- all_dates %>%
  dplyr::sample_n(1000) %>%
  dplyr::mutate_if(is.character, function(x) {gsub("[^\x20-\x7E]", "", x)})
usethis::use_data(example_c14_date_list, overwrite = TRUE)

