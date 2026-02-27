#' Tese Capitulo 2 - Analise de precos de gasolina, alcool e Oleo Diesel
#' 
#' Script para geração dos Forecasts das series.
#' 
#' Author: Bruno Tebaldi de Queiroz Barbosa
#' 
#' Data: 2022-01-06
#' 


# setup -------------------------------------------------------------------

rm(list=ls())
library(readxl)
library(readr)
library(tidyr)
library(dplyr)
library(stringr)
library(ggplot2)
library(lubridate)
library(cowplot)


dir <- "2025-06-03"
dir <- "2025-06-09"
dir <- "2025-05-30"


# User difened functions --------------------------------------------------

mDiff <- function(x){
  ret <- x - dplyr::lag(x)
  ret[1] <- 0
  return(ret)
}


# Data Load ---------------------------------------------------------------

# export_file <- file.path("Ox", "mat_files", "Result_Matrix", dir, file.name)
# main_path <- dirname(export_file)
main_path <- file.path("Ox", "mat_files", "Result_Matrix", dir)

# Leitura das matrizes de lag.
mGy_Inv <- readRDS(file.path(main_path, "mGy_inv.rds"))
mLag1 <- readRDS(file.path(main_path, "mGy_inv_X_mGyL1.rds"))
mLag2 <- readRDS(file.path(main_path, "mGy_inv_X_mGyL2.rds"))
mLag3 <- readRDS(file.path(main_path, "mGy_inv_X_mGyL3.rds"))

mLag4 <- readRDS(file.path(main_path, "mGy_inv_X_mGyL4.rds"))
mLag5 <- readRDS(file.path(main_path, "mGy_inv_X_mGyL5.rds"))
mLag6 <- readRDS(file.path(main_path, "mGy_inv_X_mGyL6.rds"))

mLag7 <- readRDS(file.path(main_path, "mGy_inv_X_mGyL7.rds"))
mLag8 <- readRDS(file.path(main_path, "mGy_inv_X_mGyL8.rds"))

# Carrega matriz de coeficiente de longo prazo
mLagLR <- readRDS(file.path(main_path, "mGy_inv_X_mL.rds"))

# Carrega matriz de coeficiente de constante e dummies sazonais
mLagDm <- readRDS(file.path(main_path, "mGy_inv_X_mC.rds"))

#  seleciona as colunas: constante + dummies (51)
mLagDm <- mLagDm[, 1:52]

colnames(mLagDm) <-  c("CONST", "Seasonal", paste("Seasonal", 1:50, sep = ""))

mX <- readxl::read_excel("scripts/X para IRF.xlsx", range = "B17:B2015")
mX.df <- readxl::read_excel("scripts/X para IRF.xlsx", range = "A31:C3019", sheet = "Planilha2")
mX <- data.matrix(mX.df[, 2])
row.names(mX) <- sprintf("%s_t%d", mX.df$name, mX.df$time)

# Calculando os parametros do VAR -----------------------------------------

I  <- diag(nrow(mLagLR))
Ze <- I*0
L1 <- mLag1 + I + mLagLR
L2 <- mLag2 - mLag1
L3 <- mLag3 - mLag2
L4 <- mLag4 - mLag3
L5 <- mLag5 - mLag4
L6 <- mLag6 - mLag5
L7 <- mLag7 - mLag6
L8 <- mLag8 - mLag7
L9 <- - mLag8

a1 <- cbind(L1, L2, L3, L4, L5, L6, L7, L8, L9)
a2 <- cbind( I, Ze, Ze, Ze, Ze, Ze, Ze, Ze, Ze)
a3 <- cbind(Ze,  I, Ze, Ze, Ze, Ze, Ze, Ze, Ze)
a4 <- cbind(Ze, Ze,  I, Ze, Ze, Ze, Ze, Ze, Ze)
a5 <- cbind(Ze, Ze, Ze,  I, Ze, Ze, Ze, Ze, Ze)
a6 <- cbind(Ze, Ze, Ze, Ze,  I, Ze, Ze, Ze, Ze)
a7 <- cbind(Ze, Ze, Ze, Ze, Ze,  I, Ze, Ze, Ze)
a8 <- cbind(Ze, Ze, Ze, Ze, Ze, Ze,  I, Ze, Ze)
a9 <- cbind(Ze, Ze, Ze, Ze, Ze, Ze, Ze,  I, Ze)

row.names(a1) <- c("brent", "Cambio", paste("R", sort(rep(1:110, 3)), c("E", "D", "G"), sep="_"))
# row.names(a2) <- c("brent", "Cambio", paste("R", sort(rep(1:110, 3)), c("E", "D", "G"), sep="_"))
# row.names(a3) <- c("brent", "Cambio", paste("R", sort(rep(1:110, 3)), c("E", "D", "G"), sep="_"))
# row.names(a4) <- c("brent", "Cambio", paste("R", sort(rep(1:110, 3)), c("E", "D", "G"), sep="_"))
# row.names(a5) <- c("brent", "Cambio", paste("R", sort(rep(1:110, 3)), c("E", "D", "G"), sep="_"))
# row.names(a6) <- c("brent", "Cambio", paste("R", sort(rep(1:110, 3)), c("E", "D", "G"), sep="_"))
# row.names(a7) <- c("brent", "Cambio", paste("R", sort(rep(1:110, 3)), c("E", "D", "G"), sep="_"))
# row.names(a8) <- c("brent", "Cambio", paste("R", sort(rep(1:110, 3)), c("E", "D", "G"), sep="_"))
# row.names(a9) <- c("brent", "Cambio", paste("R", sort(rep(1:110, 3)), c("E", "D", "G"), sep="_"))

mF <- rbind(a1, a2, a3, a4, a5, a6, a7, a8, a9)

if(FALSE){
varEigen <- eigen(mF)
Mod(varEigen$values[1:50])}

which(row.names(a1) == "R_75_E") # Sao Paulo
which(row.names(a1) == "R_75_D") # Sao Paulo
which(row.names(a1) == "R_75_G") # Sao Paulo
# which(row.names(a1) == "R_62_G") # RJ
# which(row.names(a1) == "R_109_G") # DF
# dim(L1)

# Construcao do choque ----------------------------------------------------

# Construcao da matriz que vai conter o choque
mShock <- matrix(c(0, 0), nrow = nrow(mLagLR), ncol=1)
# mShock <- matrix(c(0, 0.05), nrow = nrow(mLagLR), ncol=1)
names_mShock = c("brent", "Cambio", paste("R", sort(rep(1:110, 3)), c("E", "D", "G"), sep="_"))
# row.names(mShock) = c("brent", "Cambio", paste("R", sort(rep(1:110, 2)), c("E", "G"), sep="_"))
# mShock[1, 1] <- 1 # coloco choque zero para brent e FX
mShock[1, 1] <- 1 # coloco choque zero para brent e FX
# mShock[227, 1] <- 1 # coloco choque zero para brent e FX
# mShock[152, 1] <- 1 # coloco choque zero para brent e FX

# calcula o choque distribuido globalmente
mShock <- mGy_Inv %*% mShock

# complementa com zero o restante do vetor.
mShock <- rbind(mShock, matrix(0, nrow = (ncol(mF)-nrow(mShock)), ncol = 1))

# total de periodos que vamos utilizar
n <- 12

# Inicializa os vetores que vao conter a resposta dos choques tanto em X quanto em erro 
# response <- matrix(NA, nrow = n, ncol = 331)
# IRF <- matrix(NA, nrow = n, ncol = 222)
shock.response <- matrix(NA, nrow = 332*9, ncol = n)
clean.response <- matrix(NA, nrow = 332*9, ncol = n)

# i <- 1
# for(i in 1:n){
#   if(i == 1){
#     mShock.effect <- mShock
#     mX.effect <- mF %*% mX
#   } else {
#     mShock.effect <- mF %*% mShock.effect
#     mX.effect <- mF %*% mX.effect
#   }
#   
#   shock.response[i, ] <- mShock.effect[1:222,1] + mX.effect[1:222,1]
#   clean.response[i, ] <- mShock.effect[1:222,1] + mX.effect[1:222,1]
#   
# }

mu <- rbind(as.matrix(mLagDm[, 1]), matrix(0, nrow = (ncol(mF)-nrow(mLagDm)), ncol = 1))

i <- 1
for(i in 1:n){
  if(i == 1){
    shock.response[ , i] <- mF %*% mX + mu + mShock
    clean.response[ , i] <- mF %*% mX + mu
  } else {
    shock.response[ , i] <- mF %*% shock.response[ , i-1]
    clean.response[ , i] <- mF %*% clean.response[ , i-1]
  }
}

# Construcao do IRF -------------------------------------------------------

# Calcula o IRF
IRF <- shock.response[1:332, ] - clean.response[1:332, ]
IRF <- t(IRF)
dim(IRF)
colnames(IRF) <- c("brent", "cambio", paste("R", sort(rep(1:110, 3)), c("E","D", "G"), sep="_"))
# IRF <- rbind(matrix(0, ncol = ncol(IRF), nrow = 1), IRF)
# colnames(response) <- c("brent", paste("R", sort(rep(1:110, 3)), c("E", "D","G"), sep="_"))
response.df <- as_tibble(IRF)
response.df$period <- 1:n



# Grafico -----------------------------------------------------------------



regiao <- c("Sao Paulo" = 75,
            "Rio de Janeiro" = 62,
            "Dist. Federal" = 109,
            "Belo Horizonte" = 46,
            "Salvador" = 39)

regiao2 <- c("SAO JOSE DO RIO PRETO" =  63,
             "RIBEIRAO PRETO" = 64,
             "ARACATUBA" = 65,
             "BOTUCATU" = 66,
             "ARARAQUARA" = 67,
             "ARARAS" = 68,
             "CAMPINAS" = 69,
             "MARILIA" = 71,
             "ADAMANTINA" = 70,
             "OURINHOS" = 72,
             "BRAGANCA PAULISTA" = 73,
             "CAMPOS DO JORDAO" = 74,
             "ITANHAEM" = 76,
             "RIO DE JANEIRO" = 62,
             "DIST. FEDERAL" = 109,
             "BELO HORIZONTE" = 46,
             "SAO PAULO" = 75,
             "CACOAL" = 2,
             "SALVADOR" = 39)

# regiao <- regiao2
i=1
for(i in seq_along(regiao)){
  g1 <- response.df %>% 
    select(period,
           Etanol = sprintf("R_%d_E",regiao[i]),
           Diesel = sprintf("R_%d_D",regiao[i]),
           Gasolina = sprintf("R_%d_G",regiao[i]))  %>% 
    # mutate_at(.vars = c("Etanol", "Gasolina"), .funs = mDiff) %>%
    ggplot() +
    geom_point(aes(x=period, y=Etanol, colour="Hydrous ethanol"), size=1) +
    geom_line(aes(x=period, y=Etanol, colour="Hydrous ethanol"), linetype = "solid") +
    geom_point(aes(x=period, y=Gasolina, colour="Regular gasoline"), size=1) +
    geom_line(aes(x=period, y=Gasolina, colour="Regular gasoline"), linetype = "solid") +
    geom_point(aes(x=period, y=Diesel, colour="Diesel"), size=1) +
    geom_line(aes(x=period, y=Diesel, colour="Diesel"), linetype = "solid") +
    geom_hline(yintercept = 0) +
    theme_bw() +
    theme(legend.position = "bottom") +
    scale_x_continuous(breaks = 1:n) +
    # scale_y_continuous(breaks = (-5:5)/50, limits = c(-10, 10)/100) +
    labs(title = sprintf("%s", names(regiao)[i]),
         subtitle = "Impulse Response Function - Long Run",
         # subtitle = "Impulse Response Function - Shor run effects",
         colour = NULL,
         y=NULL,
         x=NULL,
         caption = "Elaborated by the author") +
    guides(color = guide_legend(override.aes = list(linetype = c(1, 1, 1) ) ) )
  
  print(g1)
  
  ggsave(filename = sprintf("./Graficos/IRF/%s/IRF - Shock in %s - region %s (%s).png",
                            dir, names_mShock[which(mShock[,1] ==1)], names(regiao)[i], dir),
         plot = g1,
         units = "in",
         width = 8, height = 6,
         dpi = 100,
         create.dir = TRUE)
  
}

# saveRDS(object = response.df, file = sprintf("./Graficos/IRF/%s/db_IRF_response (%s).rds", dir, dir))




response.df %>% 
  select(period,
         ends_with("_E"))  %>%
  pivot_longer(cols =  -period) %>% 
  # mutate_at(.vars = c("Etanol", "Gasolina"), .funs = mDiff) %>%
  ggplot() +
  # geom_point(aes(x=period, y=Etanol, colour="Hydrous ethanol"), size=1) +
  # geom_line(aes(x=period, y=Etanol, colour="Hydrous ethanol"), linetype = "dotted") +
  # geom_point(aes(x=period, y=Gasolina), size=1) +
  geom_line(aes(x=period, y=value, group = name), linetype = "solid", alpha = 0.2, colour = "blue") +
  geom_smooth(aes(x = period, y =y),
              linetype = "solid",
              # alpha = 0.2,
              data = response.df %>%
                select(period, ends_with("_E")) %>%
                pivot_longer(cols =  -period) %>% group_by(period) %>% summarise(y = mean(value)),
              colour = "red", se = FALSE) +
  geom_hline(yintercept = 0) +
  theme_bw() +
  theme(legend.position = "bottom") +
  scale_x_continuous(breaks = 1:n) +
  labs(title = "Impulse Response Function - Long Run",
       subtitle = "All regions - Ethanol",
       # subtitle = "Impulse Response Function - Shor run effects",
       colour = NULL,
       y=NULL,
       x=NULL,
       caption = "Elaborated by the author") +
  guides(color = guide_legend(override.aes = list(linetype = c(1, 1) ) ) )


ggsave(filename = sprintf("./Graficos/IRF/%s/IRF - Shock in %s - ALCOOL all regions.png",
                          dir,
                          names_mShock[which(mShock[,1] ==1)]),
       # plot = g1,
       units = "in",
       width = 8, height = 6,
       dpi = 100,
       create.dir = TRUE)

response.df %>% 
  select(period,
         ends_with("_G"))  %>%
  pivot_longer(cols =  -period) %>% 
  # mutate_at(.vars = c("Etanol", "Gasolina"), .funs = mDiff) %>%
  ggplot() +
  # geom_point(aes(x=period, y=Etanol, colour="Hydrous ethanol"), size=1) +
  # geom_line(aes(x=period, y=Etanol, colour="Hydrous ethanol"), linetype = "dotted") +
  # geom_point(aes(x=period, y=Gasolina), size=1) +
  geom_line(aes(x=period, y=value, group = name), linetype = "solid", alpha = 0.2, colour = "blue") +
  geom_smooth(aes(x = period, y =y),
              linetype = "solid",
              # alpha = 0.2,
              data = response.df %>%
                select(period, ends_with("_G")) %>%
                pivot_longer(cols =  -period) %>% group_by(period) %>% summarise(y = mean(value)),
              colour = "red", se = FALSE) +
  geom_hline(yintercept = 0) +
  theme_bw() +
  theme(legend.position = "bottom") +
  scale_x_continuous(breaks = 1:n) +
  labs(title = "Impulse Response Function - Long Run",
       subtitle = "All regions - Gasolina",
       # subtitle = "Impulse Response Function - Shor run effects",
       colour = NULL,
       y=NULL,
       x=NULL,
       caption = "Elaborated by the author") +
  guides(color = guide_legend(override.aes = list(linetype = c(1, 1) ) ) )

ggsave(filename = sprintf("./Graficos/IRF/%s/IRF - Shock in %s - GASOLINE all regions.png",
                          dir,
                          names_mShock[which(mShock[,1] ==1)]),
       # plot = g1,
       units = "in",
       width = 8, height = 6,
       dpi = 100,
       create.dir = TRUE)


response.df %>% 
  select(period,
         ends_with("_D")) %>%
  pivot_longer(cols =  -period) %>% 
  # mutate_at(.vars = c("Etanol", "Gasolina"), .funs = mDiff) %>%
  ggplot() +
  # geom_point(aes(x=period, y=Etanol, colour="Hydrous ethanol"), size=1) +
  # geom_line(aes(x=period, y=Etanol, colour="Hydrous ethanol"), linetype = "dotted") +
  # geom_point(aes(x=period, y=Gasolina), size=1) +
  # geom_line(aes(x=period, y=value, group = name), linetype = "solid", alpha = 0.2, colour = "blue") +
  geom_line(aes(x=period, y=value, group = name), linetype = "solid", alpha = 0.2, colour = "blue") +
  geom_smooth(aes(x = period, y =y),
              linetype = "solid",
              # alpha = 0.2,
              data = response.df %>%
                select(period, ends_with("_D")) %>%
                pivot_longer(cols =  -period) %>% group_by(period) %>% summarise(y = mean(value)),
              colour = "red", se = FALSE) +
  geom_hline(yintercept = 0) +
  theme_bw() +
  theme(legend.position = "bottom") +
  scale_x_continuous(breaks = 1:n) +
  labs(title = "Impulse Response Function - Long Run",
       subtitle = "All regions - Diesel",
       # subtitle = "Impulse Response Function - Shor run effects",
       colour = NULL,
       y=NULL,
       x=NULL,
       caption = "Elaborated by the author") +
  guides(color = guide_legend(override.aes = list(linetype = c(1, 1) ) ) )


ggsave(filename = sprintf("./Graficos/IRF/%s/IRF - Shock in %s - DIESEL all regions.png",
                          dir,
                          names_mShock[which(mShock[,1] ==1)]),
       # plot = g1,
       units = "in",
       width = 8, height = 6,
       dpi = 100,
       create.dir = TRUE)


response.df %>% 
  select(period, brent, cambio)  %>%
  pivot_longer(cols =  -period) %>% 
  # mutate_at(.vars = c("Etanol", "Gasolina"), .funs = mDiff) %>%
  ggplot() +
  # geom_point(aes(x=period, y=Etanol, colour="Hydrous ethanol"), size=1) +
  # geom_line(aes(x=period, y=Etanol, colour="Hydrous ethanol"), linetype = "dotted") +
  # geom_point(aes(x=period, y=Gasolina), size=1) +
  geom_line(aes(x=period, y=value, colour = name), linetype = "solid", size = 1) +
  geom_hline(yintercept = 0) +
  theme_bw() +
  theme(legend.position = "bottom") +
  scale_x_continuous(breaks = 1:n) +
  labs(title = "Impulse Response Function - Long Run",
       subtitle = "All regions - brent e cambio",
       # subtitle = "Impulse Response Function - Shor run effects",
       colour = NULL,
       y=NULL,
       x=NULL,
       caption = "Elaborated by the author") +
  guides(color = guide_legend(override.aes = list(linetype = c(1, 1) ) ) )
