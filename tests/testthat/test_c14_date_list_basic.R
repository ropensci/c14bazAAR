context("basic c14_date_list functions")

#### as ####

test_that("as.c14_date_list errors with wrong input", {
  expect_error(
    as.c14_date_list(
      "test"
    ),
    NULL
  )
  expect_error(
    as.c14_date_list(
      data.frame(c14age = c(2000, 2500), cheese = c(20, 30))
    ),
    NULL
  )
})

test_that("as.c14_date_list gives back a c14_date_list with correct input", {
  expect_s3_class(
    as.c14_date_list(
      data.frame(c14age = c(2000, 2500), c14std = c(20, 30))
    ),
    "c14_date_list"
  )
})

test_that("as.c14_date_list ignores additional columns", {
  expect_equal(
    colnames(as.c14_date_list(
      data.frame(c14age = c(2000, 2500), c14std = c(20, 30), cheese = c(1,2))
    )),
    c("c14age", "c14std", "cheese")
  )
})

#### is ####

test_that("is.c14_date_list identifies a c14_date_list correctly", {
  expect_true(
    is.c14_date_list(example_c14_date_list)
  )
})

test_that("is.c14_date_list identifies other objects correctly", {
  expect_false(
    is.c14_date_list(3)
  )
})

#### format ####

test_that("format.c14_date_list returns an invisible output", {
  expect_invisible(
    format(example_c14_date_list)
  )
})

#### print ####

test_that("print.c14_date_list uses format to print a c14_date_list in the intended way", {
  expect_gt(
    length(capture.output(print(example_c14_date_list))),
    10
  )
  expect_equal(
    c("\tRadiocarbon date list", "\tdates: 9", "\tsites: 4", "\tcountries: 5"),
    capture.output(print(example_c14_date_list))[1:4]
  )
})

#### plot ####

test_that("a file produced from plot.c14_date_list has approximately the correct size", {

  testfile <- tempfile()
  png(testfile)
  plot(example_c14_date_list)
  dev.off()

  expect_equal(
    file.size(testfile),
    # hard coded file size
    38000,
    tolerance = 1000
  )

})
