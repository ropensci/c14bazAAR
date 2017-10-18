library(c14bazAAR)
library(magrittr)

a1 <- get_all_dates()

a2 <- a1 %>% order_variables()

a3 <- a2 %>% rm_doubles()
#a3 <- a2 %>% rm_doubles(mark = T)

a4 <- a3 %>% calibrate()

a5 <- a4 %>% thesaurify()

a6 <- a5 %>% estimate_spatial_quality()

a7 <- a6 %>% order_variables()

save(a1, a2, a3, a4, a5, a6, a7, file = "playground/dates.RData")

a8 <- a7 %>%
  dplyr::mutate_if(is.character, dplyr::funs(iconv(., "UTF-8", "UTF-8", sub = '')))

indicators_material <- c("grain", "gerste", "wheat", "bean", "cereal", "linsen", "lenses")
indicators_species <- c("ovis", "capra")

hu <- a8 %>%
  dplyr::filter(
    .,
    grepl(paste(indicators_material, collapse = "|"), material, ignore.case = TRUE) |
      grepl(paste(indicators_species, collapse = "|"), species, ignore.case = TRUE)
  )


library(mapview)
library(sp)

mu <- hu
mu <- mu %>% dplyr::filter(
  !is.na(lat) & !is.na(lon)
)

sp::coordinates(mu) <- ~lon+lat
sp::proj4string(mu) <- "+proj=longlat +datum=WGS84 +no_defs"

mapView(mu)
