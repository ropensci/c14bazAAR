#' @rdname db_getter_backend
#' @export
get_jomon <- function(db_url = get_db_url("jomon")) {

  check_connection_to_url(db_url)

  # read data
  jomon <- db_url %>%
    data.table::fread(
      drop = c(
        "SampleID",
        "CombineGroup",
        "SiteID",
        "Site_Address_JP",
        "MaterialType_JP",
        "Phase",
        "Phase_Details",
        "PhaseAnalysis",
        "Delta13CError"
        ),
      encoding = "UTF-8",
      showProgress = FALSE
    ) %>%
    base::replace(., . == "", NA) %>%
    dplyr::transmute(
      labnr = .data[["LabCode"]],
      c14age = .data[["CRA"]],
      c14std = .data[["Error"]],
      c13val = .data[["Delta13C"]],
      material = .data[["MaterialType_En"]],
      site = .data[["Site_Name_JP"]],
      region = .data[["Region"]],
      sitetype = .data[["Context_JP"]],
      period = .data[["PotteryPhase_JP"]],
      shortref = .data[["Source"]]
    ) %>%
    dplyr::mutate(
      sourcedb = "jomon",
      sourcedb_version = get_db_version("jomon")
    ) %>%
    as.c14_date_list()

  return(jomon)
}
