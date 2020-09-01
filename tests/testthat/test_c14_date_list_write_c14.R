context("write c14_date_lists to file system")

csv_file <- tempfile()
csv_file2 <- tempfile()
xlsx_file <- tempfile()

test_that("writing to file works without errors", {
  expect_silent(
    write_c14(example_c14_date_list, file = csv_file, format = "csv")
  )
  expect_silent(
    write_c14(example_c14_date_list, path = xlsx_file, format = "xlsx")
  )
})

test_that("list columns are correctly recognized and a message created", {
  expect_message(
    write_c14(calibrate(example_c14_date_list), file = csv_file2, format = "csv"),
    "The following list columns were removed: calrange. Unnest them to keep them in the output table."
  )
})

csv_read <- read.csv(csv_file, stringsAsFactors = F, row.names = 1)
xlsx_read <- readxl::read_excel(xlsx_file)

test_that("written files are generally fine", {
  # result dimensions
  expect_equal(
    nrow(csv_read),
    9
  )
  expect_equal(
    nrow(xlsx_read),
    9
  )
  expect_equal(
    ncol(csv_read),
    19
  )
  expect_equal(
    ncol(xlsx_read),
    19
  )
  # content
  expect_equal(
    csv_read$labnr[3],
    "lab-3"
  )
  expect_equal(
    xlsx_read$labnr[3],
    "lab-3"
  )
})
