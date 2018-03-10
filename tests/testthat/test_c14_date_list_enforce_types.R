context("enforce types")

#### output ####

result <- enforce_types(example_c14_date_list)

test_that("enforce_types gives back a c14_date_list", {
  expect_s3_class(
    result,
    "c14_date_list"
  )
})

test_that("enforce_types gives back a c14_date_list with the same columns
          as the input c14_date_list", {
  expect_equal(
    colnames(example_c14_date_list),
    colnames(result)
  )
})

example <- data.frame(
  c14age = c("foo", "bar"),
  c14std = c(20.456, 30.123),
  stringsAsFactors = FALSE
)
class(example) <- c("c14_date_list", class(example))
example_result <- enforce_types(example)

test_that("enforce_types does adjust variable types if necessary", {
  expect_false(
    all(sapply(example, class) == sapply(example_result, class))
  )
})

#### warnings ####

test_that("enforce_types warns if it applies changes and warnings are not suppressed", {
  expect_warning(
    enforce_types(example, suppress_na_introduced_warnings = FALSE),
    NULL
  )
})
