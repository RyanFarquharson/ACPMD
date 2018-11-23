# Importing original files containing 2010-11 ABS census data for the ACPMD.

library(readr)
library(readxl)
library(dplyr)


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

# The 'Estimate' column of OB contains characeters, whereas for AZ and AA the data type is a double.  
# Could make AZ and AA chr also, but we will want to do calculations with Estimate.
# So I used as.double to coerce ABS_management_201001_OB$Estimate to a double, which creates NAs where the character string is not a numeric.

ABS_management_201011_OB$Estimate <- as.double(ABS_management_201011_OB$Estimate)

# Create a list of the 3 EVAO tables

ABS_management_201011_list <- list(ABS_management_201011_OB, ABS_management_201011_AZ, ABS_management_201011_AA)

ABS_management_201011 <- bind_rows(ABS_management_201011_list)

