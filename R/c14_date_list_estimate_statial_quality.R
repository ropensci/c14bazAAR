#### estimate_spatial_quality ####

#' @name estimate_spatial_quality
#' @title Estimate quality of coordinate information
#'
#' @description Estimate quality of coordinates with a set of tests
#'
#' @param x an object of class c14_date_list
#' @param country_thesaurus_table a thesaurus table (default: c14databases::country_thesaurus)
#'
#' @return an object of class c14_date_list
#' @export
#'
#' @rdname estimate_spatial_quality
#'
estimate_spatial_quality <- function(x, country_thesaurus_table = c14databases::country_thesaurus) {
  UseMethod("estimate_spatial_quality")
}

#' @rdname estimate_spatial_quality
#' @export
estimate_spatial_quality.default <- function(x, country_thesaurus_table = c14databases::country_thesaurus) {
  stop("x is not an object of class c14_date_list")
}

#' @rdname estimate_spatial_quality
#' @export
estimate_spatial_quality.c14_date_list <- function(x, country_thesaurus_table = c14databases::country_thesaurus) {

  # check if packages sp, rworldmap and rworldxtra are available
  if (
    c("sp", "rworldmap", "rworldxtra") %>%
    sapply(function(x) {requireNamespace(x, quietly = TRUE)}) %>%
    all %>% `!`
  ) {
    stop(
      "R package 'sp', 'rworldmap' and 'rworldxtra' needed for this function to work. Please install it.",
      call. = FALSE
    )
  }

  # duration message
  if (nrow(x) > 1000) {
    message("This may take several minutes...")
  }

  # setup progress bar
  pb <- utils::txtProgressBar(
    max = 100,
    style = 3,
    width = 50,
    char = "+"
  )

  # load world map
  world <- rworldmap::getMap(resolution = 'high')
  worldproj <- sp::CRS(sp::proj4string(world))

  utils::setTxtProgressBar(pb, 3)

  # determine dates without coordinate information
  x[["lon"]] %>% is.na %>% which -> emptylon
  x[["lat"]] %>% is.na %>% which -> emptylat
  {x[["lon"]] == 0 & x[["lat"]] == 0} %>% which -> empty_null
  c(emptylon, emptylat, empty_null) %>% unique -> empty

  # determine country from coordinates and world map
  if ("country_coord" %in% colnames(x)) {
    x$country_coord <- NA
  } else {
    x <- x %>%
      tibble::add_column(
        country_coord = NA,
        .after = "country"
      )
  }

  x$country_coord[-empty] <- x[if(length(empty > 0)){-empty} else {1:nrow(x)}, c("lon", "lat")] %>%
    sp::SpatialPoints(proj4string = worldproj) %>%
    sp::over(., world) %>%
    .[["ADMIN"]] %>%
    as.character

  utils::setTxtProgressBar(pb, 10)

  # check country-coordinate relation for every date
  if ("spatial_quality" %in% colnames(x)) {
    x$spatial_quality <- NA
  } else {
    x <- x %>%
      tibble::add_column(
        spatial_quality = NA,
        .after = "lon"
      )
  }

  ldb <- nrow(x)

  # loop
  for (i in 1:ldb) {

    lon <- x[["lon"]][i]
    lat <- x[["lat"]][i]
    coordcountry <- x$country_coord[i]
    dbcountry <- x$country[i]

    # test, if there are coords
    # yes: ok, go on
    # no: stop and store "no coords"
    if (is.na(lon) | is.na(lat) | (lon == 0 & lat == 0)) {
      x[["spatial_quality"]][i] <- "no coords"
      next()
    }

    # test, if the coords are within the spatial frame of reference
    # yes: ok, go on
    # no: stop and store "wrong coords"
    if (lon > 180 | lon < -180 | lat > 90 | lat < -90) {
      x[["spatial_quality"]][i] <- "wrong coords"
      next()
    }

    # test, if it was possible to determine country from coordinates
    # yes: ok, go on
    # no: stop and store "doubtful coords"
    if (is.na(coordcountry)) {
      x[["spatial_quality"]][i] <- "doubtful coords"
      next()
    }

    # test, if the initial country value is NA
    # yes: stop and store country name determined from coords + "possibly correct"
    # no: go on
    if (is.na(dbcountry)) {
      x[["country"]][i] <- coordcountry
      x[["spatial_quality"]][i] <- "possibly correct"
      next()
    }

    # compare country info in db and country info determined from coords
    # apply thesaurus to get every possible spelling of a country
    corc <- dplyr::filter(
      country_thesaurus_table,
      .data[["var"]] == dbcountry
    )$cor
    if(length(corc) != 0) {
      dbcountrysyn <- c(
        dbcountry,
        corc,
        dplyr::filter(country_thesaurus_table, .data[["cor"]] == corc)$var
      ) %>%
        unique
    } else {
      dbcountrysyn <- dbcountry
    }


    # test, if the initial country value is equal to the country name determined
    # from coords
    # yes: ok, go on
    # no: stop and store country name determined from coords + "doubtful correct"
    if (!(coordcountry %in% dbcountrysyn)) {
      x[["country"]][i] <- coordcountry
      x[["spatial_quality"]][i] <- "doubtful coords"
      next()
      # else (initial country value is equal to the country name determined from coords)
      # store "possibly correct"
    } else {
      x[["spatial_quality"]][i] <- "possibly correct"
    }

    # increment progress bar
    utils::setTxtProgressBar(pb, 10 + 88 * (i/ldb))
  }

  utils::setTxtProgressBar(pb, 100)
  close(pb)

  return(x)
}
