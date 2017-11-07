load("playground/dates.RData")

library(magrittr)
library(SPARQL)

a8 <- a7 %>%
  dplyr::transmute(
    per = period,
    cul = culture,
    pha = phase
  ) %>% dplyr::filter(
    !is.na(per), !is.na(cul), !is.na(pha)
  )

endpoint <- "http://vocab.getty.edu/sparql.xml"

search_att <- function(word) {

  # 300019332: European Neolithic (culture or period)
  # 300106924: Aegean Neolithic periods
  # 300107633: Levantine Neolithic periods

  q <- paste0(
    "select ?Subject ?Term ?Parents ?ScopeNote ?Parent where {
      ?Subject a skos:Concept;
                 luc:term '", word, "'; ",
                "skos:inScheme aat: ;
                 gvp:prefLabelGVP [xl:literalForm ?Term].
      ?Subject gvp:broaderPreferred ?Parent;
      optional {?Subject gvp:parentStringAbbrev ?Parents}
      optional {?Subject skos:scopeNote [dct:language gvp_lang:en; rdf:value ?ScopeNote]}"
    ,
    "filter (
      ?Parent in (
        aat:300019332, aat:300266481, aat:30010763, aat:300106924
      ))",
    "}"
  ) %>% gsub("[\n]", "", .) %>%
    gsub("(?<=[\\s])\\s*|^\\s+|\\s+$", "", ., perl=TRUE)

  res <- tryCatch(
    {invisible(SPARQL(url = endpoint, query = q)$results)},
    error = function(cond) {NULL}
  )

  # res_only_periods <- res %>%
  #   dplyr::filter(
  #     grepl("Styles and Periods Facet", Parents)
  #   )

  return(res)
}


total <- 50
pb <- txtProgressBar(min = 0, max = total, style = 3)

hu <- list()
for (i in 1:total) {

  for (p2 in 3:1) {
    knupp <- search_att(a8[i, p2])
    if (nrow(knupp) > 0) {
      hu[[i]] <- knupp
      break;
    }
  }

  setTxtProgressBar(pb, i)

}
close(pb)

