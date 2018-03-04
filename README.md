[![Travis-CI Build Status](https://travis-ci.org/ISAAKiel/c14bazAAR.svg?branch=master)](https://travis-ci.org/ISAAKiel/c14bazAAR) [![Coverage Status](https://img.shields.io/codecov/c/github/ISAAKiel/c14bazAAR/master.svg)](https://codecov.io/github/ISAAKiel/c14bazAAR?branch=master)
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/c14bazAAR)](http://cran.r-project.org/package=c14bazAAR)
[![license](https://img.shields.io/badge/license-GPL%202-B50B82.svg)](https://www.r-project.org/Licenses/GPL-2)

# c14bazAAR

<img align="right" src="khajiit.jpg" width = 350>

c14bazAAR is a R package to query different openly accessible radiocarbon date databases. It allows basic data cleaning, calibration and merging. It serves as backend of the [neolithicRC WebApp](https://github.com/nevrome/neolithicR). If you're not familiar with R the [WebApp](http://www.neolithicRC.de) might be better suited for your needs.

#### Table of Contents

- [Installation](#installation)
- [How to use](#how-to-use)
  - [Download](#download)
  - [Calibration](#calibration)
  - [Material classification](#material-classification)
  - [Country attribution](#country-attribution)
  - [Duplicates](#duplicates)
  - [Coordinate precision](#coordinate-precision)
  - [Conversion](#conversion)
  - [Technical functions](#technical-functions)
- [Databases](#databases)

### Installation

c14bazAAR is not on [CRAN](https://cran.r-project.org/) yet, but you can install it from github. To do so, run the following lines in your R console:

```
if(!require('devtools')) install.packages('devtools')
devtools::install_github("ISAAKiel/c14bazAAR")
```

The package needs a lot of other packages -- many of them only necessary for specific tasks. Functions that require certain packages you don't have installed yet will stop and ask you to install them. Please do so with [`install.packages()`](https://www.r-bloggers.com/installing-r-packages/) to download and install the respective packages from CRAN.

### How to use

The package contains a set of getter functions (see below) to query the databases. Thereby not every available variable from every archive is downloaded. Instead c14bazAAR focuses on a [selection](https://github.com/ISAAKiel/c14bazAAR/blob/master/data-raw/variable_reference.csv) of the most important and most common variables to achieve a certain degree of standardization. The downloaded dates are stored in the custom S3 class `c14_date_list` which acts as a wrapper around the [tibble](http://tibble.tidyverse.org/) class and provides specific class methods.

The complete workflow to download and prepare all dates can be triggered like this:

```
# trööt
```

It takes quite some time to run all of this and it's probably not necessary for your usecase. Here's a list of the main tasks c14bazAAR can handle. That allows you to pick what you need:

#### Download

c14bazAAR contains a growing selection of getter functions to download radiocarbon date databases. [Here's](#databases) a list of all available getters. You can download all dates at once with `get_all_dates()`. The getters download the data, adjust the variable selection according to a defined [variable key](https://github.com/ISAAKiel/c14bazAAR/blob/master/data-raw/variable_reference.csv) and transform the resulting list into a `c14_date_list`. 

```
x <- get_all_dates()
```

#### Calibration

The `calibrate()` function calibrates all valid dates in a `c14_date_list` individually with `Bchron::BchronCalibrate()`. It provides two different types of output: calprobdistr and calrange. See `?calibrate` for more information.

```
x %>% calibrate()
```

#### Material classification

Most 14C databases provide some information about the material sampled for the individual date. Unfortunately this information is often very specific and makes filtering operations diffult for large datasets. The function `classify_material()` relies on a [custom made classification](https://github.com/ISAAKiel/c14bazAAR/blob/master/data-raw/material_thesaurus.csv) to simplify this data. See `?classify_material` for more information and look [here](https://github.com/ISAAKiel/c14bazAAR/blob/master/data-raw/material_thesaurus_comments.md) for a changelog of the thesaurus.

```
x %>% classify_material()
```

#### Country attribution

Filtering 14C dates by country is useful for a first spatial limitation and especially important, if no coordinates are documented. Most databases provide the variable coountry, but they don't rely on a unified naming convention and therefore use various terms to represent the same entity. The function `standardize_country_name()` tries to unify the semantically equal terms by string comparison with the curated country name list `countrycode::codelist` and a [custom made thesaurus](https://github.com/ISAAKiel/c14bazAAR/blob/master/data-raw/country_thesaurus.csv). Beyond that it turned out to be much more reliable to look at the coordinates to determine the country. 

That's what the function `determine_country_by_coordinate()` does. It joins the position with country polygons from `rworldxtra::countriesHigh` to get reliable country attribution. 

The function `finalize_country_name()` finally combines the initial country information in the database and the results of the two previous functions to forge a single column country_final.

The wrapper function `all_country_functions()` calls these function automatically in a sequence. See `?country_attribution` for more information.

```
x %>%
  standardize_country_name() %>%
  determine_country_by_coordinate() %>%
  finalize_country_name()
```

#### Duplicates

Some of the source databases already contain duplicated dates and for sure you'll have some if you combine different databases. As a result of the long history of these archives, which includes even mutual absorbation, duplicates make up a significant proportion of combined datasets. The function `mark_duplicates()` adds a column duplicate group to the c14_date_list, that assigns duplicates found by labcode comparison a common group number. This should allow you to make an educated decision, which dates to discard. 

For an automatic removal there's the function `remove_duplicates()`. It boils down all dates in a duplicate_group to one entry. Unequal values become NA. All variants for all columns are documented within a string in the column duplicate_remove_log.

See `?duplicates` for more information.

```
x %>%
  mark_duplicates() %>%
  remove_duplicates()
```

#### Coordinate precision

```
x %>% coordinate_precision
```

#### Conversion

```
x %>% as.sf()
```

#### Technical functions

Beyond that there are some small helpers to combine (`fuse()`), structure (`order_variables()`, `enforce_types()`) or convert (`as.sf()`, ...) `c14_date_list`s.

```
x3 <- fuse(x1, x2)
```

### Databases

To suggest other archives to be queried you can join the discussion [here](https://github.com/ISAAKiel/c14bazAAR/issues/2).

* [`get_14SEA()`](R/get_14sea.R) [**14SEA**](http://www.14sea.org/) 14C database for Southeast Europe and Anatolia (10,000–3000 calBC).
* [`get_aDRAC()`](R/get_adrac.R) [**aDRAC**](https://github.com/dirkseidensticker/aDRAC): Archives des datations radiocarbone d'Afrique centrale by Dirk Seidensticker.
* [`get_AustArch()`](R/get_austarch.R) [**AustArch**](http://archaeologydataservice.ac.uk/archives/view/austarch_na_2014/): A Database of 14C and Luminescence Ages from Archaeological Sites in Australia by [Alan N. Williams, Sean Ulm, Mike Smith, Jill Reid](http://intarch.ac.uk/journal/issue36/6/williams.html)
* [`get_CalPal()`](R/get_calpal.R) [**CALPAL**](https://uni-koeln.academia.edu/BernhardWeninger/CalPal): Radiocarbon Database of the [CalPal software package](http://monrepos-rgzm.de/forschung/ausstattung.html#calpal) by Bernhard Weninger. See [nevrome/CalPal-Database](https://github.com/nevrome/CalPal-Database) for an interface.
* [`get_CONTEXT()`](R/get_context.R) [**CONTEXT**](http://context-database.uni-koeln.de/): Collection of radiocarbon dates from sites in the Near East and neighboring regions (20.000 - 5.000 calBC) by Utz Böhner and Daniel Schyle.
* [`get_EUROEVOL()`](R/get_euroevol.R) [**EUROEVOL**](http://discovery.ucl.ac.uk/1469811/): Cultural Evolution of Neolithic Europe Dataset by [Katie Manning, Sue Colledge, Enrico Crema, Stephen Shennan and Adrian Timpson](http://openarchaeologydata.metajnl.com/articles/10.5334/joad.40/).
* [`get_KITEeastAfrica()`](R/get_eastafrica.R) [**CARD Upload Template - KITE East Africa v2.1**](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/NJLNRJ): Radiocarbon dates from eastern Africa in the CARD2.0 format by [Colin Courtney Mustaphi, Rob Marchant](https://www.openquaternary.com/articles/10.5334/oq.22/)
* [`get_RADON()`](R/get_radon.R) [**RADON**](http://radon.ufg.uni-kiel.de/): Central European and Scandinavian database of 14C dates for the Neolithic and Early Bronze Age by [Dirk Raetzel-Fabian, Martin Furholt, Martin Hinz, Johannes Müller, Christoph Rinne, Karl-Göran Sjögren und Hans-Peter Wotzka](http://www.jna.uni-kiel.de/index.php/jna/article/view/65).
* [`get_RADONB()`](R/get_radonb.R) [**RADON-B**](http://radon-b.ufg.uni-kiel.de/): Database for European 14C dates for the Bronze and Early Iron Age by Jutta Kneisel, Martin Hinz, Christoph Rinne.

All databases can be queried at once with `get_all_dates()`.


