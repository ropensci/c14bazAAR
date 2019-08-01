context("conversion functions")

#### as.sf ####

test_that("as.sf prints a warning when it has to remove dates without coordinates", {
  expect_warning(
    as.sf(example_c14_date_list),
    "Dates without coordinates were removed."
  )
})

result <- as.sf(example_c14_date_list, quiet = T)

test_that("as.sf gives back a sf object", {
  expect_s3_class(
    result,
    "sf"
  )
})

test_that("as.sf gives back a sf object with the correct columns", {
  expect_equal(
    colnames(result),
    c(
      paste0("data.", colnames(example_c14_date_list)),
      "geom"
    )
  )
})
