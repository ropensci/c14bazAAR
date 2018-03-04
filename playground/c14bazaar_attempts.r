## devtools::install_github("ISAAKiel/c14bazAAR")
library(c14bazAAR)
tmp <- get_aDRAC()
tmp

library(magrittr)


library(sf)
library(maps)
w <- st_as_sf(maps::map("world", plot = FALSE, fill = TRUE))

repUN <- ISOcodes::UN_M.49_Countries %>%
  tbl_df() %>%
  mutate(Name = gsub("^ ", "", Name))

tmp_sf <- tmp %>%
  filter(!is.na(lat)) %>%  
  st_as_sf(coords = c("lon","lat"),
           remove = FALSE,
           crs = 4326) %>%
  sf::st_join(y = w) %>%
  left_join(y = repUN, by = c(ID = "Name"))%>%
  mutate(check = case_when(country == ISO_Alpha_3 ~ "correct"))# %>%  
  #`class<-`(c("c14_date_list", class(.)))

problems <- tmp_sf %>%
  filter(is.na(check))

unique(problems$country)
unique(problems$country) %in% maps::iso3166$ISOname
unique(problems$country) %in% ISOcodes::UN_M.49_Countries$ISO_Alpha_3

## fuzzyjoin to achieve a check of the correct writing of the site names based on coordinates
library(fuzzyjoin)



