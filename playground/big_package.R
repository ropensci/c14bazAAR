library(c14databases)
library(magrittr)

a1 <- get_all_dates()

a2 <- a1 %>% order_variables()

a3 <- a2 %>% rm_doubles()

a4 <- a3 %>% calibrate()

a5 <- a4 %>% thesaurify()

a6 <- a5 %>% estimate_spatial_quality()
