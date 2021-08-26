# Summary Figure for README

library(c14bazAAR)
library(cowplot)
library(ggplot2)
library(ggthemes)
library(rnaturalearth)
library(sf)
library(tidyr)

c14.data <- c14bazAAR::get_c14data(databases = "all")

c14.sf <- st_as_sf(c14.data, coords = c("lon", "lat"), crs = 4326, na.fail = FALSE)
# lables for facet plot
c14.n <- as.data.frame(table(c14.data$sourcedb))
c14.n$lab <- paste0(c14.n$Var1,"\n(", c14.n$Freq, " dates)")
c14.lab <- c14.n$lab
names(c14.lab) <- c14.n$Var1
land <- ne_download(scale = "small", type = 'land', category = 'physical', returnclass = "sf")

# map
c14.map <- ggplot(land) +
  geom_sf(fill = "lightgrey", color = NA) +
  geom_sf(data = c14.sf, aes(fill = sourcedb),
          shape = 21,
          color = "white") +
  facet_wrap(~ sourcedb,
             ncol = 4) +
  coord_sf(crs = st_crs('+proj=moll')) +
  theme_bw() +
  theme(legend.position = "none",
        panel.border = element_blank(),
        strip.background = element_rect(fill="white"))

# historgram
c14.hist <- ggplot(data = c14.data,
                  aes(x = c14age,
                      fill = sourcedb)) +
  geom_histogram(color = "white",
                 binwidth = 500) +
  geom_hline(yintercept = 0, color = "grey") +
  facet_grid(sourcedb ~ .,
             scales = "free_y",
             labeller = labeller(sourcedb = c14.lab)) +
  scale_x_reverse("uncal BP", limits = c(40000, 0),
                  expand = c(0,0)) +
  scale_y_continuous("", expand = c(0,0)) +
  theme_bw() +
  theme(axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        legend.position = "none",
        strip.background = element_rect(fill="white"),
        strip.text.y = element_text(angle = 0))

p <- plot_grid(c14.map, c14.hist,
               labels = "",
               align = "h",
               rel_widths = c(3, 1.3))

ggsave("man/figures/README_map_figure.jpeg", p, width = 12, height = 8)
