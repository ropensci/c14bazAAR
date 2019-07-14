library(c14bazAAR)
library(ggplot2)

aDRAC <- get_aDRAC()

# Radiocarbon dating

Batalimo <- aDRAC %>%
  dplyr::filter(site == "Batalimo")

## Ridgeplots of density distributions

Batalimo_calibrated <- Batalimo %>%
  calibrate(choices = "calprobdistr")

Batalimo_calibrated$calprobdistr

Batalimo_cal_dens <- Batalimo_calibrated %>% tidyr::unnest()

Batalimo_cal_dens %>%
  ggplot() +
  ggridges::geom_ridgeline(
    aes(-calage + 1950, labnr, height = density),
    scale = 300
  ) +
  xlab("age calBC/calAD") +
  ylab("dates")

## Calcurve plot

Batalimo_calibrated <- Batalimo %>%
  calibrate(choices = "calrange")

Batalimo_cal_range <- Batalimo_calibrated %>% tidyr::unnest()

load(system.file('data/intcal13.rda', package = 'Bchron'))

ggplot() +
  geom_line(
    data = intcal13,
    mapping = aes(x = -V1 + 1950, y = -V2 + 1950)
  ) +
  geom_errorbarh(
    data = Batalimo_cal_range,
    mapping = aes(y = -c14age + 1950, xmin = -to + 1950, xmax = -from + 1950)
  ) +
  xlim(-1000, 1000) +
  ylim(1000, -1000) +
  xlab("age calBC/calAD") +
  ylab("uncalibrated age BC/AD")

# Map

Moga_spatial <- aDRAC %>%
  as.sf %>%
  dplyr::filter(grepl("Moga 2008", data.shortref)) %>%
  dplyr::group_by(data.site) %>%
  dplyr::summarise()

## interactive

Moga_spatial %>% mapview::mapview()

## static

countries <- rnaturalearth::ne_countries() %>% sf::st_as_sf()

ggplot() +
  geom_sf(data = countries) +
  geom_sf(data = Moga_spatial) +
  geom_sf_text(data = countries, mapping = aes(label = formal_en)) +
  coord_sf(xlim = c(10, 30), ylim = c(0, 15))
