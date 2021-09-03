#' @rdname db_getter_backend
#' @export

library(rintchron)

get_intchron <- function(){

  sadb <- intchron(c("sadb")) %>%
    dplyr::transmute(
      method =,
      labnr = .data[["labcode"]],
      c14age = .data[["r_date"]],
      c14std = .data[["r_date_sigma"]],
      c13val = .data[["d13C"]],
      site = .data[["site"]],
      feature = .data[["context"]],
      period = .data[["period"]],
      culture = .data[["subperiod"]],
      material = .data[["material"]],
      species = .data[["species"]],
      region = .data[["region"]],
      country = .data[["country"]],
      lat = .data[["latitude"]],
      lon = .data[["longitude"]],
      shortref = .data[["refs"]]
    ) %>%
    as.c14_date_list()

  return(sadb)

}

