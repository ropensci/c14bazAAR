context("country attribution functions")

#### output ####

# standardize_country_name

result <- standardize_country_name(
  example_c14_date_list,
  quiet = TRUE
)

test_that("standardize_country_name gives back a c14_date_list", {
  expect_s3_class(
    result,
    "c14_date_list"
  )
})

test_that("standardize_country_name gives back a c14_date_list with the additional
          column country_thes", {
  expect_true(
    all(
      c(colnames(example_c14_date_list), "country_thes") %in%
        colnames(result)
    )
  )
})

test_that("standardize_country_name gives back a c14_date_list with the additional
          column country_thes and this column is of type character", {
  expect_type(
    result$country_thes,
    "character"
  )
})

# determine_country_by_coordinate

result2 <- determine_country_by_coordinate(result)

test_that("determine_country_by_coordinate gives back a c14_date_list", {
  expect_s3_class(
    result2,
    "c14_date_list"
  )
})

test_that("determine_country_by_coordinate gives back a c14_date_list with the additional
          column country_coord", {
  expect_true(
    all(
      c(colnames(result), "country_coord") %in%
        colnames(result2)
    )
  )
})

test_that("determine_country_by_coordinate gives back a c14_date_list with the additional
          column country_coord and this column is of type character", {
  expect_type(
    result2$country_coord,
    "character"
  )
})

# finalize_country_name

result3 <- finalize_country_name(result2)

test_that("finalize_country_name gives back a c14_date_list", {
  expect_s3_class(
    result3,
    "c14_date_list"
  )
})

test_that("finalize_country_name gives back a c14_date_list with the additional
          column country_final", {
  expect_true(
    all(
      c(colnames(result2), "country_final") %in%
        colnames(result3)
    )
  )
})

test_that("finalize_country_name gives back a c14_date_list with the additional
          column country_final and this column is of type character", {
  expect_type(
    result3$country_final,
    "character"
  )
})

result4 <- finalize_country_name(example_c14_date_list)

test_that("finalize_country_name gives the same result as the other functions combined,
          because it calls the other functions in case of missing variables.", {
  expect_equal(
    result3,
    result4
  )
})

#### messages ####

test_that("standardize_country_name has message output, if quiet == FALSE", {
  expect_message(
    standardize_country_name(
      example_c14_date_list,
      country_thesaurus = country_thesaurus,
      quiet = FALSE
    ),
    NULL
  )
})

