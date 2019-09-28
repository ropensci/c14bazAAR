a1 <- c14bazAAR::get_all_dates()

a2 <- a1 %>% dplyr::filter(
  !is.na(lat) & !is.na(lon)
  )

a3 <- a2 %>% c14bazAAR::as.sf() %>%
  sf::st_transform(crs = 25832) %>%
  sf::st_coordinates() %>%
  tibble::as_tibble()

world_wgs84 <- rnaturalearth::ne_coastline(110, "sf")

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

plot(europe_25832)

library(ggplot2)
library(ggridges)

a4 <- cbind(a2, a3) %>% tibble::as_tibble()

a4$Y_r <- a4$Y %>% round(-5)

a5 <- a4 %>% dplyr::mutate(
  c14age_groups = cut(
    c14age,
    breaks = quantile(a4$c14age, probs = c(0, 0.33, 0.66, 1)) %>% as.vector(),
    include.lowest = T
    labels = 1:3
  )
)

ggplot() +
  geom_sf(data = africa) +
  geom_density_ridges(
    data = a5 %>% dplyr::filter(c14age_groups == 1),
    mapping = aes(x = X, y = Y_r, group = Y_r),
    alpha = 0.3,
    color = "red",
    fill = "red",
    rel_min_height = 0.03
  ) +
  geom_density_ridges(
    data = a5 %>% dplyr::filter(c14age_groups == 2),
    mapping = aes(x = X, y = Y_r, group = Y_r),
    fill = "orange",
    alpha = 0.3,
    color = "white",
    rel_min_height = 0.03
  ) +
  geom_density_ridges(
    data = a5 %>% dplyr::filter(c14age_groups == 3),
    mapping = aes(x = X, y = Y_r, group = Y_r),
    fill = "yellow",
    alpha = 0.3,
    color = "white",
    rel_min_height = 0.03
  ) +
  xlim(min(a5$X) - 1000000, max(a5$X) + 1000000) +
  ylim(min(a5$Y) - 1000000, max(a5$Y) + 1000000)

