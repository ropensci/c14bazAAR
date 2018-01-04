#### calibrate ####

#' @name calibrate
#' @title Calibrate dates
#'
#' @description Calibrate all valid dates in a c14_date_list
#'
#' @param x an object of class c14_date_list
#'
#' @return an object of class c14_date_list
#' @export
#'
#' @rdname calibrate
#'
calibrate <- function(x) {
  UseMethod("calibrate")
}

#' @rdname calibrate
#' @export
calibrate.default <- function(x) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname calibrate
#' @export
calibrate.c14_date_list <- function(x) {

  # check if packages Bchron and plyr are available
  if (
    c("Bchron", "plyr") %>%
    sapply(function(x) {requireNamespace(x, quietly = TRUE)}) %>%
    all %>% `!`
  ) {
    stop(
      "R packages 'Bchron' and 'plyr' needed for this function to work. Please install it.",
      call. = FALSE
    )
  }

  # load intcal13 data from Bchron
  utils::data("intcal13", package = "Bchron")

  # start message:
  message(paste0("Calibration... ", {if (nrow(x) > 1000) {"This may take several minutes."}}))

  # setup progress bar
  pb <- utils::txtProgressBar(
    max = 100,
    style = 3,
    width = 50,
    char = "+"
  )

  # add or empty columns calage and calstd
  if (c("calage", "calstd") %in% colnames(x) %>% all) {
    x$calage <- NA
    x$calstd <- NA
  } else {
    x <- x %>%
      tibble::add_column(
        calage = NA,
        .after = "c14std"
      ) %>%
      tibble::add_column(
        calstd = NA,
        .after = "calage"
      )
  }

  # determine dates that are out of the range of the calcurve can not be calibrated
  toona <- which(is.na(x$c14age) | is.na(x$c14std))
  toosmall <- which(x$c14age < min(intcal13[,1]))
  toobig <- which(x$c14age > max(intcal13[,1]))
  outofrange <- c(toona, toosmall, toobig) %>% unique

  # copy these dates without calibration
  x$calage[outofrange] <- x$c14age[outofrange]
  x$calstd[outofrange] <- x$c14std[outofrange]

  # 2sigma range probability threshold
  threshold <- (1 - 0.9545) / 2

  # extract dates which are not out of range
  calibrateable <- x[-outofrange, ]

  # create empty calibration result data.frame
  interval95 <- data.frame(
    .id = rep(NA, nrow(calibrateable)),
    V1 = NA,
    V2 = NA
  )

  # determine amount of calibration loop iteration to work through the data in stacks of 200 dates
  # -> artificial stacks
  step_width <- 200
  amount_of_iterations <- ceiling(nrow(calibrateable)/step_width)

  # increment progress bar
  utils::setTxtProgressBar(pb, 5)

  # calibration loop -- loop only for progress bar :-( -- code was much simpler without this
  for (i in 1:amount_of_iterations) {

    # define step sequence for this step
    step_seq <- (step_width * (i - 1) + 1):if (i == amount_of_iterations)
    {nrow(calibrateable)} else {(step_width * i)}

    # separate data in stacks of size step_width
    calibrateable_step <- calibrateable[step_seq,]

    # calibration
    interval95[step_seq,] <- Bchron::BchronCalibrate(
      ages      = calibrateable_step$c14age,
      ageSds    = calibrateable_step$c14std,
      calCurves = rep("intcal13", nrow(calibrateable_step)),
      eps       = 1e-06
    ) %>%
      # extract border ages of the 2sigma range
      plyr::ldply(., function(x) {
        x[["densities"]]            %>% cumsum -> a      # cumulated density
        which(a <= threshold)  %>% max    -> my_min # lower border
        which(a > 1-threshold) %>% min    -> my_max # upper border
        x[["ageGrid"]][c(my_min, my_max)]
      }
      )

    # increment progress bar
    utils::setTxtProgressBar(pb, 5 + 90 * i/amount_of_iterations)
  }

  # take the mean of the borders as CALAGE and the distance
  # of CALAGE to the upper and lower 95.45% interval as CALSTD
  top <- round(interval95[, 3])
  amean <- apply(interval95[, 2:3], 1, function(x){round(mean(x))})

  # write result back into x
  x$calage[-outofrange] <- amean
  x$calstd[-outofrange] <- top - amean

  # increment progress bar
  utils::setTxtProgressBar(pb, 100)

  # close progress bar
  close(pb)

  return(x)
}
