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

  check_if_packages_are_available(c("Bchron", "plyr"))

  # start message:
  message(paste0("Calibration... ", {if (nrow(x) > 1000) {"This may take several minutes."}}))

  # setup progress bar
  pb <- utils::txtProgressBar(
    max = 100,
    style = 3,
    width = 50,
    char = "+"
  )

  # add empty columns "calage" and "calprobdistr"
  x %<>% add_or_replace_column_in_df("calage",  NA_integer_, .after = "c14std")
  x %<>% add_or_replace_column_in_df("calprobdistr",  I(replicate(nrow(x), data.frame())), .after = "calage")

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
      eps = 1e-06
    )

    # increment progress bar
    utils::setTxtProgressBar(pb, 5 + 90 * i/amount_of_iterations)
  }

  # determine calage
  calage_vector <- determine_calage_from_probability_distribution(calibrateable_prodistr)

  # write result back into x
  x$calage[-outofrange] <- calage_vector
  x$calprobdistr[-outofrange] <- calibrateable_prodistr

  # TODO put this into the parameter
  my_sigma <- 2

  my_prob_vector <- c(0.6827, 0.9545, 0.9974)

  x %<>% add_or_replace_column_in_df("calrange",  I(replicate(nrow(x), data.frame())), .after = "calprobdistr")
  x %<>% add_or_replace_column_in_df("sigma",  NA_integer_, .after = "calrange")

  x$calrange[-outofrange] <- lapply(x$calprobdistr[-outofrange],hdr, prob = my_prob_vector[my_sigma])

  x$sigma <- my_sigma

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
determine_dates_out_of_range_of_calcurve <- function(x) {
  # load intcal13 data from Bchron
  utils::data("intcal13", package = "Bchron")

  toona <- which(is.na(x$c14age) | is.na(x$c14std))
  toosmall <- which(x$c14age < min(intcal13[,2]))
  toobig <- which(x$c14age > max(intcal13[,2]))
  outofrange <- c(toona, toosmall, toobig) %>% unique

  return(outofrange)
}

#' calibrate_to_probability_distribution
#'
#' @param x c14_date_list
#' @param ... passed to Bchron::BchronCalibrate()
#'
#' @return list with probability distribution data frames
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
#' A function for computing highest density regions (HDRs). Adopted from the Bchron package
#'
#' @details The output of this function is a list of contiguous ranges which cover the probability interval requested. A highest density region might have multiple such ranges if the calibrated date is multi-modal. These differ from credible intervals, which are always contiguous but will not be a good representation of a multi-modal probability distribution.
#'
#' @param calprobdistr the probability distribution
#' @param prob The desired probability interval, in the range(0, 1)
#'
#' @return a dataframe containing the hdr
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
