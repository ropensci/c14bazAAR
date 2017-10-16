#' get current 14SEA-Database
#'
#' Downloads the current version of the 14SEA-Database from \url{http:///www.14sea.org/}.
#'
#' @examples
#'
#' \dontrun{
#'   14SEA <- get_14SEA()
#' }
#'
#' @export
get_14SEA <- function() {

  # URL
  db_url <- "http://www.14sea.org/img/14SEA_Full_Dataset_2017-01-29.xlsx"

  # check connection
  if (!RCurl::url.exists(db_url)) {stop(paste(db_url, "is not available. No internet connection?"))}

  # download data to temporary file
  tempo <- tempfile()
  utils::download.file(db_url, tempo)

  # read data
  SEA14 <- tempo %>%
    readxl::read_xlsx(
      trim_ws = TRUE,
      na = c("Combination fails", "nd", "-"),
      col_types = c(
        Site = "text",
        Subregion = "text",
        `Subregion no.` = "text",
        Country = "text",
        `Lab. no.` = "text",
        `Date BP` = "text",
        `±` = "text",
        δ13C = "text",
        `calBC 1σ (from)` = "text",
        `calBC 1σ (to)` = "text",
        Material = "text",
        Level = "text",
        Provenance = "text",
        Comment = "text",
        Period = "text",
        `Reference 1` = "text",
        `Reference 2` = "text",
        `Reference 3` = "text",
        `Reference 4` = "text"
      )
    )# %>%
    # dplyr::rename(
    #   id = .data[["ID"]],
    #   labnr = .data[["LABNR"]],
    #   c14age = .data[["C14AGE"]],
    #   c14std = .data[["C14STD"]],
    #   c13val = .data[["C13"]],
    #   material = .data[["MATERIAL"]],
    #   species = .data[["SPECIES"]],
    #   country = .data[["COUNTRY"]],
    #   site = .data[["SITE"]],
    #   period = .data[["PERIOD"]],
    #   culture = .data[["CULTURE"]],
    #   featuretype = .data[["FEATURETYPE"]],
    #   feature = .data[["FEATURE"]],
    #   lat = .data[["LATITUDE"]],
    #   lon = .data[["LONGITUDE"]],
    #   shortref = .data[["REFERENCE"]],
    #   pages = .data[["PAGES"]]
    # ) %>%
    # # unite shortref & pages (if not NA)
    # tidyr::replace_na(list(shortref = "", pages = "")) %>%
    # tidyr::unite_(
    #   ., "shortref", c("shortref", "pages"), sep = ", ", remove = TRUE
    # ) %>%
    # dplyr::mutate(
    #   shortref = replace(.$shortref, which(.$shortref == ", "), NA)
    # ) %>%
    # dplyr::mutate(
    #   shortref = gsub("[,]+[[:space:]]$", "", .$shortref)
    # ) %>% dplyr::mutate(
    #   sourcedb = "RADON"
    # ) %>%
    # as.c14_date_list() %>%
    # c14databases::order_variables()

    # delete temporary file
    unlink(tempo)

    return(SEA14)
}
