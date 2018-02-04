context("database parsers and helper functions ~ 30s")

#### get_all_parser_functions ####

parser_functions <- c14bazAAR:::get_all_parser_functions()

test_that("get_all_parser_functions gives back a list", {
  expect_type(
    parser_functions, "list"
  )
})

test_that("get_all_parser_functions gives back a list with more then one entry", {
  expect_gt(
    length(parser_functions), 1
  )
})

test_that("get_all_parser_functions gives back a list of functions", {
  expect_true(
    all(sapply(parser_functions, is.function))
  )
})

#### two random parser function - to reduce test time ####

date_lists <- list()
date_lists[[1]] <- sample(parser_functions, 1)[[1]]()
date_lists[[2]] <- sample(parser_functions, 1)[[1]]()

test_that("two random parsers give back a c14_date_list", {
  expect_true(
    all(sapply(date_lists, c14bazAAR::is.c14_date_list))
  )
})

test_that("two random parsers give back a c14_date_list with more than one entry", {
  expect_true(
    all(sapply(date_lists, nrow) > 1)
  )
})

#### get_all_dates ####

all_dates <- c14bazAAR::get_all_dates()

test_that("get_all_dates gives back a c14_date_list", {
  expect_true(
    c14bazAAR::is.c14_date_list(all_dates)
  )
})

test_that("get_all_dates gives back a c14_date_list with more entries
          compared with calling two parsers", {
  expect_gt(
    nrow(all_dates), sum(sapply(date_lists, nrow))
  )
})

