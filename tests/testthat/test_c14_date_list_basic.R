context("basic c14_date_list functions")

#### as ####

test_that("as.c14_date_list gives back a c14_date_list with correct input", {
  expect_s3_class(
    as.c14_date_list(
      data.frame(c14age = c(2000, 2500), c14std = c(20, 30))
    ),
    "c14_date_list"
  )
})

test_that("as.c14_date_list errors with wrong input", {
  expect_error(
    as.c14_date_list(
      data.frame(c14age = c(2000, 2500), cheese = c(20, 30))
    ),
    NULL
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

#### format & print ####

# no idea, how to test that


