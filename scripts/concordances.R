# Importing concordances to convert areas to ASGS SA2s

library(readr)
library(readxl)
library(dplyr)

path_conc_2006 <- "./data/raw_data/concordance/concord_2006_SLAs.xlsx"

excel_sheets(path_conc_2006)

concord_2006SLA_SA2 <- read_excel(path_conc_2006, sheet = 1, col_names = TRUE)

SLA_ID_2006 <- read_excel(path_conc_2006, sheet = 2, col_names = TRUE)
