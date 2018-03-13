context("basic c14_date_calibrate functions")

correct_input <- as.c14_date_list(data.frame(c14age = c(2000, 2500), c14std = c(20, 30)))
oor_input <- as.c14_date_list(data.frame(c14age = c(200000, 2500), c14std = c(20, 30)))
wrong_input <- data.frame(holland="in not")

#### input sensitivity ####
test_that("calibrate.c14_date_list produces an error with incorrect input", {
  expect_error(calibrate(wrong_input), "not an object of class c14_date_list")
})

test_that("calibrate.c14_date_list not produces an error with correct input", {
  expect_error(calibrate(correct_input), NA)
})

test_that("calibrate.c14_date_list returns c14_date_list", {
  expect_true(is.c14_date_list(calibrate(correct_input)))
})

#### parameter sensitivity ####

test_that("calibrate.c14_date_list correctly considers parameters", {
  expect_true(all(c("calrange", "sigma") %in% colnames(calibrate(correct_input))))
  expect_false("calprobdistr" %in% colnames(calibrate(correct_input)))
  expect_true("calprobdistr" %in% colnames(calibrate(correct_input, choices = "calprobdistr")))
  expect_false(all(c("calrange", "sigma") %in% colnames(calibrate(correct_input, choices = "calprobdistr"))))
  expect_true(all(c("calrange", "sigma", "calprobdistr") %in% colnames(calibrate(correct_input, choices = c("calprobdistr", "calrange")))))
  expect_true(all(calibrate(correct_input, sigma = 3)$sigma==3))
  expect_true(all(calibrate(correct_input)$sigma==2))
})

#### Sigma Ranges ####

test_that("calibrate.c14_date_list 2 sigma range is not wider than 3 sigma range", {
  a <- calibrate(correct_input)$calrange[[1]][,c("from", "to")]
  b <- calibrate(correct_input, sigma = 3)$calrange[[1]][,c("from", "to")]
  expect_true(min(a)>=min(b))
  expect_true(max(a)<=max(b))
})

#### message ####

test_that("calibrate.c14_date_list returns a message", {
  expect_message(calibrate(correct_input), "Calibrating dates...")
})

#### not calibration out of range data ####

test_that("calibrate.c14_date_list returns a message", {
  expect_equal(nrow(calibrate(calibrate(oor_input))$calrange[[1]]), 0)
})

