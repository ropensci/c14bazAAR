## Ardrac
test <- c14bazAAR::get_aDRAC()
test2 <- c14bazAAR::determine_country_by_coordinate(test)
test3 <- c14bazAAR::standardize_country_name(test2)
test3[1:5, c("lat","lon","country","country_thes","country_coord","coord_precision")]
test4 <- c14bazAAR::finalize_country_name(test3)
test4[1:5, c("lat","lon","country","country_thes","country_coord","coord_precision","country_final")]

## CalPal
test <- c14bazAAR::get_CalPal()
test2 <- c14bazAAR::determine_country_by_coordinate(test)
test3 <- c14bazAAR::standardize_country_name(test2)
test3[1:5, c("lat","lon","country","country_thes","country_coord","coord_precision")]
test4 <- c14bazAAR::finalize_country_name(test3)
test4[1:5, c("lat","lon","country","country_thes","country_coord","coord_precision","country_final")]



