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
    orcid: 0000-0002-9904-6548
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

Radiocarbon dating the most important method in archaeology for the absolute and relative chronological reconstruction of cultural development, especially within prehistoric archaeology [@Taylor:2016]. This is true for the intrasite level, for regional comparisons and also in cases where processes that have a large spatial and temporal extension are to be investigated. Prominent examples for the latter include models for processes like the 'neolithization' of Europe or the 'Bantu expansion' in sub-Saharan Africa, which have been analysed with radiocarbon data (e.g. @Ammerman:1971, [CITATION: Hast du da für Bantu etwas ähnlich Initiales wie Ammerman+Cavalli Sforza, Dirk?]). 

Data selection for such models is complex and requires a precise understanding of the archaeological questions. Criticism of these models therefore usually starts with a sceptical look at the underlying data set. It is not sufficient to consider only the data that was eventually included, but also dates that were deliberately omitted. In order to discuss the selection too, the original data set must be generally accessible and well contextualized. Otherwise no systematic evaluation can take place.

Fortunately, many archaeological institutions and individual authors are sharing their radiocarbon collections online (e.g. @hinz_radon_2012, @Kneisel:2013, @Mustaphi:2016, [CITATION: Magst du noch aDRAC ergänzen, Dirk?]) -- some of them archives with a long tradition of great quality control and maintenance. Also the boom of the Open Data movement in recent years has led to and increase of publications with raw data in archaeology (e.g. @Palmisano:2017). These collections are an important archive for future research questions. 

However the entire data basis is currently highly decentralized and lacks basic standardisation. That results in an effective loss of the added value that could result from the intersection of data sets in terms of searchability, error checking and further analysis. The creation of a world-wide, standardized and centralised database of radiocarbon dates is not to be expected for the near future.

``c14bazAAR`` attempts to solve the problem at hand by providing an independent interface to access different radiocarbon data sources and make them available for a reproducible research process, from modelling to publication to scientific discourse. It only queries openly available ^14^C data archives not behind pay- or login-walls.

The package includes getter functions `get_*` (e.g. `get_aDRAC()`, `get_EUROEVOL()`) that download the databases from different sources online, reduce them to a basic set of common variables and store them in a dedicated R S3 class `c14_date_list`. A `c14_date_list` establishes standardized variable types for the most important variables usually defined to describe radiocarbon data and -- technically -- it inherits from `tibble::tibble` to integrate well into the R [tidyverse](https://www.tidyverse.org/) ecosystem.

In addition to that ``c14bazAAR`` contains a multitude of functions that can be applied to objects of class `c14_date_list`. These include methods for the bulk calibration of radiocarbon dates with the Bchron R package [@Haslett:2008], the removal of dublicates, the estimation of coordinate precision, and the conversion to other useful R data types (e.g. `sf::sf` [@Pebesma:2018]). For the classification of sample material ``c14bazAAR`` provides manually curated reference lists that map the inconsistent attributions in the source databases to a standardized set of material classes. Such a reference list exists as well to fix the country attribution value of dates -- which is especially important for dates with missing coordinate information. For these dates another function to determine the source country based on coordinate information fails.

``c14bazAAR`` was already and is currently used for data aquisition and preparation in multiple research papers: [CITATION: Könnte man hier https://boris.unibe.ch/119414/ angeben, Martin?]<!--MH: Das ist aber nur ein Vortragsabstract!-->, @Schmid:2019, [CITATION: Könnte hier das fire events Paper stehen, Dirk? Quasi in prep?]

# Acknowledgements

The package got valuable code input from several members of the [ISAAKiel group](https://isaakiel.github.io) (Initiative for Statistical Analysis in Archaeology Kiel), most notably: Daniel Knitter, David Matzig, Wolfgang Hamer, Kay Schmütz and Nils Müller-Scheeßel.

# References
