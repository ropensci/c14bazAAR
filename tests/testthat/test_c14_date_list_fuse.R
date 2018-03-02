context("fuse")

result <- fuse(example_c14_date_list, example_c14_date_list)

test_that("fuse gives back a c14_date_list", {
  expect_s3_class(
    result,
    "c14_date_list"
  )
})

test_that("fuse gives back a c14_date_list with the same columns
          as the input c14_date_list", {
  expect_equal(
    colnames(example_c14_date_list),
    colnames(result)
  )
})

test_that("fuse does rbind c14_date_lists", {
  expect_equal(
    nrow(result),
    2*nrow(example_c14_date_list)
  )
})
