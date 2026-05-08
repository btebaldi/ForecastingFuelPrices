
# Setup -------------------------------------------------------------------

rm(list = ls())

library(readxl)
library(dplyr)
library(ggplot2)



# Results Load ------------------------------------------------------------

mOutputDir <- "C:/Users/bteba/OneDrive/TesteRestricaoRank"
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
          "TesteRestricaoRank03d")
m_lbl = c("Rank01",
          "Rank02a",
          "Rank02b",
          "Rank02c",
          "Rank02d",
          "Rank02e",
          "Rank03a",
          "Rank03b",
          "Rank03c",
          "Rank03d")

results <- results %>% 
  mutate(Teste = factor(x = File, levels = m_lvl, labels = m_lbl, ordered = TRUE),
         RR = factor(x = Rank_by_EM, levels = 0:3, labels = paste("R",0:3, sep = "_")))

results <- results %>% filter(Teste != "Rank02e")


results %>% 
  ggplot(mapping = aes(y = Teste, x = p_value)) + 
  geom_boxplot() + 
  # scale_fill_viridis(discrete = TRUE, alpha=0.6) +
  # geom_jitter(color="blue", size=0.9, height = 0.05, alpha=0.4, ) +
  # geom_point(color="blue", alpha=0.4, ) +
  geom_vline(xintercept = c(0.01), linetype = "dashed", colour = "Red") + 
  geom_vline(xintercept = c(0.05), linetype = "dashed", colour = "Blue") + 
  # geom_vline(xintercept = c(0.01, 0.05, 0.10), linetype = "dashed", colour = "Red") + 
  facet_wrap(~RR) + 
  theme_bw() + 
  scale_x_continuous(breaks = c(0, 0.05, 0.1, 0.25, 0.50, 0.75, 1)) +
  labs(title = "Test Restrictions",
       x = "P-Value",
       y = NULL)


ggsave(filename = file.path(mOutputDir, "results_boxplot.png"),
       scale = 1,width = 8, height = 6, units = "in", dpi = 100)


results %>% 
  filter(RR == "R_1") %>% 
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
  filter(RR == "R_2") %>% 
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
  filter(RR == "R_3") %>% 
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
