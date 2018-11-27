# Import concordance or correspondence tables to convert areas to ASGS SA2s

library(readr)
library(readxl)
library(dplyr)

path_conc_2006 <- "./data/raw_data/concordance/CA_SLA_2006_SA2_2011.xls"

excel_sheets(path_conc_2006)

concord_2006SLA_2011SA2 <- read_excel(path_conc_2006, 
                                      sheet = "Table 3", 
                                      col_names = c("SLA_MAINCODE_2006", "SLA_NAME_2006", "SA2 MAINCODE_2011", "SA2_NAME_2011", "RATIO", "PERCENTAGE"), 
                                      skip = 7, n_max = 4371)

write_csv(concord_2006SLA_2011SA2, "./data/concord_2006SLA_2011SA2.csv")
