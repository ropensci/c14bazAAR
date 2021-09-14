# Summary Figure for README

library(ggplot2)
library(magrittr)
library(sf)

# download data
c14.data <- c14bazAAR::get_c14data(databases = "all")

# order according to median ages
c14.data$sourcedb <- stats::reorder(c14.data$sourcedb, c14.data$c14age, function(x) {median(x, na.rm = T)})

# transform to spatial data
c14.sf <- sf::st_as_sf(c14.data, coords = c("lon", "lat"), crs = 4326, na.fail = FALSE)

# labels for histogram plot
c14.n <- as.data.frame(table(c14.data$sourcedb))
c14.n$lab <- paste0(c14.n$Var1,"\n(", c14.n$Freq, " dates)")
c14.lab <- c14.n$lab
names(c14.lab) <- c14.n$Var1
# prepare histogram annotation
arrowanno <- c14.data %>%
  dplyr::filter(c14age > 15000) %>%
  dplyr::group_by(sourcedb) %>%
  dplyr::summarise(sum = dplyr::n())

land <- sf::st_as_sf(rnaturalearthdata::coastline110)

# map
c14.map <- ggplot() +
  geom_sf(data = land, color = "grey60") +
  geom_sf(
    data = c14.sf,
    aes(fill = sourcedb),
    shape = 21,
    color = "black"
  ) +
  facet_wrap(~ sourcedb, ncol = 4) +
  coord_sf(crs = st_crs('+proj=moll')) +
  theme_bw() +
  theme(
    legend.position = "none",
    panel.border = element_blank(),
    strip.background = element_rect(fill="white"),
    panel.grid.major = element_line(color="grey90")
  )

# historgram
c14.hist <- ggplot() +
  geom_histogram(
    data = c14.data,
    aes(x = c14age, fill = sourcedb),
    color = "white",
    binwidth = 200
  ) +
  geom_hline(
    yintercept = 0, color = "grey"
  ) +
  geom_text(
    data = arrowanno,
    aes(x = Inf, y = Inf, size = sum, color = sourcedb),
    label = "\u25c4",
    vjust = "inward", hjust = "inward"
  ) +
  facet_grid(
    sourcedb ~ .,
    scales = "free_y",
    labeller = labeller(sourcedb = c14.lab)
  ) +
  scale_x_reverse(
    "years uncal BP",
    limits = c(15000, 0),
    expand = c(0,0)
  ) +
  scale_y_continuous("", expand = c(0,0)) +
  scale_size_continuous(range = c(2, 5)) +
  theme_bw() +
  theme(
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank(),
    legend.position = "none",
    strip.background = element_rect(fill="white"),
    strip.text.y = element_text(angle = 0)
  )

p <- cowplot::plot_grid(
  c14.map, c14.hist,
  labels = "",
  align = "h",
  rel_widths = c(3, 1.3)
)

ggsave("man/figures/README_map_figure.jpeg", p, width = 12, height = 8, bg = "white")
