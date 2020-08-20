context("duplicates related functions")

option_test_input <- tibble::tribble(
  ~sourcedb, ~labnr,  ~c14age, ~c14std,
  "A",       "lab-1", 1100,    10,
  "A",       "lab-1", 2100,    20,
  "B",       "lab-1", 3100,    30,
  "A",       "lab-2", NA,      10,
  "B",       "lab-2", 2200,    20,
  "C",       "lab-3", 1300,    10
) %>%
  as.c14_date_list()

#### remove_duplicates ####

result <- remove_duplicates(option_test_input)

test_that("remove_duplicates gives back a c14_date_list", {
  expect_s3_class(
    result,
    "c14_date_list"
  )
})

test_that("remove_duplicates gives back a c14_date_list with the additional
          column duplicate_remove_log", {
            expect_true(
              all(
                c("duplicate_remove_log") %in%
                  colnames(result)
              )
            )
          })

test_that("remove_duplicates gives back a c14_date_list with the additional
          column duplicate_remove_log and this column is of type character", {
            expect_type(
              result$duplicate_remove_log,
              "character"
            )
          })

#### remove_duplicates with mark_only = TRUE ####

result_mark_only <- remove_duplicates(option_test_input, mark_only = TRUE)

test_that("remove_duplicates with mark_only = TRUE gives back a c14_date_list", {
  expect_s3_class(
    result_mark_only,
    "c14_date_list"
  )
})

test_that("remove_duplicates with mark_only = TRUE gives back a c14_date_list
          with the additional column duplicate_group", {
  expect_true(
    all(
      c(colnames(option_test_input), "duplicate_group") %in%
        colnames(result_mark_only)
    )
  )
})

test_that("remove_duplicates with mark_only = TRUE gives back a c14_date_list with
          the additional column duplicate_group and this column is of type integer", {
  expect_type(
    result_mark_only$duplicate_group,
    "integer"
  )
})

#### remove_duplicates options ####

# option 1
option_test_res_1 <- tibble::tribble(
  ~sourcedb, ~labnr,  ~c14age, ~c14std,
  "C",       "lab-3", 1300,    10,
  NA,        "lab-1", NA,      NA,
  NA,        "lab-2", 2200,    NA
) %>% as.c14_date_list()

test_that("duplicate removal option 1 works as expected", {
  expect_equal(
    option_test_input %>% remove_duplicates(., log = FALSE),
    option_test_res_1
  )
})

test_that("duplicate removal option 1 works with log = TRUE", {
  expect_true(
    "duplicate_remove_log" %in% (option_test_input %>% remove_duplicates() %>% colnames())
  )
})

# option 2
option_test_res_2 <- tibble::tribble(
  ~sourcedb, ~labnr,  ~c14age, ~c14std,
  "A",       "lab-1", 1100,    10,
  "A",       "lab-2", NA,      10
) %>% as.c14_date_list()

test_that("duplicate removal option 2 works as expected", {
  expect_equal(
    option_test_input %>% remove_duplicates(
      preferences = c("A", "B"), log = FALSE
    ),
    option_test_res_2
  )
})

test_that("duplicate removal option 2 works with log = TRUE", {
  expect_true(
    "duplicate_remove_log" %in% (
      option_test_input %>% remove_duplicates(
        preferences = c("A", "B"), log = TRUE
      ) %>% colnames()
    )
  )
})

# option 3
option_test_res_3 <- tibble::tribble(
  ~labnr,  ~c14age, ~c14std,
  "lab-1", 1100,    10,
  "lab-2", 2200,    10
) %>% as.c14_date_list()

test_that("duplicate removal option 3 works as expected", {
  expect_equal(
    option_test_input %>% remove_duplicates(
      preferences = c("A", "B"), supermerge = TRUE, log = FALSE
    ),
    option_test_res_3
  )
})

test_that("duplicate removal option 3 works with log = TRUE", {
  expect_true(
    "duplicate_remove_log" %in% (
      option_test_input %>% remove_duplicates(
        preferences = c("A", "B"), supermerge = TRUE, log = TRUE
      ) %>% colnames()
    )
  )
})
