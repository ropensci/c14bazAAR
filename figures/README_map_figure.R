# Summary Figure for README

library(ggplot2)
library(magrittr)
library(sf)

# download data
options(timeout = 1000)
c14.data <- c14bazAAR::get_c14data(databases = "all")

# order according to median ages
c14.data$sourcedb <- stats::reorder(c14.data$sourcedb, c14.data$c14age, function(x) {median(x, na.rm = T)})

# transform to spatial data
c14.sf <- sf::st_as_sf(c14.data, coords = c("lon", "lat"), crs = 4326, na.fail = FALSE)

# labels for histogram plot
c14.n <- as.data.frame(table(c14.data$sourcedb))
c14.n$lab <- paste0(c14.n$Var1,"\n", format(c14.n$Freq, big.mark = ","), " dates")
c14.lab <- c14.n$lab
names(c14.lab) <- c14.n$Var1
# prepare histogram annotation
arrowanno <- c14.data %>%
  dplyr::filter(c14age > 15000) %>%
  dplyr::group_by(sourcedb) %>%
  dplyr::summarise(sum = dplyr::n())

# prepare world land area
land <- rnaturalearthdata::countries110
land_moll <- land %>%
  sf::st_break_antimeridian() %>%
  sf::st_transform('+proj=moll') %>%
  sf::st_make_valid() %>%
  sf::st_union()

# prepare world outline
make_bbox_polygon <- function(bbox, n = 200, crs_from = 4326) {
  xmin <- -180; xmax <- 180-0.00001
  ymin <- bbox[["ymin"]]; ymax <- bbox[["ymax"]]
  bottom <- cbind(seq(xmin, xmax, length.out = n), rep(ymin, n))
  right  <- cbind(rep(xmax, n), seq(ymin, ymax, length.out = n))
  top    <- cbind(seq(xmax, xmin, length.out = n), rep(ymax, n))
  left   <- cbind(rep(xmin, n), seq(ymax, ymin, length.out = n))
  coords <- rbind(bottom, right[-1, ], top[-1, ], left[-c(1, n), ], bottom[1, ])
  sf::st_polygon(list(coords)) %>% sf::st_sfc(crs = crs_from)
}
world_box_moll <- make_bbox_polygon(sf::st_bbox(land), n = 200, crs_from = 4326) %>%
  sf::st_transform('+proj=moll')

# map
c14.map <- ggplot() +
  geom_sf(data = land_moll, linewidth = 0.3) +
  geom_sf(data = world_box_moll, linewidth = 0.3, fill = NA) +
  geom_sf(
    data = c14.sf,# %>% dplyr::filter(sourcedb == "14sea"),
    aes(fill = sourcedb),
    shape = 21,
    color = "black"
  ) +
  facet_wrap(~ sourcedb, ncol = 3) +
  coord_sf(crs = sf::st_crs('+proj=moll')) +
  theme_bw() +
  theme(
    legend.position = "none",
    panel.border = element_blank(),
    strip.background = element_rect(fill="white"),
    strip.text = element_text(margin = margin(0.1,0,0.1,0, "cm")),
    panel.grid.major = element_line(color="grey90"),
    axis.text = element_blank(),
    axis.ticks = element_blank()
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
  align = "h", axis = "lr",
  rel_widths = c(3, 1.7)
)

ggsave("man/figures/README_map_figure.jpeg", p, width = 9, height = 12, bg = "white")
