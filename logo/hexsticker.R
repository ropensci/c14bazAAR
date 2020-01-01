library(hexSticker)
library(ggplot2)
library(emojifont)
library(sf)
library(geojsonsf)

ln <- geojson_sf("logo/ln.geojson")
pts <- geojson_sf("logo/pts.geojson")

load.fontawesome()
fa <- fontawesome(c('fa-table',
                    'fa-database'))

pts <- st_bind_cols(pts, data.frame(label = sample(fa,
                                                   nrow(pts),
                                                   replace = T)))

p <- ggplot() +
  geom_sf(data = ln,
          size = 1,
          color = "grey") +
  geom_sf_text(data = pts,
               aes(label = label),
               family = 'fontawesome-webfont',
               size = 10)  +
  geom_rect(
    aes(
      xmin = 28.96755,
      xmax = 28.96945,
      ymax = 41.01058,
      ymin = 41.0102,
    ),
    fill = "white",
    alpha = 0.7
  ) +
  theme_void()

hexSticker::sticker(subplot = p,
                    package="c14bazAAR",
                    p_color = "black",
                    p_size = 20,
                    p_family = "sans",
                    p_x = 1,
                    p_y = .73,
                    s_x = 1,
                    s_y = 1,
                    s_width = 2,
                    s_height = 2,
                    h_fill = "white",
                    h_color = "black",
                    h_size = 1,
                    filename = "man/figures/logo.png")
