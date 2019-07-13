library(c14bazAAR)
library(ggplot2)
library(ggridges)

aDRAC <- get_aDRAC()

Batalimo <- aDRAC %>%
  dplyr::filter(site == "Batalimo")

Batalimo_calibrated <- Batalimo %>%
  calibrate(choices = "calprobdistr")

Batalimo_calibrated$calprobdistr

Batalimo_caldens <- Batalimo_calibrated %>% tidyr::unnest()

Batalimo_caldens$labnr <- factor(Batalimo_caldens$labnr, levels = Batalimo %>% dplyr::arrange(dplyr::desc(c14age)) %$% labnr)

Batalimo_caldens %>%
  ggplot() +
  geom_ridgeline(
    aes(-calage + 1950, labnr, height = density),
    scale = 300
  ) +
  xlab("age calBC/calAD") +
  ylab("dates")

