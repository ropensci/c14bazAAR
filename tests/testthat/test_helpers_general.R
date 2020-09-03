context("generally useful heper functions")

# check_if_packages_are_available
test_that("check_if_packages_are_available works", {
  expect_silent(
    check_if_packages_are_available(c("c14bazAAR", "dplyr"))
  )
  expect_error(
    check_if_packages_are_available(c("abc", "def"))
  )
})

# check_if_columns_are_present
test_that("check_if_columns_are_present works", {
  expect_silent(
    check_if_columns_are_present(example_c14_date_list, c("feature", "period"))
  )
  expect_error(
    check_if_columns_are_present(example_c14_date_list, c("abc", "def"))
  )
})

# check_connection_to_url
test_that("check_connection_to_url works", {
  skip_on_cran()
  expect_silent(
    check_connection_to_url("http://www.google.com")
  )
  expect_error(
    check_connection_to_url("abc")
  )
})
