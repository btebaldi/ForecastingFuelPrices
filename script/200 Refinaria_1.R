#' AUTOR: Bruno Tebaldi de Q Barbosa
#' 
#' Data: 2021-09-24
#' 
#' Construção do banco de dados de gasolina para a tese
#' 
#' https://www.gov.br/anp/pt-br/assuntos/precos-e-defesa-da-concorrencia/precos/precos-revenda-e-de-distribuicao-combustiveis/serie-historica-do-levantamento-de-precos
#' https://www.gov.br/anp/pt-br/assuntos/precos-e-defesa-da-concorrencia/precos/precos-revenda-e-de-distribuicao-combustiveis/serie-historica-do-levantamento-de-precos
#' 

# Setup -------------------------------------------------------------------

library(readxl)
rm(list = ls())


# User defined Function ---------------------------------------------------

RenameColumns <- function(x){
  
  namesMap <- c("DATA INICIAL"="DATA_INICIAL",
                "DATA FINAL" = "DATA_FINAL",
                "REGIÃO"="REGIAO",
                "MUNICÍPIO" = "MUNICIPIO",
                "NÚMERO DE POSTOS PESQUISADOS"="NUM_PESQUISADOS",
                "UNIDADE DE MEDIDA"="UNI_MEDIDA",
                "PREÇO MÉDIO REVENDA"="PRECO_MEDIO_REVENDA",
                "DESVIO PADRÃO REVENDA"="DESVIO_PADRAO_REVENDA",
                "PREÇO MÍNIMO REVENDA"="PRECO_MINIMO_REVENDA",
                "PREÇO MÁXIMO REVENDA"="PRECO_MAXIMO_REVENDA",
                "MARGEM MÉDIA REVENDA"="MARGEM_MEDIA_REVENDA",
                "COEF DE VARIAÇÃO REVENDA" = "COEF_DE_VARIACAO_REVENDA",
                "PREÇO MÉDIO DISTRIBUIÇÃO"="PRECO_MEDIO_DISTRIBUICAO",
                "DESVIO PADRÃO DISTRIBUIÇÃO"="DESVIO_PADRAO_DISTRIBUICAO",
                "PREÇO MÍNIMO DISTRIBUIÇÃO"="PRECO_MINIMO_DISTRIBUICAO",
                "PREÇO MÁXIMO DISTRIBUIÇÃO"="PRECO_MAXIMO_DISTRIBUICAO",
                "COEF DE VARIAÇÃO DISTRIBUIÇÃO"="COEF_DE_VARIACAO_DISTRIBUICAO")
  
  
  for(i in 1:length(namesMap)){
    x[x == names(namesMap)[i]] = namesMap[i]
  }
  return(x)
}



mDir <- "C:/Users/bteba/Downloads/Historico/2026-02-08/Precos na refinaria/"

tbl_0 <- read_excel(file.path(mDir, "2001 a 2012.xlsx"))
tbl_1 <- read_excel(file.path(mDir, "2013 a 2015.xlsx"))
tbl_2 <- read_excel(file.path(mDir, "2016 a 2018.xlsx"))
tbl_3 <- read_excel(file.path(mDir, "2019 a 2021.xlsx"))
tbl_4 <- read_excel(file.path(mDir, "2022 a 2025.xlsx"))




colnames(tbl_0) <- 
colnames(tbl_0)



"MÊS"                           "PRODUTO"                      
[3] "REGIÃO"                        "ESTADO"                       
[5] "MUNICÍPIO"                     "NÚMERO DE POSTOS PESQUISADOS" 
[7] "UNIDADE DE MEDIDA"             "PRECO MÉDIO REVENDA"          
[9] "DESVIO PADRÃO REVENDA"         "PRECO MÍNIMO REVENDA"         
[11] "PRECO MÁXIMO REVENDA"          "MARGEM MÉDIA REVENDA"         
[13] "COEF DE VARIAÇÃO REVENDA"      "PRECO MÉDIO DISTRIBUIÇÃO"     
[15] "DESVIO PADRÃO DISTRIBUIÇÃO"    "PRECO MÍNIMO DISTRIBUIÇÃO"    
[17] "PRECO MÁXIMO DISTRIBUIÇÃO"     "COEF DE VARIAÇÃO DISTRIBUIÇÃO"