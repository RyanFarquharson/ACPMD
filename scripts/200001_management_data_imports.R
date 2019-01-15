# Import data from specified sheets of original excel files containing 2000-01 ABS census data on fallow, stubble and cultivation for the ACPMD. 
# These files have multiple worksheets with headings in merged cells
# For the purposes the crop and pasture management database, the data of interest reside in Table1, sheet 2
# Here we create tidy dataframes from which we can build a database


library(readr)
library(readxl)
library(tidyverse)

datapath <- "./data/raw_data/200001/Fallow/"
filelist <- list.files(datapath)
statelist <- c("NSW", "Vic", "Qld", "SA", "WA", "Tas", "NT&ACT")

# worksheet to import
sheet_n <- 2

# row in which merged header appears
Area_row <- 5

skip_n <- Area_row -1

# row in which merged header appears
names_row <- 5

# number of rows to remove from bottom of worksheet
remove_last_rows <- -3


# iterate through files

n <- 1

for (f in filelist) {
  path <- paste0(datapath,f)
  state <- statelist[n]
  
  number_of_cols <- ncol(head((read_excel(path, sheet = sheet_n, skip = skip_n)), n = 1))
    
  cola <- head((read_excel(path, sheet = sheet_n, skip = skip_n, col_names = FALSE)), n = 1) %>% 
      select(seq(2, number_of_cols, 2)) %>%
      rep(each = 2)
    
  # use paste to put alternating ' _Estimate' or ' _Number of establishments' next to each column name.
    
  colnames <- c("Item", paste(cola, rep(c("_Estimate", "_Number of establishments"), (number_of_cols - 1) / 2)))
    
  # read in data and put in column names
    
  table_name <- head((read_excel(path, sheet = sheet_n, skip = names_row + 1, col_names = colnames)), n = remove_last_rows)
    
  # create tidy tables for Estimates and Number of establishments
    
  table_name_Estimate <- paste(state, "Land ownership and use", "Estimate", sep="_")
    
  table_name_Number_of_establishments <- paste(state, "Land ownership and use", "Number of establishments", sep="_")
    
  assign(table_name_Estimate, select(table_name, "Item", ends_with("Estimate")) %>%
             gather(Area, Estimate, -Item, na.rm = TRUE) %>%
    separate(Area, c("SD2001", "Junk"), sep = " _") %>%
    select(SD2001, Item, Estimate))
    
    #write_csv(path = paste0("./data/200001/",table_name_Estimate))
    
  assign(table_name_Number_of_establishments, select(table_name, "Item", ends_with("establishments")) %>%
             gather(Area, Number_of_establishments, -Item, na.rm = TRUE) %>%
    separate(Area, c("SD2001", "Junk"), sep = " _") %>%
    select(SD2001, Item, Number_of_establishments))
  
  n <- n + 1
  
 }
  

####################

# Need to convert 2001 SD to 2011 SA2s using correspondence files.
# To do so will be a multi-step process
# Some SD names are not unique because they occur in more than one state (Central West, Northern, South Eastern, South West)
# Modify above code to add a column with the state ID so that joins can be state specific

# No longer need to use SD names so joins no longer have to be state specific

# Steps: 2001SD -> 2006SLA -> 2011SA2
# Correspondence files: CA2001SD_2006SLA.csv, CG_SLA_2006_SA2_2011.xls
# Check which direcion the correspondence works in

# path for concordance/correspondence files

concpath <- "./data/raw_data/concordance/"

# read 2006SD to 2001SD concordance file

CA2001SD_2006SLA <- read_csv(paste0(concpath,"CA2001SD_2006SLA.csv"))

# mutate to include state code (first digit of SD code)

CA2001SD_2006SLA_state <- CA2001SD_2006SLA %>% mutate(state_code = substr(CA2001SD_2006SLA$SD_Code_2001,0,1))

# create table of state names and state codes

state_code <- c("1", "2", "3", "4", "5", "6", "7", "8")
statelist2 <- c("NSW", "Vic", "Qld", "SA", "WA", "Tas", "NT", "ACT")

statetable <- cbind(statelist2,state_code)

# do an inner join of state estimate table and CA2006SD_2001SD where state_code is correct to avoid incorrect assignement of SD codes since some SD names double up
# use filter then pipe to join

NSW_2001SD_2006SLA <- CA2001SD_2006SLA_state %>% filter(state_code == 1) %>%
  inner_join(`NSW_Land ownership and use_Estimate`, by = c("SD_Name_2001" = "SD2001"))

# Note that there were 6 SLAs where the ratios did not approach 1.

# Calculate new estimates using ratios.  Mutate so SLA_estimate = estimate * ratio

NSW2006SLA <- NSW_2001SD_2006SLA %>% mutate(SLA_estimate = NSW_2001SD_2006SLA$Estimate * NSW_2001SD_2006SLA$RATIO)

test1 <- NSW2006SLA %>% group_by(SLA_MAINCODE_2006, Item) %>%
  summarise(sum_ratio = sum(RATIO), sum_estimate = sum(SLA_estimate))

# Consider second join to go from 2006SLA to 2011SA2.  Can do this in a couple of ways.
# 1. Calculate new estimate as previously, join second ratio, calculate new new estimate
# 2. join twice then multiply ratio.x by ratio.y and calculate new estimate.
# Maybe try both and test equivalence.

# read in concordance from 2006 SLA to 2011 SA2

CG_SLA_2006_SA2_2011 <- read_excel(paste0(concpath,"CG_SLA_2006_SA2_2011.xls"), sheet = 4, skip = 5, n_max = 3613,  
                                         col_names = TRUE)

# mutate to include state code (first digit of SD code).  This isn't actually needed because SLAs and SA2 maincodes commence with state code.
# In fact, could run through all of the 

CG_SLA_2006_SA2_2011_state <- CG_SLA_2006_SA2_2011 %>% mutate(state_code = substr(CG_SLA_2006_SA2_2011$SA2_MAINCODE_2011,0,1))

#NSW_2001SD_2006SLA_2011SA2 <- CG_SLA_2006_SA2_2011_state %>% filter(state_code == 1) %>%
#  inner_join(NSW_2001SD_2006SLA, by = "SLA_MAINCODE_2006") 

#NSW_management <- 
#  NSW_2001SD_2006SLA_2011SA2 %>%
#  mutate(SA2_estimate = Estimate * RATIO.x * RATIO.y, final_ratio = RATIO.x * RATIO.y) %>% 
#  group_by(SA2_MAINCODE_2011, Item) %>%
#  summarise(sum_ratio = sum(final_ratio), sum_estimate = sum(SA2_estimate))

NSW_2006_SLA <- 
  NSW2006SLA %>% 
  select(SLA_MAINCODE_2006, SLA_NAME_2006,Item, SLA_estimate)

NSW_2006SLA_2011SA2 <- CG_SLA_2006_SA2_2011_state %>% filter(state_code == 1) %>%
  inner_join(NSW_2006_SLA, by = "SLA_MAINCODE_2006")

NSW_2011_SA2_management <- NSW_2006SLA_2011SA2 %>%
  mutate(SA2_estimate = SLA_estimate * RATIO) %>%
  group_by(SA2_MAINCODE_2011, Item) %>%
  summarise(sum_ratio = sum(RATIO), sum_estimate = sum(SA2_estimate))



# Repeat for other states

# bind rows to get full data set into one table
