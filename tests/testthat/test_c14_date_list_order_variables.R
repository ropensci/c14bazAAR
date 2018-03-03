context("order variables")

#### output ####

result <- order_variables(example_c14_date_list)

test_that("order_variables gives back a c14_date_list", {
  expect_s3_class(
    result,
    "c14_date_list"
  )
})

test_that("order_variables gives back a c14_date_list with the same columns
          as the input c14_date_list", {
  expect_true(
    all(
      colnames(example_c14_date_list) %in% colnames(result)
    )
  )
})

example <- data.frame(
  c14std = c(20, 30),
  c14age = c(2000, 2500),
  stringsAsFactors = FALSE
)
class(example) <- c("c14_date_list", class(example))
example_result <- order_variables(example)

test_that("order_variables does change the variable order according to the
          defined order", {
  expect_equal(
    colnames(example_result),
    c("c14age", "c14std")
  )
})

