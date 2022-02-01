##### as ####

#' @name c14_date_list
#'
#' @title \strong{c14_date_list}
#'
#' @description The \strong{c14_date_list} is the central data structure of the
#' \code{c14bazAAR} package. It's a tibble with set of custom methods and
#' variables. Please see the
#' \href{https://github.com/ropensci/c14bazAAR/blob/master/data-raw/variable_reference.csv}{variable_reference}
#' table for a description of the variables. Further available variables are ignored. \cr
#' If an object is of class data.frame or tibble (tbl & tbl_df), it can be
#' converted to an object of class \strong{c14_date_list}. The only requirement
#' is that it contains the essential columns \strong{c14age} and \strong{c14std}.
#' The \code{as} function adds the string "c14_date_list" to the classes vector
#' of the object and applies \code{order_variables()}, \code{enforce_types()} and
#' the helper function \code{clean_latlon()} to it.
#'
#' @param x an object
#' @param ... further arguments passed to or from other methods
#'
#' @rdname c14_date_list
#'
#' @examples
#' as.c14_date_list(data.frame(c14age = c(2000, 2500), c14std = c(30, 35)))
#' is.c14_date_list(5) # FALSE
#' is.c14_date_list(example_c14_date_list) # TRUE
#'
#' print(example_c14_date_list)
#' plot(example_c14_date_list)
#'
#' @export
as.c14_date_list <- function(x, ...) {

  # define expectations
  necessary_vars <- c("c14age","c14std")

  # check input data type
  if("data.frame" %in% class(x) | all(c("tbl", "tbl_df") %in% class(x))){
    # check if necessary vals are present
    present <- necessary_vars %in% colnames(x)
    if (all(present)) {
      # do the actual conversion!
      x %>%
        tibble::new_tibble(., nrow = nrow(.), class = "c14_date_list") %>%
        c14bazAAR::order_variables() %>%
        c14bazAAR::enforce_types() %>%
        clean_latlon() %>%
        clean_labnr() %>%
        return()
    } else {
      stop(
        "The following variables (columns) are missing: ",
        paste(necessary_vars[!present], collapse = ", ")
      )
    }
  } else {
    stop("x is not an object of class data.frame or tibble")
  }

}

#### is ####

#' @rdname c14_date_list
#' @export
is.c14_date_list <- function(x, ...) {"c14_date_list" %in% class(x)}

#### format ####

#' @rdname c14_date_list
#' @export
format.c14_date_list <- function(x, ...) {
  out_str <- list()
  out_str$header <- paste0("\tRadiocarbon date list")
  out_str$dates <- paste0("\t", "dates: ", nrow(x))
  if("site" %in% colnames(x)) {
    out_str$sites <- paste0("\t", "sites: ", length(unique(x[["site"]])))
  }
  if("country" %in% colnames(x)) {
    out_str$country <- paste0("\t", "countries: ", length(unique(x[["country"]])))
  }
  if("c14age" %in% colnames(x)) {
    out_str$range_uncal <- paste0(
      "\t", "uncalBP: ",
      round(max(x[["c14age"]], na.rm = TRUE), -2), " \u2015 ", round(min(x[["c14age"]], na.rm = TRUE), -2)
    )
  }
  if("calage" %in% colnames(x)) {
    out_str$range_cal <- paste0(
      "\t", "calBP: ",
      round(max(x[["calage"]], na.rm = TRUE), -2), " \u2015 ", round(min(x[["calage"]], na.rm = TRUE), -2)
    )
  }
  return_value <- paste(out_str, collapse = "\n", sep = "")
  invisible(return_value)
}

#### print ####

#' @rdname c14_date_list
#' @export
print.c14_date_list <- function(x, ...) {
  # own format function
  cat(format(x, ...), "\n\n")
  # add table printed like a tibble
  x %>% `class<-`(c("tbl", "tbl_df", "data.frame")) %>% print
}

#### plot ####

#' @rdname c14_date_list
#' @export
plot.c14_date_list <- function(x, ...) {

  check_if_packages_are_available("globe")

  # store par settings
  old.par <- graphics::par(no.readonly = TRUE)

  # set plot layout
  graphics::layout(
    matrix(c(1,2,4,3,3,4,5,5,5), 3, 3, byrow = TRUE),
    widths = c(1,0.5,1.5), heights = c(0.7,0.55,1)
  )

  # plot 1: text
  graphics::par(mar = c(0, 0, 0, 0))
  graphics::plot(0, type = 'n', axes = FALSE, ann = FALSE)
  graphics::legend(
    "topleft",
    format(x) %>% gsub("\t", "", .),
    bty = "n",
    cex = 1.7
  )

  # prepare data for mapping
  mean_lon <- mean(x[["lon"]], na.rm = T)
  x_west <- x[x[["lon"]] < mean_lon,]
  x_east <- x[x[["lon"]] >= mean_lon,]

  # plot 2: small globe: "western side of the distribution"
  if (all(c("lon", "lat") %in% colnames(x))) {
    graphics::par(mar = c(0, 0, 0, 0))
    # opposite side of the globe
    # globe::globeearth(eye = list(
    #     -(180-mean(x[["lon"]], na.rm = T)),
    #     -mean(x[["lat"]], na.rm = T)
    # ))
    globe::globeearth(eye = list(
      mean(x_west[["lon"]], na.rm = T),
      mean(x_west[["lat"]], na.rm = T)
    ))
    globe::globepoints(
      loc = x[,c("lon", "lat")],
      col = "red",
      cex = 0.01,
      pch = 20
    )
  } else {
    graphics::par(mar = c(0, 0, 0, 0))
    graphics::plot(0, type = 'n', axes = FALSE, ann = FALSE)
  }

  # plot 3: std histogram
  ste <- x[["c14std"]]
  graphics::par(mar = c(4.2, 4.2, 0, 0))
  graphics::boxplot(
    ste[!is.na(ste) & ste > 0],
    log = "x",
    col = NULL,
    main = NULL,
    frame.plot = FALSE,
    xlab = "Log std error (c14std)",
    cex.axis = 1.5,
    cex.lab = 1.5,
    horizontal = TRUE,
    bg = "transparent"
  )

  # plot 4: big globe: "eastern side of the distribution"
  if (all(c("lon", "lat") %in% colnames(x))) {
    graphics::par(mar = c(0, 0, 0, 0))
    globe::globeearth(eye = list(
      mean(x_east[["lon"]], na.rm = T),
      mean(x_east[["lat"]], na.rm = T)
    ))
    globe::globepoints(
      loc = x[,c("lon", "lat")],
      col = "red",
      cex = 0.01,
      pch = 20
    )
  } else {
    graphics::par(mar = c(0, 0, 0, 0))
    graphics::plot(0, type = 'n', axes = FALSE, ann = FALSE)
    graphics::legend(
      "center",
      "no coordinate columns",
      bty = "n",
      cex = 1.7
    )
  }

  # plot 5: age histogram
  graphics::par(mar = c(4.2, 4.2, 0, 0))
  graphics::hist(
    x[["c14age"]],
    breaks = 100,
    col = NULL,
    main = NULL,
    xlim = rev(range(x[["c14age"]], na.rm = T)),
    xlab = "Uncalibrated Age BP in years (c14age)",
    ylab = "Amount of dates",
    cex.axis = 1.5,
    cex.lab = 1.5
  )

  # reset par setting on exit
  on.exit(graphics::par(old.par))
}

#### accessor functions ####

