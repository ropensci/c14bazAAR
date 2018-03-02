## Works (except the problem with the too low resolution):
## 
## some coordinates are NA; probable reason: coastal distance and too
## low resolution of rworldxtra data; st_is_within_distance might be
## suitable to solve the issue.
##
## a simple buffer or st_is_within_distance might be suitable to solve
## the issue.
## ==================================================

## Ardrac
test <- c14bazAAR::get_aDRAC()
test2 <- c14bazAAR::determine_country_by_coordinate(test)
no_country <- nrow(test2[,c("lat","lon","country","country_coord")][is.na(test2$country_coord) & !is.na(test2$lat),])
paste("no country although there are coordinates?", no_country , "times. I.e. ", round((no_country / nrow(test2)) * 100, 2) , "%")
test3 <- c14bazAAR::standardize_country_name(test2)
test3[1:5, c("lat","lon","country","country_thes","country_coord","coord_precision")]
test4 <- c14bazAAR::finalize_country_name(test3)
test4[1:5, c("lat","lon","country","country_thes","country_coord","coord_precision","country_final")]

## CalPal
test <- c14bazAAR::get_CalPal()
test2 <- c14bazAAR::determine_country_by_coordinate(test)
no_country <- nrow(test2[,c("lat","lon","country","country_coord")][is.na(test2$country_coord) & !is.na(test2$lat),])
paste("no country although there are coordinates?", no_country , "times. I.e. ", (no_country / nrow(test2)) * 100 , "%")
test3 <- c14bazAAR::standardize_country_name(test2)
test3[1:5, c("lat","lon","country","country_thes","country_coord","coord_precision")]
test4 <- c14bazAAR::finalize_country_name(test3)
test4[1:5, c("lat","lon","country","country_thes","country_coord","coord_precision","country_final")]

## CONTEXT
test <- c14bazAAR::get_CONTEXT()
test2 <- c14bazAAR::determine_country_by_coordinate(test)
no_country <- nrow(test2[,c("lat","lon","country","country_coord")][is.na(test2$country_coord) & !is.na(test2$lat),])
paste("no country although there are coordinates?", no_country , "times. I.e. ", (no_country / nrow(test2)) * 100 , "%")
test3 <- c14bazAAR::standardize_country_name(test2)
test3[1:5, c("lat","lon","country","country_thes","country_coord","coord_precision")]
test4 <- c14bazAAR::finalize_country_name(test3)
test4[1:5, c("lat","lon","country","country_thes","country_coord","coord_precision","country_final")]

## RADONB
test <- c14bazAAR::get_RADONB()
test2 <- c14bazAAR::determine_country_by_coordinate(test)
no_country <- nrow(test2[,c("lat","lon","country","country_coord")][is.na(test2$country_coord) & !is.na(test2$lat),])
paste("no country although there are coordinates?", no_country , "times. I.e. ", (no_country / nrow(test2)) * 100 , "%")
test3 <- c14bazAAR::standardize_country_name(test2)
test3[1:5, c("lat","lon","country","country_thes","country_coord","coord_precision")]
test4 <- c14bazAAR::finalize_country_name(test3)
test4[1:5, c("lat","lon","country","country_thes","country_coord","coord_precision","country_final")]

## EUROEVOL
test <- c14bazAAR::get_EUROEVOL()
test2 <- c14bazAAR::determine_country_by_coordinate(test)
no_country <- nrow(test2[,c("lat","lon","country","country_coord")][is.na(test2$country_coord) & !is.na(test2$lat),])
paste("no country although there are coordinates?", no_country , "times. I.e. ", round((no_country / nrow(test2)) * 100, 2), "%")
test3 <- c14bazAAR::standardize_country_name(test2)
test3[1:5, c("lat","lon","country","country_thes","country_coord","coord_precision")]
test4 <- c14bazAAR::finalize_country_name(test3)
test4[1:5, c("lat","lon","country","country_thes","country_coord","coord_precision","country_final")]

## RADON 
test <- c14bazAAR::get_RADON()
test2 <- c14bazAAR::determine_country_by_coordinate(test)
no_country <- nrow(test2[,c("lat","lon","country","country_coord")][is.na(test2$country_coord) & !is.na(test2$lat),])
paste("no country although there are coordinates?", no_country , "times. I.e. ", round((no_country / nrow(test2)) * 100, 2), "%")
test3 <- c14bazAAR::standardize_country_name(test2)
test3[1:5, c("lat","lon","country","country_thes","country_coord","coord_precision")]
test4 <- c14bazAAR::finalize_country_name(test3)
test4[1:5, c("lat","lon","country","country_thes","country_coord","coord_precision","country_final")]

## FAILS
## ==================================================

## AustArch
## PROBLEM 1: the data lacks a "country" column; therefore it is not possible to use the functions standardize_country_name as well as finalize_country_name.
## PROBLEM 2: there are negative values in the precision calculation; the data is from Australia, perhaps this is the reason?! 
test <- c14bazAAR::get_AustArch()
test2 <- c14bazAAR::determine_country_by_coordinate(test)
no_country <- nrow(test2[,c("lat","lon","country_coord")][is.na(test2$country_coord) & !is.na(test2$lat),])
paste("no country although there are coordinates?", no_country , "times. I.e. ", round((no_country / nrow(test2)) * 100, 2), "%")
test3 <- c14bazAAR::standardize_country_name(test2)
test3[1:5, c("lat","lon","country","country_thes","country_coord","coord_precision")]
test4 <- c14bazAAR::finalize_country_name(test3)
test4[1:5, c("lat","lon","country","country_thes","country_coord","coord_precision","country_final")]

## KITEeastAfrica
## ERROR: https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/NJLNRJ is not available. No internet connection?
test <- c14bazAAR::get_KITEeastAfrica()
test2 <- c14bazAAR::determine_country_by_coordinate(test)
test3 <- c14bazAAR::standardize_country_name(test2)
test3[1:5, c("lat","lon","country","country_thes","country_coord","coord_precision")]
test4 <- c14bazAAR::finalize_country_name(test3)
test4[1:5, c("lat","lon","country","country_thes","country_coord","coord_precision","country_final")]

## all in one
## ERROR: https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/NJLNRJ is not available. No internet connection?
## --> only the AustArch database is there with the same problems as above
test <- c14bazAAR::get_all_dates()
test2 <- c14bazAAR::determine_country_by_coordinate(test)
no_country <- nrow(test2[,c("lat","lon","country_coord")][is.na(test2$country_coord) & !is.na(test2$lat),])
paste("no country although there are coordinates?", no_country , "times. I.e. ", round((no_country / nrow(test2)) * 100, 2), "%")
test3 <- c14bazAAR::standardize_country_name(test2)
test3[1:5, c("lat","lon","country","country_thes","country_coord","coord_precision")]
test4 <- c14bazAAR::finalize_country_name(test3)
test4[1:5, c("lat","lon","country","country_thes","country_coord","coord_precision","country_final")]
