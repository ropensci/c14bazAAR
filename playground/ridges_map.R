a1 <- c14bazAAR::get_aDRAC()

a2 <- a1 %>% dplyr::filter(
  !is.na(lat) & !is.na(lon),
  c14age < 15000
  )

a3 <- a2 %>% c14bazAAR::as.sf() %>%
  sf::st_transform(crs = 4049) %>%
  sf::st_coordinates() %>%
  tibble::as_tibble()

data("countriesHigh", package = "rworldxtra")
africa_sp <- countriesHigh[(countriesHigh$REGION == "Africa") %>% tidyr::replace_na(FALSE), ]
africa <- africa_sp %>%
  sf::st_as_sf() %>%
  sf::st_transform(crs = 4049) %>%
  dplyr::select(ADMIN)

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

