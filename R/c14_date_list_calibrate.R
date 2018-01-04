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

  # add or replace empty integer column calage
  if ("calage" %in% colnames(x) %>% all) {
    x$calage <- NA_integer_
  } else {
    x <- x %>%
      tibble::add_column(
        calage = NA_integer_,
        .after = "c14std"
      )
  }

  # add or replace empty list column filled with empty data.frames calprobdistr
  if ("calprobdistr" %in% colnames(x) %>% all) {
    x$calprobdistr <- I(replicate(nrow(x), data.frame()))
  } else {
    x <- x %>%
      tibble::add_column(
        calprobdistr = I(replicate(nrow(x), data.frame())),
        .after = "calage"
      )
  }

  # determine dates that are out of the range of the calcurve can not be calibrated
  toona <- which(is.na(x$c14age) | is.na(x$c14std))
  toosmall <- which(x$c14age < min(intcal13[,2]))
  toobig <- which(x$c14age > max(intcal13[,2]))
  outofrange <- c(toona, toosmall, toobig) %>% unique

  # extract dates which are not out of range
  calibrateable <- x[-outofrange, ]

  # create empty calibration result data.frame list
  calibrateable_prodistr <- replicate(nrow(calibrateable), data.frame())

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
    calibrateable_prodistr[step_seq] <- Bchron::BchronCalibrate(
      ages      = calibrateable_step$c14age,
      ageSds    = calibrateable_step$c14std,
      calCurves = rep("intcal13", nrow(calibrateable_step)),
      eps       = 1e-06
    ) %>%
      # extract border ages of the 2sigma range
      lapply(
        function(x) {
          data.frame(calage = x[["ageGrid"]], density = x[["densities"]])
        }
      )

    # increment progress bar
    utils::setTxtProgressBar(pb, 5 + 90 * i/amount_of_iterations)
  }

  # determine calage
  calage_vector <- calibrateable_prodistr %>%
    lapply(
      function(x) {
        x$calage[which.max(x$density)]
      }
    ) %>% unlist

  # write result back into x
  x$calage[-outofrange] <- calage_vector
  x$calprobdistr[-outofrange] <- calibrateable_prodistr

  # increment progress bar
  utils::setTxtProgressBar(pb, 100)

  # close progress bar
  close(pb)

  return(x)
}
