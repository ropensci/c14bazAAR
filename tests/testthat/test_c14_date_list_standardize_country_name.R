context("standardize country name")

#### output ####

result <- standardize_country_name(
  example_c14_date_list,
  country_thesaurus = country_thesaurus,
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





