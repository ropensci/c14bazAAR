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

  # apply ordering key
  x <- x %>%
    dplyr::select(
      .data[["labnr"]],
      .data[["site"]],
      .data[["c14age"]],
      .data[["c14std"]],
      dplyr::contains("calage"),
      dplyr::contains("calstd"),
      .data[["material"]],
      dplyr::contains("material_cor"),
      .data[["country"]],
      dplyr::contains("country_cor"),
      .data[["lat"]],
      .data[["lon"]],
      dplyr::everything()
    )

  return(x)
}

#### thesaurify ####

#' @name thesaurify
#' @title Apply thesaurus
#'
#' @description Add columns country_cor & material_cor with simplified and unified terms
#'
#' @param x an object of class c14_date_list
#'
#' @return an object of class c14_date_list
#' @export
#'
#' @rdname thesaurify
#'
thesaurify <- function(x) {
  UseMethod("thesaurify")
}

#' @rdname thesaurify
#' @export
thesaurify.default <- function(x) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname thesaurify
#' @export
thesaurify.c14_date_list <- function(x) {

  # whitespaces
  x <- x %>%
    dplyr::mutate_if(
      is.character,
      stringr::str_trim
    )
  message("Removed leading and trailing whitespaces in all character columns.")

  # add or empty columns calage and calstd
  if (c("country_cor", "material_cor") %in% colnames(x) %>% all) {
    x$country_cor <- NA
    x$material_cor <- NA
  } else {
    x <- x %>%
      tibble::add_column(
        country_cor = NA,
        .after = "country"
      ) %>%
      tibble::add_column(
        material_cor = NA,
        .after = "material"
      )
  }

  # apply thesauri and create new columns
  x <- x %>%
    dplyr::mutate(
      country_cor = ifelse(
        .$country %in% c14databases::country_thesaurus$var,
        c14databases::country_thesaurus$cor[match(.$country, c14databases::country_thesaurus$var)],
        .$country
      ),
      material_cor = ifelse(
        .$material %in% c14databases::material_thesaurus$var,
        c14databases::material_thesaurus$cor[match(.$material, c14databases::material_thesaurus$var)],
        .$material
      )
    ) %>%
    `class<-`(c("c14_date_list", class(.)))

  return(x)
}

#### clean ####

#' @name clean
#' @title Clean dataset
#'
#' @description Apply some data cleaning steps to a c14_date_list
#'
#' @param x an object of class c14_date_list
#'
#' @return an object of class c14_date_list
#' @export
#'
#' @rdname clean
#'
clean <- function(x) {
  UseMethod("clean")
}

#' @rdname clean
#' @export
clean.default <- function(x) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname clean
#' @export
clean.c14_date_list <- function(x) {

  # whitespaces
  x <- x %>%
    dplyr::mutate_if(
      is.character,
      stringr::str_trim
    )
  message("Removed leading and trailing whitespaces in all character columns.")

  # lat&lon not available but zero
  x[which(x[["lon"]] == 0 & x[["lat"]] == 0), c("lon", "lat")] <- NA
  message("Made missing coordinate values explicit. 0/0 -> NA/NA.")

  # lat&long not on this earth
  x[which(x[["lon"]] > 180 | x[["lon"]] < -180 | x[["lat"]] > 90 | x[["lat"]] < -90), c("lon", "lat")] <- NA
  message("Removed coordinate values which are out of bounds.")

  # add class again -- gets lost in in mutate_if :-(
  x <- x %>%
    `class<-`(c("c14_date_list", class(.)))

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
          x$densities            %>% cumsum -> a      # cumulated density
          which(a <= threshold)  %>% max    -> my_min # lower border
          which(a > 1-threshold) %>% min    -> my_max # upper border
          x$ageGrid[c(my_min, my_max)]
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
