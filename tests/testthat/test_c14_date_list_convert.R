context("conversion functions")

#### as.sf ####

result <- as.sf(example_c14_date_list)

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
