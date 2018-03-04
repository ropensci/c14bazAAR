context("coordinate precision")

#### output ####

result <- coordinate_precision(
  example_c14_date_list
)

test_that("coordinate_precision gives back a c14_date_list", {
  expect_s3_class(
    result,
    "c14_date_list"
  )
})

test_that("coordinate_precision gives back a c14_date_list with the additional
          column coord_precision", {
  expect_true(
    all(
      c(colnames(example_c14_date_list), "coord_precision") %in%
        colnames(result)
    )
  )
})

test_that("coordinate_precision gives back a c14_date_list with the additional
          column coord_precision and this column is of type double", {
  expect_type(
    result$coord_precision,
    "double"
  )
})
