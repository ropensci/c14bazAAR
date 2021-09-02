context("country attribution functions")

#### output ####

# determine_country_by_coordinate

result <- determine_country_by_coordinate(example_c14_date_list)

test_that("determine_country_by_coordinate gives back a c14_date_list", {
  expect_s3_class(
    result,
    "c14_date_list"
  )
})

test_that("determine_country_by_coordinate gives back a c14_date_list with the additional
          column country_coord", {
  expect_true(
    all(
      c(colnames(example_c14_date_list), "country_coord") %in%
        colnames(result)
    )
  )
})

test_that("determine_country_by_coordinate gives back a c14_date_list with the additional
          column country_coord and this column is of type character", {
  expect_type(
    result$country_coord,
    "character"
  )
})
