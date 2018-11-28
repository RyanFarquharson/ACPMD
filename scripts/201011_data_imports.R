# Importing original files containing 2010-11 ABS census data for the ACPMD.

library(readr)
library(readxl)
library(dplyr)

#############

# First, the commodities data.

path1 <- "./data/raw_data/201011/71210do042_201011.csv"

# Read in 71210do042_201011.csv ABS commodities data.
# Skipped first 5 columns.  Specified column names since skip was used.  
# Used n_max so that the lower rows containing explanations were not included.
# Used guess_max because default of 100 rows to guess data type did not capture some data with different types e.g. Commodit - Codes row 1298...

ABS_commodities_201011 <- read_csv(path1, skip = 5, col_names = c("ASGS - Codes","ASGS - Labels","EVAO cutoff - Codes","EVAO cutoff - Labels","Commodity - Codes","Commodity - Labels",
"Estimated value (Number)", "Estimate - Relative Standard Error (Percent)", "Number of agricultural businesses",
"Number of agricultural businesses - Relative Standard Error (Percent)"), n_max = 285646, guess_max = 1500)

# Convert 'Estimated value(Number)' column to double

ABS_commodities_201011$`Estimated value (Number)` <- as.double(ABS_commodities_201011$`Estimated value (Number)`)

write_csv(ABS_commodities_201011, "./data/ABS_commodities_201011.csv")

# Rename ABS_commodities_201011 to get consistent column names across all years
# Decide on naming:
# ASGS_code
# ASGS_label
# EVAO_code
# EVAO_label
# Commodity_code
# Commodity_label
# Estimate
# Estimate_RSE
# Businesses
# Businesses_RSE

commodities_201011_SA2 <- ABS_commodities_201011

commodities_201011_SA2 <- rename(commodities_201011_SA2, 
       ASGS_code = "ASGS - Codes",
       ASGS_label = "ASGS - Labels",
       EVAO_code = "EVAO cutoff - Codes",
       EVAO_label = "EVAO cutoff - Labels",
       Commodity_code = "Commodity - Codes",
       Commodity_label = "Commodity - Labels",
       Estimate = "Estimated value (Number)",
       Estimate_RSE = "Estimate - Relative Standard Error (Percent)",
       Businesses = "Number of agricultural businesses",
       Businesses_RSE = "Number of agricultural businesses - Relative Standard Error (Percent)") 

write_csv(commodities_201011_SA2, "./data/commodities_201011_SA2.csv")

# Create a list of commodity codes and labels

ABS_commodities_201011_categories <-
  ABS_commodities_201011%>% 
  select('Commodity - Codes', 'Commodity - Labels') %>%
  distinct

write_csv(ABS_commodities_201011_categories, "./data/ABS_commodities_201011_categories.csv")


#############

# Now for the management data
# Here we attemp to import data from a .xls file downloaded from ABS.  Without explanantion, read_excel cannot open the file.  
# By opening it in excel and saving at as a .xlsx file, readxl now works.

path2 <- "./data/raw_data/201011/71210do043_201011.xls"
path3 <- "./data/raw_data/201011/71210do043_201011.xlsx"

excel_sheets(path3)

# Read in the data tables for each of the 3 tabs for each EVAO

ABS_management_201011_OB <- read_excel(path3, sheet = "OB", skip = 5, n_max = 37316,  
                                    col_names = TRUE)
ABS_management_201011_AZ <- read_excel(path3, sheet = "AZ", skip = 5, n_max = 26253,  
                                       col_names = TRUE)
ABS_management_201011_AA <- read_excel(path3, sheet = "AA", skip = 5, n_max = 30478,  
                                       col_names = TRUE)

# The 'Estimate' column of OB contains characters, whereas for AZ and AA the data type is a double.  
# Could make AZ and AA chr also, but we will want to do calculations with Estimate.
# So I used as.double to coerce ABS_management_201001_OB$Estimate to a double, which creates NAs where the character string is not a numeric.

ABS_management_201011_OB$Estimate <- as.double(ABS_management_201011_OB$Estimate)

# Create a list of the 3 EVAO tables

ABS_management_201011_list <- list(ABS_management_201011_OB, ABS_management_201011_AZ, ABS_management_201011_AA)

# Combine the 3 EVAO tables into a single table

ABS_management_201011 <- bind_rows(ABS_management_201011_list)

write_csv(ABS_management_201011, "./data/ABS_management_201011.csv")

# Create a table of codes and item descriptions

ABS_management_201011_management_categories <-
  ABS_management_201011%>% 
  select('Data item code', 'Data item description') %>%
  distinct

write_csv(ABS_management_201011_management_categories, "./data/ABS_management_201011_categories.csv")
