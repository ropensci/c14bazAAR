# c14bazAAR 1.0.3

- added getter function for Palmisano et al. database: `get_Palmisano` (#59)
- small file path construction fix in CONTEXT getter function (4f3e3a8c4fb596d6ce9667814d661a5bc533a824)
- added an internal function `clean_labnr` to the `as.c14_date_list` workflow to fix certain syntactically wrong representations of lab numbers in several input databases as part of the downloading process (#61)
- added a feature to `remove_duplicates` that allows to define a preference order of source databases which is used to select entries in case of duplicates (see `?duplicates`)
- replaced some deprecated functions by other packages (dplyr::funs & tibble::as.tibble)

# c14bazAAR 1.0.2

Release version
