
# Understanding and Forecasting the Effects of Global Shocks on Fuel Prices: The Brazilian case

GitHub repository: ForecastingFuelPrices

## 📘 Repositório de Reprodução - Artigo "Understanding and Forecasting the Effects of Global Shocks on Fuel Prices: The Brazilian case"

Este repositório contém os materiais necessários para reprodução e extensão dos resultados apresentados no artigo aceito para publicação na revista *XXXX* <!--([https://revistas.usp.br/ee](https://revistas.usp.br/ee)):-->

**Título:** *Understanding and Forecasting the Effects of Global Shocks on Fuel Prices: The Brazilian case*
**Autores:** \[Redacted]
**Data:** Agosto de 2025

### 🧩 Conteúdo do Repositório
To be added
<!--
* 📂 `Base de dados/`: Bases de dados usadas no artigo  , como séries temporais de admissões/demissões por mesorregião, produção industrial e a matriz de conexões regionais (IBGE).
* 📂 `Export/`: Resultados principais do artigo, incluindo tabelas, gráficos e saídas do modelo.
* 📂 `GVAR_Toolbox2.0/`: Códigos em MATLAB utilizados para estimar o modelo GVAR, incluindo scripts auxiliares e de pré-processamento de dados. Utiliza a toolbox **GVAR Toolbox 2.0**.
* 📂 `scripts/`: Scripts adicionais. Utilizado na construção de base de dados e análises de resultados.
* 📂 `Videos/`: Vídeos explicativos com visualizações das previsões regionais de emprego sob diferentes cenários macroeconômicos.
-->


#### Scripts de construção da base de dados
file: 01_Construcao do banco de dados.R
Used to construct the database from the downloaded files. (the downloaded files are not provided due to size constrains.)

02_Juncao do banco_Agrupamento.R
Used to grup regions. The grouped regions are based on the configuration file "Cadastro de municipios.xlsx"

03_Analise exploratoria.R
Script used in Exploratori analisys. Not needed for the reproduction.

04_Analise de completude dos dados
Script used in Exploratori analisys. Not needed for the reproduction.

05_Cria bando de dados com buraco.R
Fill missing dates. The final database (db_Ox_com_buraco.rds) still has missing values, however for almost all dates the database is complete. Is is worth mentioning that the 2020 pandemic caused period of 9 weeks with out values. These periods were not inserted. 
 
06_Completa buracos com KF.R
Completa eventuais buracos na serie com um Filtro de Kalman. ao final a base  "db_Ox_sem_buraco.csv" é disponibilizada sem nenhum buraco.

07_Constroi matriz de pesos.R
Scrip que constroi a matrix de pesos utilizada no Gvar. Faz a leitura do database Ligacoes_entre_Cidades.xlsx para construir uma matriz de conexao que possa ser lida pelo OxMetrics.

08_Constroi serie de oil.R
Inclui serie de petroleo brent na base de dados. O preço é colocado como a média de preços na semana. O resultado é disponibilizado no arquivo "db_Oil.rds" (uma versao em csv tambme é disponibilizada)

09_Constroi serie de oil com dummies.R
Inclui serie de dummies semanais na base de dados. Utiliza a base de dados "db_Oil.rds" como entrada e gera duas base de dados (i) db_oil_forForecast.rds Com todo periodo de dados; (ii) "db_oil_withDummies.rds" que base de dados que vai até o ano de 2019 (exclusive)

10_ Constroi Serie com cambio.R
Inclui serie de cambio na base de dados. Utiliza a base de dados "db_oil_forForecast.rds" como entrada e gera duas base de dados (i) db_oil_forForecast2.rds Com todo periodo de dados; (ii) "db_oil_withDummies2.rds" que base de dados que vai até o ano de 2019 (exclusive)

#### Scripts de Analise Exploratoria de Dados
20 - Gera graficos de regioes.R

#### Scripts de Analise dos Resultados
21 - Interpreta matrix do Ox das regioes.R
Script para interpretação da Matriz feita no Ox para uma matriz do R.

22 - Gera forecasts das regioes.R
Script que gera a previsao dos dados baseado nos resultados encontrados.

23 - VECM model by region.R
Script que gera a modelo VECM para cada uma das regioes.

24 - Impulse response.R
Script que gera uma Funçao de Impulso (IRF) no modelo GVAR total. 

### 🔁 Reprodutibilidade

To be added
<!--
To be added
Todas as etapas do artigo — da preparação dos dados à estimação do modelo e à simulação de cenários — são totalmente reproduzíveis por meio dos scripts disponíveis. Consulte o arquivo `README.txt` em `GVAR_Toolbox2.0/` para instruções detalhadas de execução.
-->


<!--
### 📌 Modelos Disponíveis

Este repositório disponibiliza diferentes versões do modelo estimado, com variações que permitem explorar alternativas metodológicas e aprofundar a análise. Abaixo, uma breve descrição de cada versão:

* **`Meso17`**: Modelo principal utilizado no artigo, estimado com dados mensais de 2004 a 2016 para 137 mesorregiões brasileiras. Utiliza a configuração padrão descrita no texto final publicado.
* **`Meso17_AllTests`**: Versão idêntica ao modelo `Meso17`, porém configurada para gerar e imprimir todos os testes estatísticos disponíveis no **GVAR Toolbox**.
* **`Meso17_FullSample`**: Variante do modelo `Meso17` que utiliza toda a amostra disponível sem divisão entre períodos de estimação e previsão.
* **`Meso19`**: Extensão do modelo que trata explicitamente a mesorregião metropolitana de São Paulo como uma unidade dominante, incorporando seu impacto direto sobre as demais regiões de forma diferenciada.
-->

<!--
### 📌 Destaques do Artigo

* Estimação de um modelo GVAR para 137 mesorregiões brasileiras, com base em dados mensais de 2004 a 2016.
* Uso de uma matriz de pesos baseada em conexões econômicas entre municípios brasileiros (IBGE, 2008).
* Simulação de diferentes trajetórias de recuperação econômica após a recessão de 2014–2016, com foco em impactos regionais no emprego formal.
* Identificação de regiões mais e menos resilientes a choques macroeconômicos.

-->