# c14bazAAR 1.0.3

## new getter functions
- added getter function for Palmisano et al. database: `get_Palmisano` (#59)
- added getter function for EUBAR database: `get_EUBAR` (#64)

## new features
- added new options for the deduplication function (see `?duplicates`) (#63)
- added an internal function `clean_labnr` to the `as.c14_date_list` workflow to fix certain syntactically wrong representations of lab numbers in several input databases as part of the downloading process (#61)
- added a [checklist](https://github.com/ISAAKiel/c14bazAAR#adding-database-getter-functions) to the README on how to add new getter functions
- better implementation of the `c14_date_list` as a subclass of tibble for a better integration of the subclass into the tidyverse (#67)
- added a [citation](https://github.com/ISAAKiel/c14bazAAR#citation) section to the README

## bugfixes
- small file path construction fix in CONTEXT getter function
- replaced some deprecated functions by other packages (dplyr::funs & tibble::as.tibble)
- replaced `RCurl::url.exists` with `httr::http_error` in `check_connection_to_url` (#68)

## removed objects
- data objects `c14bazAAR::country_thesaurus`, `c14bazAAR::material_thesaurus`, `c14bazAAR::variable-reference` have been removed from the package -- they are queried from [here](https://github.com/ISAAKiel/c14bazAAR/tree/master/data-raw) anyway and it's not necessary to put them into the package
- some helper functions have been made internal
- .Rd files for unexported, internal objects have been removed (@noRd)

# c14bazAAR 1.0.2

Release version
