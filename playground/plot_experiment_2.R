radon <- c14bazAAR::get_c14data("all")

radon %<>% dplyr::filter(
  c14age < 10000
)

.pardefault <- par(no.readonly = TRUE)

layout(matrix(c(1,2,3,3), 2, 2, byrow = TRUE))

#### text ####
header <- as.character(format(radon)) %>%
  strsplit("\n") %>% unlist %>%
  sub("\t", "", .) %>%
  sub("\t\t", "\t", .) %>%
  trimws
plot(0, type = 'n', axes = FALSE, ann = FALSE, xlim = c(0, 1), ylim = c(length(header) + 1, 0))
for (i in 1:length(header)) {
  if (i == 1) {
    text(0, i, bquote(bold(.(header[i]))), adj = 0)
  } else {
    text(0, i, header[i], adj = 0)
  }
}

#### globe ####
par(mar = c(0, 0, 0, 0))
globe::globeearth(eye = list(mean(radon$lon, na.rm = T), mean(radon$lat, na.rm = T)))
globe::globepoints(
  loc = radon[,c("lon", "lat")],
  col = "red",
  cex = 0.01,
  pch = 20
)

#### histogram ####
par(mar = c(4.2, 4.2, 0, 0))
hist(
  radon$c14age,
  breaks = 100,
  main = NULL,
  xlim = rev(range(radon$c14age, na.rm = T)),
  xlab = "Uncalibrated Age BP in years (c14age)",
  ylab = "Amount of dates"
)

par(.pardefault)

