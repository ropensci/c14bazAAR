---
title: 'c14bazAAR: An R package for downloading and preparing C14 dates from different source databases
tags:
  - R
  - archaeology
  - radiocarbon dates
  - data retrieval
authors:
  - name: Clemens Schmid
    orcid: 0000-0003-3448-5715
    affiliation: 1
  - name: Dirk Seidensticker
    orcid: 0000-0002-8155-7702
    affiliation: 2
  - name: Martin Hinz
    orcid: 0000-0000-0000-0000
    affiliation: 1
affiliations:
  - name: Institute of Archaeological Sciences, University of Bern
    index: 1
  - name: Faculty of Arts and Philosophy, Department of Languages and Cultures, Ghent University
    index: 2
date: 12 July 2019
bibliography: paper.bib
---

# Summary

Radiocarbon dating is an important method for the absolute and relative chronological reconstruction of cultural history, especially within prehistoric archaeology (CITATION). This is true for the intrasite level, for regional comparisons and also in cases where processes that have a large spatial and temporal extension are to be investigated. Examples for the latter include processes like the 'neolithization' of Europe or the 'Bantu expansion' in sub-Saharan Africa, which have been famously analysed with radiocarbon data (e.g. CITATION). 

The selection of the individual data for such models is complex and requires a precise understanding of the archaeological question. It is not sufficient to consider only the data selection that was ultimately processed in a model, but also those that were not integrated. Criticism of these models therefore usually starts with the data set. In order to be able to discuss it though, the data set must be generally accessible and well contextualized. Otherwise no systematic evaluation can take place.

Fortunately many archaeological institutions and individual authors are sharing their radiocarbon collections throughout the web (e.g. CITATION) -- some of them archives with a long tradition of data collection, processing and maintenance. Also the boom of the Open Data movement in recent years has led to and increase of publications with raw data in archaeology (e.g. CITATION). These in themselves offer an important archive for future research questions. 

However the entire data basis is highly decentralized and lacks basic standardisation. That results in an effective loss of the added value that could result from the intersection of data sets in terms of searchability, error checking and further analysis. The creation of a world-wide, standardized and centralised database of radiocarbon dates is not to be expected for the near future.

**c14bazAAR** therefore tries to solve the problem at hand, by providing an independent interface to access different radiocarbon data sources and to enable them for a reproducible research process, from modelling to publication to scientific discourse. It only queries openly available ^14^C data archives not behind pay- or login-walls.

The package includes getter functions `get_*` (e.g. `get_aDRAC()`, `get_EUROEVOL()`) that download the databases from different sources online, reduce them to a basic set of common variables and store them in a dedicated R S3 class `c14_date_list`. A `c14_date_list` establishes standardized variable types for the most important variables usually defined to describe radiocarbon data and -- technically -- it inherits from `tibble::tibble` to integrate well into the [tidyverse](https://www.tidyverse.org/) ecosystem (CITATION).

In addition to that c14bazAAR contains a multitude of functions that can be applied to objects of class `c14_date_list`. These include methods for the bulk calibration of radiocarbon dates with the Bchron R package (CITATION), the removal of dublicates, the estimation of coordinate precision, and the conversion to other useful R data types (e.g. `sf::sf` (CITATION)). For the classification of sample material c14bazAAR provides manually curated reference lists that map the inconsistent attributions in the source databases to a standardized set of material classes. Such a reference list exists as well to fix the country attribution value of dates -- which is especially important for dates witzh missing coordinate information. For these dates another function to determine the source country based on coordinate information fails.

c14bazAAR is already in use for...

# Acknowledgements

The packages is developed by the ISAAKiel group (Initiative for Statistical Analysis in Archaeology Kiel) https://isaakiel.github.io

# References
