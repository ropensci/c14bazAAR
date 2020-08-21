db_url <- "https://github.com/eehh-stanford/price2020/raw/master/MesoRAD-v.1.1_FINAL_no_locations.xlsx"

# download data
temp <- tempfile(fileext = ".xlsx")
utils::download.file(url = db_url, destfile = temp, mode = "wb", quiet = TRUE)

head(
  openxlsx::read.xlsx(
    temp,
    sheet = 1)
)

head(xlsx::read.xlsx(
  temp,
  sheetIndex = 1)
)
