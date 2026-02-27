#' Author: Bruno Tebaldi Barbosa
#'
#' 2021-11-09
#'
#' Script que faz a preparacao dos dados (com buraco) para a regressao do GVAR 
#' 
#' 
# Setup -------------------------------------------------------------------

rm(list = ls())

library(dplyr)
library(tidyr)

# Data Load ---------------------------------------------------------------

Gas_agrupo <- readRDS("./database/Gasolina_Agrupamento.rds")

colnames(Gas_agrupo)

db_com_buraco <- Gas_agrupo %>% 
  filter(PRODUTO %in% c("ETANOL_HIDRATADO", "OLEO_DIESEL", "GASOLINA_COMUM")) %>% 
  pivot_wider(id_cols = c("DATA_INICIAL", "DATA_FINAL"),
              names_from = c("OxCode", "PRODUTO"),
              values_from = "PRECO_MEDIO_REVENDA",
              names_prefix = "R_")


# completa datas faltantes
db_com_buraco <- db_com_buraco %>% add_row(DATA_INICIAL = as.Date("2005-08-14"), DATA_FINAL = as.Date("2005-08-20"))
db_com_buraco <- db_com_buraco %>% add_row(DATA_INICIAL = as.Date("2005-08-21"), DATA_FINAL = as.Date("2005-08-27"))
db_com_buraco <- db_com_buraco %>% add_row(DATA_INICIAL = as.Date("2009-08-16"), DATA_FINAL = as.Date("2009-08-22"))
db_com_buraco <- db_com_buraco %>% add_row(DATA_INICIAL = as.Date("2009-08-23"), DATA_FINAL = as.Date("2009-08-29"))
db_com_buraco <- db_com_buraco %>% add_row(DATA_INICIAL = as.Date("2015-08-16"), DATA_FINAL = as.Date("2015-08-22"))
db_com_buraco <- db_com_buraco %>% add_row(DATA_INICIAL = as.Date("2022-09-18"), DATA_FINAL = as.Date("2022-09-24"))

# PANDEMIA HOLE
db_com_buraco <- db_com_buraco %>% add_row(DATA_INICIAL = as.Date("2020-08-23"), DATA_FINAL = as.Date("2020-08-29"))
db_com_buraco <- db_com_buraco %>% add_row(DATA_INICIAL = as.Date("2020-08-30"), DATA_FINAL = as.Date("2020-09-05"))
db_com_buraco <- db_com_buraco %>% add_row(DATA_INICIAL = as.Date("2020-09-06"), DATA_FINAL = as.Date("2020-09-12"))
db_com_buraco <- db_com_buraco %>% add_row(DATA_INICIAL = as.Date("2020-09-13"), DATA_FINAL = as.Date("2020-09-19"))
db_com_buraco <- db_com_buraco %>% add_row(DATA_INICIAL = as.Date("2020-09-20"), DATA_FINAL = as.Date("2020-09-26"))
db_com_buraco <- db_com_buraco %>% add_row(DATA_INICIAL = as.Date("2020-09-27"), DATA_FINAL = as.Date("2020-10-03"))
db_com_buraco <- db_com_buraco %>% add_row(DATA_INICIAL = as.Date("2020-10-04"), DATA_FINAL = as.Date("2020-10-10"))
db_com_buraco <- db_com_buraco %>% add_row(DATA_INICIAL = as.Date("2020-10-11"), DATA_FINAL = as.Date("2020-10-17"))

db_com_buraco %>% count(DATA_INICIAL) %>% arrange(-n)

db_com_buraco <- db_com_buraco %>% arrange(DATA_INICIAL)

sort(diff(db_com_buraco$DATA_INICIAL), decreasing = TRUE)
sort(diff(db_com_buraco$DATA_FINAL), decreasing = TRUE)
which(diff(db_com_buraco$DATA_INICIAL) != 7)
which(diff(db_com_buraco$DATA_FINAL) != 7)

saveRDS(object = db_com_buraco,
        file = "./database/db_Ox_com_buraco.rds")










