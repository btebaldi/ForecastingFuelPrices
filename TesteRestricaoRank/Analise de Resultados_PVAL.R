
# Setup -------------------------------------------------------------------

rm(list = ls())

library(readxl)
library(dplyr)
library(ggplot2)
library(tidyr)


# Results Load ------------------------------------------------------------

mOutputDir <- "C:/Users/bteba/Downloads/"
mFile <- file.path(mOutputDir, "mPvalS.xlsx")

results <- read_excel(mFile, range = cell_limits(ul = c(1,1), lr = c(NA, 23)))
head(results)

m_lvl <- c(1,2,3)
m_lbl <- c("Adm","Des","Liq")


results <- results %>% 
  mutate(Tipo = factor(Tipo, labels = m_lbl, levels = m_lvl))




results %>% 
  dplyr::select(-Linha) %>% 
  pivot_longer(cols = starts_with(c("Modelo",  "VECM", "GVAR_Classic")),
               names_to = "Model", 
               values_to = "Pval") %>% 
  mutate(Model = factor(Model,
                        levels = c(sprintf("Modelo_%d", 1:19), "GVAR_Classic", "VECM"),
                        labels = c(sprintf("Modelo_%d", 1:19), "GVAR_Classic", "VECM"),
                        ordered = TRUE)) %>% 
  ggplot() + 
  geom_boxplot(aes(y=Model, x = Pval)) + 
  facet_grid(~Tipo) + 
  theme_bw() +
  labs(y = NULL, x = "P-Value")





results %>% 
  dplyr::select(-Linha) %>% 
  pivot_longer(cols = starts_with(c("Modelo",  "VECM", "GVAR_Classic")),
               names_to = "Model", 
               values_to = "Pval") %>% 
  mutate(Model = factor(Model,
                        levels = c(sprintf("Modelo_%d", 1:19), "GVAR_Classic", "VECM"),
                        labels = c(sprintf("Modelo_%d", 1:19), "GVAR_Classic", "VECM"),
                        ordered = TRUE)) %>% 
  # filter(Pval > 0.99) %>%
  # count(Model, Tipo) %>%
  group_by(Model, Tipo) %>% summarise(n = median(Pval)) %>% 
  tidyr::pivot_wider(id_cols = Model, names_from = Tipo, values_from = n, values_fill = 0) %>% 
  print(n= 21)
