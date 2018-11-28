# Combine epoch data

library(readr)
library(dplyr)

commodities_200506 <- read_csv("./data/commodities_200506_SA2.csv")

commodities_201011 <- read_csv("./data/commodities_201011_SA2.csv", col_types = "")

# getting a warning message about parsing failures due to column types

colnames(commodities_200506)

colnames(commodities_201011)

commodities_epochs <- bind_rows(list('200506' = commodities_200506, '201011' = commodities_201011), .id = "epoch")
