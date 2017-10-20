[![Travis-CI Build Status](https://travis-ci.org/ISAAKiel/c14bazAAR.svg?branch=master)](https://travis-ci.org/ISAAKiel/c14bazAAR) [![Coverage Status](https://img.shields.io/codecov/c/github/ISAAKiel/c14bazAAR/master.svg)](https://codecov.io/github/ISAAKiel/c14bazAAR?branch=master)
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/c14bazAAR)](http://cran.r-project.org/package=c14bazAAR)
[![license](https://img.shields.io/badge/license-GPL%202-B50B82.svg)](https://www.r-project.org/Licenses/GPL-2)

# c14bazAAR

R package to query different C14 date databases (formerly known as c14databases). Allows basic data cleaning, calibration and merging. This package simplifies the data collection from different openly accessible source databases. 

# Databases

* `get_aDRAC()` [aDRAC](https://github.com/dirkseidensticker/aDRAC): Archives des datations radiocarbone d'Afrique centrale by **Dirk Seidensticker**.
* `get_CALPAL()` [CALPAL](https://uni-koeln.academia.edu/BernhardWeninger/CalPal): Radiocarbon Database of the [CalPal software package](http://monrepos-rgzm.de/forschung/ausstattung.html#calpal) by **Bernhard Weninger**. See [nevrome/CalPal-Database](https://github.com/nevrome/CalPal-Database) for an interface.
* `get_CONTEXT()` [CONTEXT](http://context-database.uni-koeln.de/): Collection of radiocarbon dates from sites in the Near East and neighboring regions (20.000 - 5.000 calBC) by **Utz Böhner** and **Daniel Schyle**.
* `get_EUROEVOL()` [EUROEVOL](http://discovery.ucl.ac.uk/1469811/): Cultural Evolution of Neolithic Europe Dataset by [**Katie Manning**, **Sue Colledge**, **Enrico Crema**, **Stephen Shennan** and **Adrian Timpson**](http://openarchaeologydata.metajnl.com/articles/10.5334/joad.40/).
* `get_RADON()` [RADON](http://radon.ufg.uni-kiel.de/): Central European and Scandinavian database of 14C dates for the Neolithic and Early Bronze Age by [Dirk Raetzel-Fabian, Martin Furholt, **Martin Hinz**, Johannes Müller, **Christoph Rinne**, Karl-Göran Sjögren und Hans-Peter Wotzka](http://www.jna.uni-kiel.de/index.php/jna/article/view/65).

# Installation
```
# install.packages("devtools")
devtools::install_github("ISAAKiel/c14bazAAR")
```

