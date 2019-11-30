library(ggplot2)

positions <- tibble::tribble(
  ~id, ~labnr, ~other, ~age,
  1, "AAR-1847", "...", "4780±100",
  2, "ALG-33", "...", "6600±250",
  3, "K-1983", "...", "4160±100",
  4, "OxA-3197", "...", "2450±70",
  5, "...", "...", "... ± ..."
)

p <- positions %>%
  ggplot() +
  geom_text(
    aes(x = 6, y = -id, label = labnr),
    color = "black",
    size = 8
  ) +
  geom_vline(
    aes(xintercept = 8.5),
    size = 0.3,
    color = "black"
  ) +
  geom_text(
    aes(x = 10, y = -id, label = other),
    color = "black",
    size = 10
  ) +
  geom_vline(
    aes(xintercept = 11.5),
    size = 0.3,
    color = "black"
  ) +
  geom_text(
    aes(x = 14, y = -id, label = age),
    color = "black",
    size = 8
  ) +
  xlim(4, 16) +
  ylim(-5.2, -0.8) +
  theme_void() +
  ggpubr::theme_transparent()

hexSticker::sticker(
  subplot = p,
  package = "c14bazAAR",
  p_color = "black",
  p_size = 24,
  p_family = "sans",
  p_x = 1,
  p_y = 0.65,
  s_x = 1,
  s_y = 1.15,
  s_width = 1.8,
  s_height = 0.9,
  h_fill = "white",
  h_color = "black",
  h_size = 1,
  filename = "inst/image/logo.png"
)

