library(hexSticker)
library(ggplot2)
library(emojifont)
library(osmdata)
library(sf)



x <- opq(bbox = c(28.967196, 41.009832,
                  28.969631, 41.011588)) %>%
  add_osm_feature(key = "highway",
                  value = "pedestrian") %>%
  osmdata_sf()






# 4 random locations
load.fontawesome()
fa <- fontawesome(c('fa-table',
                    'fa-database'))

pts <- st_sample(st_as_sfc(st_bbox(c(xmin = 28.9672,
                                     xmax = 28.9696,
                                     ymin = 41.0105,
                                     ymax = 41.0115))),
                 6,
                 type = "random")
pts <- st_bind_cols(pts, data.frame(label = sample(fa,
                                                   n,
                                                   replace = T)))

st_crs(pts) <- 4326

p <- ggplot() +
  geom_sf(data = x$osm_lines,
          size = 1,
          color = "grey") +
  geom_sf_text(data = pts,
               aes(label = label),
               family = 'fontawesome-webfont',
               size = 10) +
  coord_sf(xlim = c(28.967, 28.96975),
           ylim = c(41.00975, 41.01175)) +
  theme_void() +
  ggpubr::theme_transparent()

hexSticker::sticker(subplot = p,
                    package="c14bazAAR",
                    p_color = "black",
                    p_size = 24,
                    p_family = "sans",
                    p_x = 1,
                    p_y = .75,
                    s_x = 1,
                    s_y = 1.15,
                    s_width = 2,
                    s_height = 2,
                    h_fill = "white",
                    h_color = "black",
                    h_size = 1,
                    filename = "man/figures/logo.png")
