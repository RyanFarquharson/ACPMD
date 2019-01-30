# Importing original files containing 2005-06 ABS census data for the ACPMD.

library(readr)
library(readxl)
library(dplyr)


path4 <- "./data/raw_data/200506/05-06 Census data-excel format.xlsx"

#excel_sheets(path4)

# The sheets in this file are as follows
# 1	National level data
# 2	State level data
# 3	Statistical Division level data
# 4	Statistical Subdivision level data - All states excluding NSW
# 5	Statistical Subdivision level data - New South Wales
# 6	Statistical Local Area level data - New South Wales - All data excluding fruit
# 7	Statistical Local Area level data - New South Wales - Fruit excluding grapes
# 8	Statistical Local Area level data - New South Wales - Grapes
# 9	Statistical Local Area level data - Victoria - All data excluding fruit
#10	Statistical Local Area level data - Victoria - Fruit excluding grapes
#11	Statistical Local Area level data - Victoria - Grapes
#12	Statistical Local Area level data - Queensland - All data excluding fruit
#13	Statistical Local Area level data - Queensland - Fruit excluding grapes
#14	Statistical Local Area level data - Queensland - Grapes
#15	Statistical Local Area level data - South Australia - All data excluding fruit
#16	Statistical Local Area level data - South Australia - Fruit excluding grapes
#17	Statistical Local Area level data - South Australia - Grapes
#18	Statistical Local Area level data - Western Australia - All data excluding fruit
#19	Statistical Local Area level data - Western Australia - Fruit excluding grapes
#20	Statistical Local Area level data - Western Australia - Grapes
#21	Statistical Local Area level data - Tasmania - All data excluding fruit
#22	Statistical Local Area level data - Tasmania - Fruit excluding grapes
#23	Statistical Local Area level data - Tasmania - Grapes
#24	Statistical Local Area level data - Northern Territory - All data excluding fruit
#25	Statistical Local Area level data - Northern Territory - Fruit excluding grapes
#26	Statistical Local Area level data - Northern Territory - Grapes
#27	Statistical Local Area level data - Australian Capital Territory - All data excluding fruit
#28	Statistical Local Area level data - Australian Capital Territory - Fruit excluding grapes
#29	Statistical Local Area level data - Australian Capital Territory - Grapes

# The sheets required are 6,9,12,15,18,21,24,27 which contain the SLA data for eachof the states and territories for all commodities excluding fruit

ABS_commodities_200506_NSW <- read_excel(path4, sheet = "6", skip = 5, n_max = 13599,  
                                       col_names = TRUE)
ABS_commodities_200506_NSW$Estimate <- as.double(ABS_commodities_200506_NSW$Estimate)

ABS_commodities_200506_Vic <- read_excel(path4, sheet = "9", skip = 5, n_max = 19077,  
                                         col_names = TRUE)

ABS_commodities_200506_Qld <- read_excel(path4, sheet = "12", skip = 5, n_max = 18825,  
                                         col_names = TRUE)

ABS_commodities_200506_SA <- read_excel(path4, sheet = "15", skip = 5, n_max = 9596,  
                                         col_names = TRUE)
ABS_commodities_200506_SA$Estimate <- as.double(ABS_commodities_200506_SA$Estimate)

ABS_commodities_200506_WA <- read_excel(path4, sheet = "18", skip = 5, n_max = 13599,  
                                        col_names = TRUE)
ABS_commodities_200506_WA$Estimate <- as.double(ABS_commodities_200506_WA$Estimate)

ABS_commodities_200506_Tas <- read_excel(path4, sheet = "21", skip = 5, n_max = 4931,  
                                        col_names = TRUE)
ABS_commodities_200506_Tas$Estimate <- as.double(ABS_commodities_200506_Tas$Estimate)

ABS_commodities_200506_NT <- read_excel(path4, sheet = "24", skip = 5, n_max = 1216,  
                                         col_names = TRUE)

ABS_commodities_200506_ACT <- read_excel(path4, sheet = "27", skip = 5, n_max = 574,  
                                        col_names = TRUE)
ABS_commodities_200506_ACT$Estimate <- as.double(ABS_commodities_200506_ACT$Estimate)

# Create a lits of state and territory data tables

ABS_commodities_200506_list <- list(ABS_commodities_200506_NSW,ABS_commodities_200506_Vic,ABS_commodities_200506_Qld,
                                 ABS_commodities_200506_SA, ABS_commodities_200506_Tas, ABS_commodities_200506_NT, ABS_commodities_200506_NT)

# Combine state and terriroty data into a single table

ABS_commodities_200506 <- bind_rows(ABS_commodities_200506_list)

# Write file to csv

write_csv(ABS_commodities_200506, "./data/ABS_commodities_200506.csv")


# Use concordance/correspondence to convert 200506 areas from 2006 SLAs to 2011 ASGS SA2s
# Note, an ABS correspondence file exists for this correspondence CG_SLA_2006_SA2_2011.xls which has different ratios.
# This is a population grid weighted correspondence denaoted CG.  It is not suitable for spatial agricultural data.  
# CA denotes area weighted which is what we need for ag data.
# Request new CA correspondence files if there are none.  Contact Hayley Farthing from ABS geospational solutions. hayley.farthing@abs.gov.au  
# concord_2006SLA_2011SA2.csv contains the same data as CA_SLA_2006_SA2_2011.xls.  
# For completeness, I have replaced the read csv from concord_2006SLA_2011SA2.csv with a read_excel from the ABS file CA_SLA_2006_SA2_2011.xls


concordance <- read_excel("./data/raw_data/concordance/CA_SLA_2006_SA2_2011.xls", sheet = 4, skip = 5, n_max = 4372, col_names = TRUE)

# Create new table ABS_commodities_200506 using a join to add in data from concordance to ABS_commodities_200506

ABS_commodities_200506_SA2 <- inner_join(ABS_commodities_200506, concordance, by = c("Region - Codes" = "SLA_MAINCODE_2006"))
  
# Use the concordance data to calculate new "Estimate" values by SA2

ABS_commodities_200506_SA2$Estimate_SA2 <- ABS_commodities_200506_SA2$Estimate * ABS_commodities_200506_SA2$RATIO

# Use the concordance data to calculate new number of ag businesses values by SA2

ABS_commodities_200506_SA2$Estimate_Businesses <- ABS_commodities_200506_SA2$`Number of agricultural businesses` * ABS_commodities_200506_SA2$RATIO


# Use a group_by and summarise to sum Estimates for each commodity by SA2

commodities_200506_SA2 <- ABS_commodities_200506_SA2 %>%
  select(`SA2 MAINCODE_2011`, SA2_NAME_2011, `Commodity - Codes`, `Commodity - Labels`, Estimate_SA2, `Estimate - Annotation`, Estimate_Businesses, `Number of agricultural businesses - Annotation`) %>%
  group_by(`SA2 MAINCODE_2011`, SA2_NAME_2011, `Commodity - Codes`, `Commodity - Labels`, `Estimate - Annotation`, `Number of agricultural businesses - Annotation`) %>%
  summarise(SA2Est = sum(Estimate_SA2), SA2Bus = sum(Estimate_Businesses))

# rename columns to be consistent across all epochs

commodities_200506_SA2 <- rename(commodities_200506_SA2,
       ASGS_code = "SA2 MAINCODE_2011",
       ASGS_label = "SA2_NAME_2011",
       Commodity_code = "Commodity - Codes",
       Commodity_label = "Commodity - Labels",
       Estimate = "SA2Est",
       Estimate_RSE = "Estimate - Annotation",
       Businesses = "SA2Bus",
       Businesses_RSE = "Number of agricultural businesses - Annotation")

write_csv(commodities_200506_SA2, "./data/commodities_200506_SA2.csv")


# Test whether sums of estimates are equal in the original and group data 
sum(ABS_commodities_200506_SA2$Estimate_SA2, na.rm = TRUE)
sum(commodities_200506_SA2$SA2Est, na.rm = TRUE)

sum(ABS_commodities_200506_SA2$Estimate_Businesses, na.rm = TRUE)
sum(commodities_200506_SA2$SA2Bus, na.rm = TRUE)

# Test filtering depending on relative standard error codes
commodities_200506_SA2 %>% filter(`Estimate - Annotation` != "**" & 
                        `Number of agricultural businesses - Annotation` != "**")


