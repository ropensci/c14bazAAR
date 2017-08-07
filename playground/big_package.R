library(c14databases)
library(magrittr)

a1 <- get_all_dates()

a2 <- a1 %>% order_variables()

a3 <- a2 %>% rm_doubles()

a4 <- a3 %>% calibrate()

a5 <- a4 %>% thesaurify()

a6 <- a5 %>% estimate_spatial_quality()

a7 <- a6 %>% order_variables()

save(a1, a2, a3, a4, a5, a6, a7, file = "playground/dates.RData")

a7 %>%
  dplyr::filter(
    is.na(country_thes) & !is.na(country)
  ) -> hu
