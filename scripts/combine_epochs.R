# Combine epoch data

library(readr)
library(dplyr)

commodities_200506 <- read_csv("./data/commodities_200506_SA2.csv")
commodities_200506$Commodity_code <- as.character(commodities_200506$Commodity_code)

commodities_201011 <- read_csv("./data/commodities_201011_SA2.csv")
commodities_201011$Commodity_code <- as.character(commodities_201011$Commodity_code)

commodities_201516 <- read_csv("./data/commodities_201516_ASGS.csv")


# colnames(commodities_200506)
# colnames(commodities_201011)
# colnames(commodities_201516)

# combine census years for potential use in defining species and magement over epochs.

commodities_epochs <- bind_rows(list('200506' = commodities_200506, '201011' = commodities_201011, '201516' = commodities_201516),
                                .id = "census")

write_csv(commodities_epochs, "./data/commodities_epochs.csv")

