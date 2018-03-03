#### calibrate ####

#' @name calibrate
#' @title Calibrate all valid dates in a \strong{c14_date_list}
#'
#' @description Calibrate all dates in a \strong{c14_date_list} with
#' \code{Bchron::BchronCalibrate()}. The function provides two different
#' kinds of output variables that are added as new list columns to the input
#' \strong{c14_date_list}: \strong{calprobdistr} and \strong{calrange}.
#' \strong{calrange} is accompanied by \strong{sigma}. See
#' \code{?Bchron::BchronCalibrate} and \code{?c14bazAAR:::hdr} for some more
#' information. \cr
#' \strong{calprobdistr}: The probability distribution of the individual date
#' for all ages with an individual probability >= 1e-06. For each date there's
#' a data.frame with the columns \strong{calage} and \strong{density}. \cr
#' \strong{calrange}: The contiguous ranges which cover the probability interval
#' requested for the individual date. For each date there's a data.frame with the
#' columns \strong{dens} and \strong{from} and \strong{to}.
#'
#' @param x an object of class c14_date_list
#' @param choices whether the result should include the full calibrated
#' probability dataframe ('probdist') or the sigma range ('sigmarange').
#' Both arguments may be given at the same time.
#' @param sigma the desired sigma value (1,2,3) for the calibrated sigma ranges
#' @param ... passed to Bchron::BchronCalibrate()
#'
#' @return an object of class c14_date_list with the additional columns
#' \strong{calprobdistr} or \strong{calrange} and \strong{sigma}
#'
#' @examples
#' calibrate(
#'   example_c14_date_list,
#'   choices = c("probdist", "sigmarange"),
#'   sigma = 1
#' )
#'
#' @export
#'
#' @rdname calibrate
#'
calibrate <- function(x, choices = c("sigmarange"), sigma = 2, ...) {
  UseMethod("calibrate")
}

#' @rdname calibrate
#' @export
calibrate.default <- function(x, choices = c("sigmarange"), sigma = 2, ...) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname calibrate
#' @export
calibrate.c14_date_list <- function(x, choices = c("sigmarange"), sigma = 2, ...) {

  choices <- match.arg(choices,
                       c("probdist", "sigmarange"),
            several.ok = TRUE)

  check_if_packages_are_available(c("Bchron", "plyr"))

  # this would actually not be necessary, because a c14_date_list has
  # those columns per definition
  x %>% check_if_columns_are_present(c("c14age", "c14std"))

  # start message:
  message(paste0("Calibration... ", {if (nrow(x) > 1000) {"This may take several minutes."}}))

  # setup progress bar
  pb <- utils::txtProgressBar(
    max = 100,
    style = 3,
    width = 50,
    char = "+"
  )

  # add empty column "calprobdistr"
  x %<>% add_or_replace_column_in_df("calprobdistr",  I(replicate(nrow(x), data.frame())), .after = "c14std")

  # extract dates which are not out of range of calcurve
  outofrange <- x %>% determine_dates_out_of_range_of_calcurve()
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

    # calibration in stacks of size step_width
    calibrateable_prodistr[step_seq] <- calibrate_to_probability_distribution(
      calibrateable[step_seq, ],
      eps = 1e-06,
      ...
    )

    # increment progress bar
    utils::setTxtProgressBar(pb, 5 + 90 * i/amount_of_iterations)
  }

  # determine calage
  calage_vector <- determine_calage_from_probability_distribution(calibrateable_prodistr)

  # write result back into x
  x$calprobdistr[-outofrange] <- calibrateable_prodistr

  # vector of probabilities for 1, 2 and 3 sigma
  my_prob_vector <- c(0.6827, 0.9545, 0.9974)

  if ("sigmarange" %in% choices) {
    x %<>% add_or_replace_column_in_df("calrange",  I(replicate(nrow(x), data.frame())), .after = "calprobdistr")
    x %<>% add_or_replace_column_in_df("sigma",  NA_integer_, .after = "calrange")
    x$calrange[-outofrange] <- lapply(x$calprobdistr[-outofrange], hdr, prob = my_prob_vector[sigma])
    x$sigma <- sigma
  } else {
    x$calrange <- x$sigma <- NULL
  }

  if (!("probdist" %in% choices)) {
    x$calprobdistr <- NULL
  }

  # turning x back into a c14_date_list
  x %<>% as.c14_date_list()

  # increment progress bar
  utils::setTxtProgressBar(pb, 100)

  # close progress bar
  close(pb)

  return(x)
}

#' determine_dates_out_of_range_of_calcurve
#'
#' @param x c14_date_list
#'
#' @return indizes of dates in c14_date_list which are out of calcurve range
#'
#' @keywords internal
determine_dates_out_of_range_of_calcurve <- function(x) {
  # load intcal13 data from Bchron
  intcal13 <- NA
  utils::data("intcal13", package = "Bchron", envir = environment())
  if(!is.data.frame(intcal13)) stop("Problems loading intcal13 dataset from package Bchron.")

  toona <- which(is.na(x$c14age) | is.na(x$c14std))
  toosmall <- which(x$c14age < min(intcal13[,2]))
  toobig <- which(x$c14age > max(intcal13[,2]))
  outofrange <- c(toona, toosmall, toobig) %>% unique

  return(outofrange)
}

#' calibrate_to_probability_distribution
#'
#' @param x c14_date_list
#' @param ... further arguments passed to Bchron::BchronCalibrate()
#'
#' @return list with probability distribution data frames
#'
#' @keywords internal
calibrate_to_probability_distribution <- function(x, ...) {
  Bchron::BchronCalibrate(
    ages      = x$c14age,
    ageSds    = x$c14std,
    calCurves = rep("intcal13", nrow(x)),
    ...
  ) %>%
    # extract probability distribution from BchronCalibrate output
    # and craft new data.frame with year and density
    lapply(
      function(x) {
        data.frame(calage = x[["ageGrid"]], density = x[["densities"]])
      }
    ) %>%
    return()
}

#' determine_calage_from_probability_distribution
#'
#' @param x c14_date_list
#'
#' @return vector of calages
#'
#' @keywords internal
determine_calage_from_probability_distribution <- function(x) {
  x %>%
    lapply(
      function(x) {
        x$calage[which.max(x$density)]
      }
    ) %>%
    unlist %>%
    return()
}

#' Calculate highest density regions for Bchron calibrated ages
#'
#' A function for computing highest density regions (HDRs).
#' Adopted from the Bchron package.
#'
#' @details The output of this function is a list of contiguous ranges which
#' cover the probability interval requested. A highest density region might
#' have multiple such ranges if the calibrated date is multi-modal. These
#' differ from credible intervals, which are always contiguous but will not
#' be a good representation of a multi-modal probability distribution.
#'
#' @param calprobdistr the probability distribution
#' @param prob The desired probability interval, in the range(0, 1)
#'
#' @return a dataframe containing the hdr
#'
#' @keywords internal
hdr <- function(calprobdistr, prob = 0.95) {

  if(findInterval(prob, c(0, 1))!=1) stop('prob value outside (0,1).')

  ag <- calprobdistr$calage
  de <- calprobdistr$density

  # Put the probabilities in order
  o = order(de)
  cu = cumsum(de[o])

  # Find which ones are above the threshold
  good_cu = which(cu>1-prob)
  good_ag = sort(ag[o][good_cu])

  # Pick out the extremes of each range
  breaks = diff(good_ag)>1
  where_breaks = which(diff(good_ag)>1)
  n_breaks = sum(breaks) + 1

  # Store output
  out = data.frame(dens = double(), from=integer(), to=integer())
  low_seq = 1
  high_seq = ifelse(length(where_breaks)==0, length(breaks), where_breaks[1])
  for(i in 1:n_breaks) {
    curr_dens = round(100*sum(de[o][seq(good_cu[low_seq], good_cu[high_seq])]),1)
    out[i,] = c(curr_dens, good_ag[low_seq], good_ag[high_seq])
    low_seq = high_seq + 1
    high_seq = ifelse(i<n_breaks-1, where_breaks[i+1], length(breaks))
  }
  return(out)
}
