
# Setup -------------------------------------------------------------------

rm(list = ls())

library(readxl)
library(dplyr)
library(ggplot2)



# Results Load ------------------------------------------------------------

mOutputDir <- "~/Github/ForecastingFuelPrices/TesteRestricaoRank/"
mFile <- file.path(mOutputDir, "results.xlsx")

results <- read_excel(mFile)
head(results)



m_lvl = c("TesteRestricaoRank01",
          "TesteRestricaoRank02a",
          "TesteRestricaoRank02b",
          "TesteRestricaoRank02c",
          "TesteRestricaoRank02d",
          "TesteRestricaoRank02e",
          "TesteRestricaoRank03a",
          "TesteRestricaoRank03b",
          "TesteRestricaoRank03c",
          "TesteRestricaoRank03d",
          "TesteRestricaoRank03e",
          "TesteRestricaoRank03f")
m_lbl = c("Rank01",
          "Rank02a",
          "Rank02b",
          "Rank02c",
          "Rank02d",
          "Rank02e",
          "Rank03a",
          "Rank03b",
          "Rank03c",
          "Rank03d",
          "Rank03e",
          "Rank03f")

m_lbl2 = c("Teste 01",
           "Teste 02",
           "Teste 02",
           "Teste 02",
           "Teste 02",
           "Teste 02",
           "Teste 03",
           "Teste 03",
           "Teste 03",
           "Teste 03",
           "Teste 03",
           "Teste 03")

results <- results %>% 
  mutate(Teste = factor(x = File, levels = m_lvl, labels = m_lbl, ordered = TRUE),
         Rank = factor(x = Rank_by_EM, levels = 0:3, labels = paste("R",0:3, sep = "_")),
         Teste2 = factor(x = File, levels = m_lvl, labels = m_lbl2))

results %>% 
  ggplot(mapping = aes(y = Teste, x = p_value)) + 
  geom_boxplot() + 
  # scale_fill_viridis(discrete = TRUE, alpha=0.6) +
  # geom_jitter(color="blue", size=0.9, height = 0.05, alpha=0.4, ) +
  # geom_point(color="blue", alpha=0.4, ) +
  geom_vline(xintercept = c(0.01), linetype = "dashed", colour = "Red") + 
  geom_vline(xintercept = c(0.05), linetype = "dashed", colour = "Blue") + 
  # geom_vline(xintercept = c(0.01, 0.05, 0.10), linetype = "dashed", colour = "Red") + 
  facet_wrap(~Rank) + 
  theme_bw() + 
  scale_x_continuous(breaks = c(0, 0.05, 0.1, 0.25, 0.50, 0.75, 1)) +
  labs(title = "Test Restrictions",
       x = "P-Value",
       y = NULL)


ggsave(filename = file.path(mOutputDir, "results_boxplot.png"),
       scale = 1,width = 8, height = 6, units = "in", dpi = 100)


results %>% 
  filter(Rank == "R_1") %>% 
  filter(Teste == "Rank01") %>% 
  ggplot(mapping = aes(y = Teste, x = p_value)) + 
  geom_boxplot() + 
  # geom_jitter(color="blue", size=0.9, height = 0.0, width =0, alpha=0.4, ) +
  geom_vline(xintercept = c(0.01), linetype = "dashed", colour = "Red") + 
  geom_vline(xintercept = c(0.05), linetype = "dashed", colour = "Blue") + 
  # geom_vline(xintercept = c(0.01, 0.05, 0.10), linetype = "dashed", colour = "Red") + 
  # facet_wrap(~RR) + 
  theme_bw() + 
  scale_x_continuous(breaks = c(0, 0.05, 0.01, 0.25, 0.50, 0.75, 1), minor_breaks = NULL) +
  labs(title = "Test Restrictions",
       subtitle = "Regions with rank 1",
       x = "P-Value",
       y = NULL)


ggsave(filename = file.path(mOutputDir, "results_boxplot_R1.png"),
       scale = 1,width = 8, height = 6, units = "in", dpi = 100)


results %>% 
  filter(Rank == "R_2") %>% 
  filter(grepl("Rank02",Teste)) %>% 
  ggplot(mapping = aes(y = Teste, x = p_value)) + 
  geom_boxplot() + 
  # geom_jitter(color="blue", size=0.9, height = 0.0, width =0, alpha=0.4, ) +
  geom_vline(xintercept = c(0.01), linetype = "dashed", colour = "Red") + 
  geom_vline(xintercept = c(0.05), linetype = "dashed", colour = "Blue") + 
  # geom_vline(xintercept = c(0.01, 0.05, 0.10), linetype = "dashed", colour = "Red") + 
  # facet_wrap(~RR) + 
  theme_bw() + 
  # xlim(0, 1) +
  scale_x_continuous(breaks = c(0, 0.01, 0.05, 0.25, 0.50, 0.75, 1), minor_breaks = NULL) +
  labs(title = "Test Restrictions",
       subtitle = "Regions with rank 2",
       x = "P-Value",
       y = NULL)

ggsave(filename = file.path(mOutputDir, "results_boxplot_R2.png"),
       scale = 1,width = 8, height = 6, units = "in", dpi = 100)


results %>% 
  filter(Rank == "R_3") %>% 
  filter(grepl("Rank03",Teste)) %>% 
  ggplot(mapping = aes(y = Teste, x = p_value)) + 
  geom_boxplot() + 
  # geom_jitter(color="blue", size=0.9, height = 0.0, width =0, alpha=0.4, ) +
  geom_vline(xintercept = c(0.01), linetype = "dashed", colour = "Red") +
  # geom_vline(xintercept = c(0.05), linetype = "dashed", colour = "Blue") + 
  # geom_vline(xintercept = c(0.01, 0.05, 0.10), linetype = "dashed", colour = "Red") + 
  # facet_wrap(~RR) + 
  theme_bw() + 
  # xlim(0, 1) +
  scale_x_continuous(breaks = c(0, 0.01, 0.05, 0.25, 0.50, 0.75, 1), minor_breaks = NULL) +
  labs(title = "Test Restrictions",
       subtitle = "Regions with rank 3",
       x = "P-Value",
       y = NULL)

ggsave(filename = file.path(mOutputDir, "results_boxplot_R3.png"),
       scale = 1,width = 8, height = 6, units = "in", dpi = 100)




results %>% 
  dplyr::select(region, Rank_by_EM, p_value, Teste) %>% 
  mutate(count = if_else(p_value >= 0.01, true = 1, false = 0)) %>% 
  pivot_wider(id_cols = c("region", "Rank_by_EM"), names_from = Teste, values_from = count) %>% 
  mutate( R1 = if_else(Rank01 >0, 1, 0),
          R2 = if_else((Rank02b + Rank02c + Rank02a + Rank02d) >0, 1, 0),
          R3 = if_else(Rank03a + Rank03b + Rank03c + Rank03d + Rank03e + Rank03f >0, 1, 0) ) %>% 
  # dplyr::select(region, Rank_by_EM, R1_s, R2_s, R3_s) %>% 
  group_by(Rank_by_EM) %>% 
  summarise(total = n(), 
            R1 = sum(R1),
            R2 = sum(R2),
            R3 = sum(R3),
            R02a  = sum(Rank02a),
            R02b  = sum(Rank02b),
            R02c  = sum(Rank02c),
            R02d  = sum(Rank02d),
            
            R03a  = sum(Rank03a),
            R03b  = sum(Rank03b),
            R03c  = sum(Rank03c),
            R03d  = sum(Rank03d),
            R03e  = sum(Rank03e),
            R03f  = sum(Rank03f),
            )



results %>% 
  dplyr::select(region, Rank_by_EM, p_value, Teste) %>% 
  filter(Rank_by_EM ==1) %>% 
  pivot_wider(id_cols = c("region", "Rank_by_EM"), names_from = Teste, values_from = p_value) %>% 
  print(n=50)
  