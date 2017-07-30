#### is ####

#' Check if a variable is of class c14_date_list
#'
#' Check if a variable is of class c14_date_list
#'
#' @param x a variable
#' @param ... further arguments passed to or from other methods
#'
#' @return true if x is a c14_date_list, false otherwise
#'
#' @export
is.c14_date_list <- function(x, ...) {"c14_date_list" %in% class(x)}

#### format ####

#' Encode a c14_date_list in a Common Format
#'
#' Format an c14_date_list for pretty printing
#'
#' @param x a c14_date_list
#' @param ... further arguments passed to or from other methods
#'
#' @return A string representation of the c14_date_list
#'
#' @export
format.c14_date_list <- function(x, ...) {
  out_str <- list()
  out_str$header <- paste0("\tRadiocarbon date list")
  out_str$dates <- paste0("\t", "dates", "\t", "\t", nrow(x))
  if("site" %in% colnames(x)) {
    out_str$sites <- paste0("\t", "sites", "\t", "\t", length(unique(x[["site"]])))
  }
  if("country" %in% colnames(x)) {
    out_str$country <- paste0("\t", "countries", "\t", length(unique(x[["country"]])))
  }
  if("c14age" %in% colnames(x)) {
    out_str$range_uncal <- paste0(
      "\t", "uncalBP", "\t", "\t",
      round(max(x[["c14age"]]), -2), " \u2015 ", round(min(x[["c14age"]]), -2)
    )
  }
  if("calage" %in% colnames(x)) {
    out_str$range_cal <- paste0(
      "\t", "calBP", "\t", "\t",
      round(max(x[["calage"]]), -2), " \u2015 ", round(min(x[["calage"]]), -2)
    )
  }
  return_value <- paste(out_str, collapse = "\n", sep = "")
  invisible(return_value)
}

#### print ####

#' Print a c14_date_list
#'
#' Print a c14_date_list according to the format.c14_date_list
#'
#' @param x a c14_date_list
#' @param ... further arguments passed to or from other methods
#'
#' @export
print.c14_date_list <- function(x, ...) {
  # own format function
  cat(format(x, ...), "\n\n")
  # add table printed like a tibble
  x %>% `class<-`(c("tbl", "tbl_df", "data.frame")) %>% print
}

#### order variables ####

#' @name order_variables
#' @title Order variables (static key)
#'
#' @description Order variables in a c14_date_list after a defined key
#'
#' @param x an object of class c14_date_list
#'
#' @return an object of class c14_date_list
#' @export
#'
#' @rdname order_variables
#'
order_variables <- function(x) {
  UseMethod("order_variables")
}

#' @rdname order_variables
#' @export
order_variables.default <- function(x) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname order_variables
#' @export
order_variables.c14_date_list <- function(x) {

  # apply ordering key but consider special case calage & calstd
  if (c("calage", "calstd") %in% colnames(x) %>% all) {
    x <- x %>%
      dplyr::select(
        .data[["labnr"]],
        .data[["site"]],
        .data[["c14age"]],
        .data[["c14std"]],
        .data[["calage"]],
        .data[["calstd"]],
        .data[["material"]],
        .data[["lat"]],
        .data[["lon"]],
        dplyr::everything()
      )
  } else {
    x <- x %>%
      dplyr::select(
        .data[["labnr"]],
        .data[["site"]],
        .data[["c14age"]],
        .data[["c14std"]],
        .data[["material"]],
        .data[["lat"]],
        .data[["lon"]],
        dplyr::everything()
      )
  }

  return(x)
}

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

  if (nrow(x) > 1000) {
    message("This may take several minutes...")
  }

  # setup progress bar
  pb <- utils::txtProgressBar(
    max = 100,
    style = 3
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
  toosmall <- which(x$c14age < 100)
  toobig <- which(x$c14age > 45000)
  outofrange <- c(toosmall, toobig) %>% unique

  # copy these dates without calibration
  x$calage[outofrange] <- x$c14age[outofrange]
  x$calstd[outofrange] <- x$c14std[outofrange]

  # increment progress bar
  utils::setTxtProgressBar(pb, 5)

  # 2sigma range probability threshold
  threshold <- (1 - 0.9545) / 2

  # calibration
  interval95 <- Bchron::BchronCalibrate(
      ages      = x$c14age[-outofrange],
      ageSds    = x$c14std[-outofrange],
      calCurves = rep("intcal13", nrow(x[-outofrange, ])),
      eps       = 1e-06
    ) %>%
    # extract border ages of the 2sigma range
    plyr::ldply(., function(x) {
        x$densities            %>% cumsum -> a      # cumulated density
        which(a <= threshold)  %>% max    -> my_min # lower border
        which(a > 1-threshold) %>% min    -> my_max # upper border
        x$ageGrid[c(my_min, my_max)]
      }
    )

  # increment progress bar
  utils::setTxtProgressBar(pb, 95)

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
