context("classify material")

#### output ####

result <- classify_material(example_c14_date_list)

test_that("classify_material gives back a c14_date_list", {
  expect_s3_class(
    result,
    "c14_date_list"
  )
})

test_that("classify_material gives back a c14_date_list with the additional
          column material_thes", {
  expect_true(
    all(
      c(colnames(example_c14_date_list), "material_thes") %in%
        colnames(result)
    )
  )
})

test_that("classify_material gives back a c14_date_list with the additional
          column material_thes and this column is of type character", {
  expect_type(
    result$material_thes,
    "character"
  )
})
