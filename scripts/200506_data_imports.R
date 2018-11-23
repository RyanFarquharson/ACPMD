# Importing original files containing 2005-06 ABS census data for the ACPMD.

library(readr)
library(readxl)
library(dplyr)


path4 <- "./data/raw_data/200506/05-06 Census data-excel format.xlsx"

excel_sheets(path4)

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

ABS_commodities_200506_list <- list(ABS_commodities_200506_NSW,ABS_commodities_200506_Vic,ABS_commodities_200506_Qld,
                                 ABS_commodities_200506_SA, ABS_commodities_200506_Tas, ABS_commodities_200506_NT, ABS_commodities_200506_NT)

ABS_commodities_200506 <- bind_rows(ABS_commodities_200506_list)
