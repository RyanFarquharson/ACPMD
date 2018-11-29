# Importing original .csv file containing 2015-16 ABS census data for the ACPMD.

library(readr)
library(dplyr)

#############

# At present, only the commodities data are available for the 2015-16 census

path1516 <- "./data/raw_data/201516/7121do004_201516.csv"

# Read in 71210do042_201011.csv ABS commodities data.
# Skipped first 4 columns.  Specified column names using TRUE which worked.  
# Used n_max so that the lower rows containing explanations were not included.
# Used guess_max in case default of 100 rows to guess data type did not capture some data with different types.

ABS_commodities_201516 <- read_csv(path1516, skip = 4, 
                                   col_names = TRUE,
                                   n_max = 84472, guess_max = 1500)

# Convert 'Estimate' column to double

ABS_commodities_201516$`Estimate` <- as.double(ABS_commodities_201516$`Estimate`)
ABS_commodities_201516$`Number of agricultural businesses` <- as.double(ABS_commodities_201516$`Number of agricultural businesses`)

write_csv(ABS_commodities_201516, "./data/ABS_commodities_201516.csv")

commodities_201516_ASGS <- rename(ABS_commodities_201516,
                                 ASGS_code = "Region code",
                                 ASGS_label = "Region label",
                                 Commodity_code = "Commodity code",
                                 Commodity_label = "Commodity description",
                                 Estimate = "Estimate",
                                 Estimate_RSE = "Estimate - Relative Standard Errors",
                                 Businesses = "Number of agricultural businesses",
                                 Businesses_RSE = "Number of agricultural businesses - Relative Standard Errors")

write_csv(commodities_201516_ASGS, "./data/commodities_201516_ASGS.csv")
