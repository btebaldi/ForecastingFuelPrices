
# Setup -------------------------------------------------------------------
rm(list=ls())
# You should take care with readLines(...) and big files. Reading all lines at
# memory can be risky. Below is a example of how to read file and process just
# one line at time:


# Bibliotecas -------------------------------------------------------------

library(stringr)
library(dplyr)

getwd()
# Variaveis internas ------------------------------------------------------

fileName = "02_Check Weak Exo.out"

filepath = file.path(".", "Ox", fileName)

if(!file.exists(filepath)) {
  stop("Arquivo nao existe")
}

ReadCon  <- file(description = filepath, open = "r")
WriteCon <- file(description = "./Ox_Results.txt", open = "w")

ncount <- 0
ncount_2S  <- 0

tbl.results <- tibble(region = 1:110,
                      rank_normal = as.integer(NA),
                      rank_barlet = as.integer(NA),
                      rank_boot = as.integer(NA),
                      rank = as.integer(NA),
                      ExoTest = as.numeric(NA),
                      ExoTest_Boot = as.numeric(NA),
                      Zero_Rank = FALSE, 
                      Auto1 = as.numeric(NA),
                      Auto2 = as.numeric(NA),
                      Beta_Rest1 = as.numeric(NA),
                      Beta_Rest2 = as.numeric(NA),
                      Beta_Rest3 = as.numeric(NA),
                      Beta_Rest4 = as.numeric(NA) )

# "TESTE A RESTRICOES NO BETA: Regiao 1"
"Test of restrictions on beta"

while ( TRUE ) {
  
  # inicializa as variaveis
  # region_number <- 0  # Numero da Regiao
  rank <- NA            # Rank test
  
  rank_normal <- NA
  rank_barlet <- NA
  rank_boot <- NA
  
  ExoTest <- NA         # Weak Exo Test
  ExoTest_Boot <- NA    # Alpha Beta Test
  zerorank <- NA        # rank zero detectado
  WriteInfo <- FALSE
  
  Auto1 <- NA
  Auto2 <- NA
  
  betaRestriction <- NA
  
  #  Faz leitura da linha
  line = readLines(ReadCon, n = 1)
  
  # Se a linha tem tamanho zero entao para o processamento
  if ( length(line) == 0 ) {
    break
  }
  
  # verifica e o comeco do processamento
  if(stringr::str_detect(line, stringr::regex("-* Ox at .* on .* -*"))){
    # writeLines( text = line, con = WriteCon)
    print(line)
  }
  
  # verifica a regiao que foi skiped
  #   if(stringr::str_detect(line, stringr::regex(pattern2))){
  #     # writeLines( text = line, con = WriteCon)
  #     # writeLines( text = "No data", con = WriteCon)
  #     # writeLines( text = "No data", con = WriteCon)
  #     # writeLines( text = "No data", con = WriteCon)
  
  #     region_number <- stringr::str_match(line,  stringr::regex("(?<=SKIP: Regiao )\\d*"))
  #     WriteInfo <- TRUE
  
  #     print(line)
  #     print("No data")
  #     print("No data")
  #   }
  
  
  # verifica a regiao que foi detectado rank zero
  if(stringr::str_detect(line, stringr::regex("RANK ZERO DETECTADO"))){
    # writeLines(text = line, con = WriteCon)
    
    zerorank <- 1
    WriteInfo <- TRUE
    
    # print(line)
  }
  
  
  # verifica a regiao atual
  if(stringr::str_detect(line, stringr::regex("             Regiao "))){
    # writeLines( text = line, con = WriteCon)
    
    region_number <- stringr::str_match(line,  stringr::regex("(?<=             Regiao )\\d*"))
    WriteInfo <- TRUE
    print(line)
  }
  
  
  
  
  if(stringr::str_detect(line, stringr::regex("RANK ESTIMADO NORMAL: "))){
    # writeLines(text = line, con = WriteCon)
    
    rank_normal <- stringr::str_match(line,  stringr::regex("(?<=RANK ESTIMADO NORMAL: )\\d"))
    WriteInfo <- TRUE
    # print(line)
    # stop()
  }
  
  if(stringr::str_detect(line, stringr::regex("RANK ESTIMADO NORMAL_BARLET: "))){
    # writeLines(text = line, con = WriteCon)
    
    rank_barlet <- stringr::str_match(line,  stringr::regex("(?<=RANK ESTIMADO NORMAL_BARLET: )\\d"))
    WriteInfo <- TRUE
    # print(line)
    # stop()
  }
  
  if(stringr::str_detect(line, stringr::regex("RANK ESTIMADO BOOSTRAP: "))){
    # writeLines(text = line, con = WriteCon)
    
    rank_boot <- stringr::str_match(line,  stringr::regex("(?<=RANK ESTIMADO BOOSTRAP: )\\d"))
    WriteInfo <- TRUE
    # print(line)
    # stop()
  }  
  
  
  # verifica o Rank
  if(stringr::str_detect(line, stringr::regex("RANK TOTAL: "))){
    # writeLines(text = line, con = WriteCon)
    
    rank <- stringr::str_match(line,  stringr::regex("(?<=RANK TOTAL: )\\d"))
    WriteInfo <- TRUE
    print(line)
    # stop()
  }
  
  # Verifica a restrição em alpha e beta
  if(stringr::str_detect(line, stringr::regex("Test of restrictions on alpha( and beta)?:"))){
    # writeLines( text = line, con = WriteCon)
    ExoTest <- stringr::str_match(line,  stringr::regex("(?<=\\[).*(?=\\])"))
    WriteInfo <- TRUE
    # print(line)
    
    # Detecta se o teste passou ou nao.
    if(stringr::str_detect(line, stringr::regex("Test of restrictions on alpha:\\s*.*\\[.*\\]\\*{2}"))) {
      ncount_2S = ncount_2S + 1
    }
    ncount = ncount + 1
  }
  
  # Verifica a restrição em alpha (2020-11-18: A principio tera dois testes por regiao)
  if(stringr::str_detect(line, stringr::regex("Bootstrap test\\s+:"))){
    # writeLines(text = line, con = WriteCon)
    ExoTest_Boot <- stringr::str_match(line,  stringr::regex("(?<=\\[).*(?=\\])"))
    WriteInfo <- TRUE
    # print(line)
    
  }
  
  # Verifica autocorrelacao
  if(stringr::str_detect(line, stringr::regex("LM\\(1\\):\\s+Chi\\^2\\(36\\)"))){
    # # writeLines(text = line, con = WriteCon)
    Auto1 <- stringr::str_match(line,  stringr::regex("(?<=\\[).*(?=\\])"))
    WriteInfo <- TRUE
    # print(line)
  }
  
  if(stringr::str_detect(line, stringr::regex("LM\\(2\\):\\s+Chi\\^2\\(36\\)"))){
    # # writeLines(text = line, con = WriteCon)
    Auto2 <- stringr::str_match(line,  stringr::regex("(?<=\\[).*(?=\\])"))
    WriteInfo <- TRUE
    # print(line)
  }
  
  
  # Teste de restricao no beta
  if(stringr::str_detect(line, stringr::regex("Test of restrictions on beta:"))){
    # # writeLines(text = line, con = WriteCon)
    betaRestriction <- stringr::str_match(line,  stringr::regex("(?<=\\[).*(?=\\])"))
    WriteInfo <- TRUE
    print(line)
  }
  
  if(WriteInfo)
  {
    selctVector <- tbl.results$region == as.integer(region_number)
    
    if(!is.na(rank_normal)){
      tbl.results$rank_normal[selctVector] <- as.integer(rank_normal)
    }
    
    if(!is.na(rank_barlet)){
      tbl.results$rank_barlet[selctVector] <- as.integer(rank_barlet)
    }
    
    if(!is.na(rank_boot)){
      tbl.results$rank_boot[selctVector] <- as.integer(rank_boot)
    }
    
    if(!is.na(rank)){
      tbl.results$rank[selctVector] <- as.integer(rank)
    }
    
    if(!is.na(ExoTest)){
      tbl.results$ExoTest[selctVector] <- as.numeric(ExoTest)  
    }
    
    if(!is.na(ExoTest_Boot)){
      tbl.results$ExoTest_Boot[selctVector] <- as.numeric(ExoTest_Boot)  
      # stop()
    }
    
    if(!is.na(zerorank)){
      tbl.results$Zero_Rank[selctVector] <- TRUE  
    }
    
    if(!is.na(Auto1)){
      tbl.results$Auto1[selctVector] <- as.numeric(Auto1)
    }
    
    if(!is.na(Auto2)){
      tbl.results$Auto2[selctVector] <- as.numeric(Auto2)
    }
    
    if(!is.na(betaRestriction))
    {
      if(is.na(tbl.results$Beta_Rest1[selctVector])){
        tbl.results$Beta_Rest1[selctVector] <- as.numeric(betaRestriction)
        
      } else if(is.na(tbl.results$Beta_Rest2[selctVector])) {
        tbl.results$Beta_Rest2[selctVector] <- as.numeric(betaRestriction)
        
      }else if(is.na(tbl.results$Beta_Rest3[selctVector])){
        tbl.results$Beta_Rest3[selctVector] <- as.numeric(betaRestriction)
        
      }else if (is.na(tbl.results$Beta_Rest4[selctVector])) {
        tbl.results$Beta_Rest4[selctVector] <- as.numeric(betaRestriction)
        
      } else { 
        stop("mais do que previsto")}
    } 
    
  }
  
}

close(ReadCon)
close(WriteCon)

# Avalia restricoes no Beta -----------------------------------------------

# Avalia restricoes no Beta
# tbl.results %>% dplyr::filter(rank == 0) %>% View()
# tbl.results %>% dplyr::filter(rank > 0) %>% View()

tbl.results %>% 
  select(rank_normal, rank_barlet, rank_boot) %>% 
  pivot_longer(cols = everything()) %>% 
  group_by(name, value) %>% 
  summarise(total = n())

tbl.results %>% 
  filter(rank >0) %>% filter(ExoTest >0.01)

tbl.results %>% 
  filter(rank >0) %>%
  filter(ExoTest >0.01)

tbl.results %>% 
  filter(rank >0) %>%
  filter(ExoTest_Boot >0.01)

tbl.results %>% 
  filter(rank >0) %>%
  filter(Beta_Rest1 < 0.01)

tbl.results %>% 
  filter(rank >0) %>%
  filter(Beta_Rest2 < 0.01 | Beta_Rest1 < 0.01)


  View()
  dplyr::filter(rank > 0) %>% 
  dplyr::select(Beta_Rest1, Beta_Rest2, Beta_Rest3, Beta_Rest4 ) %>% 
  mutate_at(.vars = c("Beta_Rest1", "Beta_Rest2", "Beta_Rest3", "Beta_Rest4"),
            .funs = function(x){as.numeric( x < 0.01)}) %>%
  # summary()
  tidyr::pivot_longer(cols = starts_with("Beta_")) %>% 
  mutate(name2 = factor(name, 
                       labels = c("[beta E G E* G*]: * 0 * 0",
                                  "[beta E G E* G*]: * * 0 0",
                                  "[beta E G E* G*]: 0 * 0 *",
                                  "[beta E G E* G*]: 0 0 * *"),
                       levels = c("Beta_Rest1",
                                  "Beta_Rest2",
                                  "Beta_Rest3",
                                  "Beta_Rest4"))) %>% 
group_by(name2) %>% 
  summarise(Rejeta_nula_1pc = sum(value),
            Total = n())
ggplot() + 
  geom_boxplot(aes(x = name, y = value))



# Test of restrictions on alpha -------------------------------------------

# ncount_2S: total de regioes que passaram no teste de alpha
# ncount: total de regioes 
cat(sprintf("Total de regioes que nao passaram: %d\nTotal que passaram: %d", ncount - ncount_2S, ncount_2S))

tbl.results <- tbl.results %>% 
  mutate(ExoTest_Info = if_else(ExoTest >= 0.01, TRUE, FALSE, missing = NA),
         ExoTest_Boot_Info = if_else(ExoTest_Boot >= 0.01, TRUE, FALSE, missing = NA),
         Overall = ExoTest_Info | ExoTest_Boot_Info,
         Max_auto = pmax(Auto1, Auto2),
         Max_rank = pmax(rank_normal , rank_barlet , rank_boot  )
  )

View(tbl.results)

print("Exogeniedade fraca por econometria")
tbl.results %>%
  count(ExoTest_Info) %>% 
  print()

print("Exogeniedade fraca por bootstrap")
tbl.results %>%
  count(ExoTest_Boot_Info) %>% 
  print()


print("Exogeniedade fraca")
tbl.results %>%
  count(Overall) %>% 
  print()

print("Autocorrelacao")
tbl.results %>% 
  mutate(Max_auto_TF = Max_auto > 0.01) %>% 
  count(Max_auto_TF) %>% 
  print()

print("Rank")
tbl.results %>%
  count(rank_boot) %>%
  print()

print("Rank")
tbl.results %>%
  count(rank) %>%
  print()



# readr::write_excel_csv(x=tbl.results,
#                        file = sprintf("%s on %s.txt", stringr::str_match(fileName,  stringr::regex(".*(?=\\.\\w{3})")), Sys.Date()))


SaveMatrixForOx <- function(Matrix, file_name, comment = NULL){
  if(is.null(comment)){comment = file_name}
  
  file.name <- sprintf("./export/%s", file_name)
  
  fileConn <- file(file.name)
  writeLines( text = sprintf("%1$d %2$d // A %1$d by %2$d matrix (%3$s)", 
                             dim(Matrix)[1],
                             dim(Matrix)[2],
                             comment),
              con = fileConn)
  close(fileConn)
  
  write.table(x = Matrix, file = file.name,
              append = TRUE,
              col.names = FALSE,
              row.names = FALSE)
}

rankOfRegions <- tbl.results %>% select(rank_boot)
SaveMatrixForOx(Matrix = rankOfRegions, file_name = "rankOfRegions.mat", comment = "(Indication of the rank of the regions)")

