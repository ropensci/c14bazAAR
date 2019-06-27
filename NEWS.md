# c14bazAAR 1.0.3

## new getter functions
- added getter function for Palmisano et al. database: `get_Palmisano` (#59)
- added getter function for EUBAR database: `get_EUBAR` (#64)

## new features
- added new options for the deduplication function (see `?duplicates`) (#63)
- added an internal function `clean_labnr` to the `as.c14_date_list` workflow to fix certain syntactically wrong representations of lab numbers in several input databases as part of the downloading process (#61)
- added a [checklist](https://github.com/ISAAKiel/c14bazAAR#adding-database-getter-functions) to the README on how to add new getter functions
- better implementation of the `c14_date_list` as a subclass of tibble (#67)

# bugfixes
- small file path construction fix in CONTEXT getter function (4f3e3a8c4fb596d6ce9667814d661a5bc533a824)
- replaced some deprecated functions by other packages (dplyr::funs & tibble::as.tibble)

# c14bazAAR 1.0.2

Release version
