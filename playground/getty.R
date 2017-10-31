load("playground/dates.RData")

library(magrittr)
library(SPARQL)

a7$culture %>% unique
a7$period %>% unique
a7$phase %>% unique

a8 <- a7 %>%
  dplyr::transmute(
    per = period,
    cul = culture,
    pha = phase
  ) %>% dplyr::filter(
    !is.na(per), !is.na(cul), !is.na(pha)
  )

endpoint <- "http://vocab.getty.edu/sparql.xml"

total <- 20
pb <- txtProgressBar(min = 0, max = total, style = 3)

hu <- list()
for (i in 1:total) {

  for (p2 in 3:1) {
    knupp <- search_att(a8[i, p2])
    if (!is.null(knupp)) {
      hu[[i]] <- knupp
      break;
    }
  }

  setTxtProgressBar(pb, i)

}
close(pb)

search_att <- function(word) {
  q <- paste0(
    "select ?Subject ?Term ?Parents ?ScopeNote {
  ?Subject a skos:Concept; luc:term '",
    word,
    "'; skos:inScheme aat: ;
     gvp:prefLabelGVP [xl:literalForm ?Term].
  optional {?Subject gvp:parentStringAbbrev ?Parents}
  optional {?Subject skos:scopeNote [dct:language gvp_lang:en; rdf:value ?ScopeNote]}
} order by asc(lcase(str(?Term)))"
  )

  res <- tryCatch(
    {invisible(capture.output(SPARQL(url = endpoint, query = q)$results))},
    error = function(cond) {NULL}
  )

  return(res)
}
