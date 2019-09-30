library(ggplot2)
library(ggridges)s

world_wgs84 <- rnaturalearth::ne_coastline(50, "sf")

border_wgs84 <-
  sf::st_polygon(list(rbind(
    c(-16, 36),
    c(34, 36),
    c(34, 63),
    c(-16, 63),
    c(-16, 36)
  ))) %>%
  sf::st_sfc(crs = sf::st_crs(world_wgs84))
  #sf::st_transform(crs = 25832) %>%
  #sf::st_buffer(dist = 0)

europe_wgs84 <- world_wgs84 %>%
  sf::st_crop(border_wgs84)

europe_25832 <- europe_wgs84 %>%
  sf::st_transform(crs = 25832)

st_envelope = function(x) sf::st_as_sfc(sf::st_bbox(x))
border_europe_25832 <- europe_25832 %>%
  st_envelope()

plot(europe_25832)

a1 <- c14bazAAR::get_all_dates()

a2 <- a1 %>% dplyr::filter(
  !is.na(lat) & !is.na(lon), !is.na(c14age)
)

a2b <- a2 %>% c14bazAAR::as.sf() %>%
  sf::st_transform(crs = 25832) %>%
  sf::st_crop(border_europe_25832)

a3 <- a2b %>%
  dplyr::mutate(
    X = sf::st_coordinates(.)[,1],
    Y = sf::st_coordinates(.)[,2],
    X_r = round(X, -4),
    Y_r = round(Y, -4)
  ) %>%
  tibble::as_tibble()

colnames(a3) <- gsub("data.", "", colnames(a3))

a4 <- a3 %>%
  dplyr::group_by(
    X_r, Y_r
  ) %>%
  dplyr::summarise(
    age_max = max(c14age),
    age_min = min(c14age),
    age_range = abs(age_max - age_min) * 2,
    n = dplyr::n() * 200
  ) %>%
  dplyr::ungroup()

a5 <- a4 %>% tidyr::complete(
  X_r = tidyr::full_seq(X_r, 10000), Y_r = tidyr::full_seq(Y_r, 10000), fill = list(
    age_max = 0, age_min = 0, age_range = 0, n = 0
  )
)

a6 <- a5 %>% tidyr::pivot_longer(
  age_max:n,
  "type"
)

ggplot() +
  geom_sf(data = europe_25832) +
  geom_ridgeline(
    data = a6,
    mapping = aes(x = X_r, y = Y_r, group = Y_r, height = value),
    alpha = 0.3,
    color = "black",
    fill = "green",
    scale = 5,
    size = 0.05
  ) +
  facet_wrap(~type) +
  theme_bw()

