library(magrittr)

#### general db info ####

db_info_table <- data.table::fread(
  "data-raw/db_info_table.csv",
  colClasses = "character",
  encoding = "UTF-8",
  showProgress = FALSE,
  na.strings = c("datatable.na.strings", "", "NA")
) %>% tibble::tibble()

usethis::use_data(db_info_table, overwrite = T)

#### example_c14_date_list ####

part_1 <- tibble::tribble(
  ~sourcedb, ~method, ~labnr, ~c14age, ~c14std, ~c13val, ~site,    ~sitetype,      ~feature,
  "A",       "Conv", "lab-1", 1000,    20,      -15,     "Site A", "Burial mound", "Grave 1",
  "A",       "Conv", "lab-2", 2000,    30,      -20,     "Site A",  NA,             "Grave 2",
  "A",       "AMS",  "lab-3", 3000,    40,      -25,     "Site B", "settlement",   NA,
  "B",       NA,     "lab-4", 4000,    50,      -15,     "Site B", "settlement",   "House 5",
  "B",       "AMS",  "lab-5", 5000,    50,      -20,     "Site C", "settlement",   NA,
  "B",       "AMS",  "lab-6", 6000,    60,      -25,     "Site C", "settlement",   "Oven 4",
  "C",       "AMS",  "lab-7", 7000,    70,      -15,     "Site D", "Camp",         "Hut 2",
  "C",       "AMS",  "lab-8", 8000,    80,      -20,     "Site D", "Camp",         "Hut 2",
  "C",       "AMS",  "lab-9", 9000,    90,      -25,     "Site D", "Camp",         "Hut 3"
)

part_2 <- tibble::tribble(
  ~period,            ~culture,             ~material,            ~species,         ~region,
  NA,                 "Fibula group A",     "Human bone",         NA,               "Swabia",
  "Bronze Age",       "Burial group B",     NA,                   NA,               "Swabia",
  "Bronze Age",       "Burial group C",     "charred fruit",      "Malus",          "Thuringia",
  "Late Neolithic",   NA,                   "Bone (Bos)",         NA,               "Thuringia",
  NA,                 "Pottery group E",    "Scattered charcoal", NA,               NA,
  "Early Neolithic",  "Pottery group F",    "Bone (Bos)",         "Bos",            NA,
  "Mesolithic",       "Stone tool group G", "Red deer antler",    "Cervus elaphus", "Dithmarschen",
  "Mesolithic",       "Stone tool group G", "Wood charcoal",      "Salix",          "Dithmarschen",
  "Mesolithic",       "Stone tool group I", "charcoal",           "Quercus",        "Dithmarschen"
)

part_3 <- tibble::tribble(
  ~country,  ~lat, ~lon, ~shortref,                   ~comment,
  "Germany", 48.3, 8.5,  "Gerinde 1969, p. 12",       NA,
  "Germany", 48.3, 8.5,  "Gerinde 1969, p. 13",       "Context unreliable",
  "Germany", 51.1, 11.3, "Hugnot 2011, p. 63",        NA,
  "Germanx", NA,   NA,   "Hugnot 2011, p. 63",        NA,
  NA,        47.4, 7.7,  "Schiefer 2004, Anhang I",   NA,
  NA,        47.4, 7.7,  "Schiefer 2004, Anhang I",   NA,
  "Austria", 54.1, 9.2,  "Bahlsen 1992; Traver 1995", "Dithmarschen is in Austria?",
  "Austria", 54.1, 9.2,  "Bahlsen 1992; Traver 1995", NA,
  "Sustria", 54.1, 9.2,  "Bahlsen 1992; Traver 1995", NA
)

example_c14_date_list <- cbind(part_1, part_2, part_3) %>%
  as.c14_date_list()

usethis::use_data(example_c14_date_list, overwrite = TRUE)

