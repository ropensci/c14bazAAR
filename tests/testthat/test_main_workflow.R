# context("main c14bazAAR workflow")
#
# library(magrittr)
#
# res <- c14bazAAR::get_all_dates() %>%
#   dplyr::sample_n(500) %>%
#   c14bazAAR::as.c14_date_list() %>%
#   c14bazAAR::calibrate() %>%
#   c14bazAAR::estimate_spatial_quality() %>%
#   c14bazAAR::rm_doubles(mark = TRUE) %>%
#   c14bazAAR::thesaurify()
#
#   test_that("the main workflow produces a c14_date_list", {
#   expect_true(c14bazAAR::is.c14_date_list(res))
# })
