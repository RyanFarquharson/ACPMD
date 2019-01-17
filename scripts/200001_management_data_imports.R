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

# To do so will be a multi-step process.  
# Correspendence files are unidirectional, and do not contain area data that would enable reversal of the correspondence.
# Note that descriptions of direction of correspondence is not necessarily obvious or correct.
# To check, do a group by for the To and From data and summarise the ratios by sum.
# The From data should sum to 1, or very close.

# Correspondence steps: 2001SD -> 2001SLA -> 2006SLA -> 2011SA2
# 2001SD to 2001SLA: can be done directly using 3 and 5 digit codes.  
#  Find a file that gives these to go from state SD name to code.
#  These need to be done state by state because SD names are not unique.  Multiple states can have the same SD name.
# 2001SLA to 2006SLA: CA2006SLA_2001SLA.csv (To, From), 
# 2006SLA to 2011SA2: CG_SLA_2006_SA2_2011.xls (From, To)

# Need to review the snippets below given issues with correspondence files.
# Also need to revisit how the data will be used.
# Since we are going from large SDs to small SLAs then SA2s, we can't allocate area data.
# Need to calculate proportional allocations and assign to 2001 SLAs then concord to 2006 SLAs then 2011 SA2s.

####################


# path for concordance/correspondence files

concpath <- "./data/raw_data/concordance/"

# Two ABS correspondence files contain 2001SD names and codes.
# Note: unfortunately these cannot be used directly because they go in the wrong direction.
# 2001SD to 2001SLA can be done directly using 3 and 5 digit codes.

# First step - match 2001SD names to SD codes.  This will needs to be done on a state by state basis due to non-unique names.

# Read csv file containing 2001 SD names and codes

CA2001SD_2006SD <- read_csv(paste0(concpath,"CA2001SD_2006SD.csv"))

# Create a state code (first didit of SD code) and select relevant columns

CA2001SD_state <- CA2001SD_2006SD %>% 
  mutate(state_code = as.integer(substr(CA2001SD_2006SD$SD_Code_2001,0,1))) %>%
  select(SD_Code_2001, SD_Name_2001, state_code)

# Do a state by state join to match state data to SD code

NSW_2001SD_estimate <- CA2001SD_state %>% filter(state_code == 1) %>%
  inner_join(`NSW_Land ownership and use_Estimate`, by = c("SD_Name_2001" = "SD2001"))
Vic_2001SD_estimate <- CA2001SD_state %>% filter(state_code == 2) %>%
  inner_join(`Vic_Land ownership and use_Estimate`, by = c("SD_Name_2001" = "SD2001"))
Qld_2001SD_estimate <- CA2001SD_state %>% filter(state_code == 3) %>%
  inner_join(`Qld_Land ownership and use_Estimate`, by = c("SD_Name_2001" = "SD2001"))
SA_2001SD_estimate <- CA2001SD_state %>% filter(state_code == 4) %>%
  inner_join(`SA_Land ownership and use_Estimate`, by = c("SD_Name_2001" = "SD2001"))
WA_2001SD_estimate <- CA2001SD_state %>% filter(state_code == 5) %>%
  inner_join(`SA_Land ownership and use_Estimate`, by = c("SD_Name_2001" = "SD2001"))
Tas_2001SD_estimate <- CA2001SD_state %>% filter(state_code == 6) %>%
  inner_join(`Tas_Land ownership and use_Estimate`, by = c("SD_Name_2001" = "SD2001"))
NTACT_2001SD_estimate <- CA2001SD_state %>% filter(state_code == 7 | state_code == 8) %>%
  inner_join(`NT&ACT_Land ownership and use_Estimate`, by = c("SD_Name_2001" = "SD2001"))

# Bind rows to bring all of the data together

All_2001SD_estimate <- 
  bind_rows(NSW_2001SD_estimate,
            Vic_2001SD_estimate,
            Qld_2001SD_estimate,
            SA_2001SD_estimate,
            WA_2001SD_estimate,
            Tas_2001SD_estimate,
            NTACT_2001SD_estimate)

# Next, 2001 SLAs need to adopt the corresponding SD data.  
# To do this, import 2001 SLA corresponance, create the SD codes from the SLA codes, then do a join.
# At this stage, the data has not been normalised.  This still needs to be done.

# Read csv containing 2001SLA to 2006SLA correspondance and add 2001SD code using first 3 digits of SLA_Main_2001

CA2006SLA_2001SLA <- read_csv(paste0(concpath,"CA2006SLA_2001SLA.csv")) %>%
  mutate('2001SD' = as.integer(substr(CA2006SLA_2001SLA$SLA_Main_2001,0,3)))

# Do a join to bring 2001SD estimate data together with 2001SLA and 2006SLAs
# Do a ratio calculation to concord from 2001SLA to 2006SLA
# Do a group by 2006 SLA and filter

All_2006SLA_estimate <-
  All_2001SD_estimate %>%
  inner_join(CA2006SLA_2001SLA, by = c("SD_Code_2001" = "2001SD")) %>%
  mutate(Estimate_2006SLA = Estimate * RATIO) %>%
  group_by(SLA_MAINCODE_2006, Item) %>%
  summarise(Estimate_2006SLA = sum(Estimate_2006SLA))

# Read excel to bring 2006SLA to 2011SA2 correspondence in

CA_SLA_2006_SA2_2011 <- read_excel(paste0(concpath,"CA_SLA_2006_SA2_2011.xls"), sheet = 4, skip = 5, n_max = 4372,  
                                   col_names = TRUE) %>%
  rename(SA2_MAINCODE_2011 = 'SA2 MAINCODE_2011')

# Join to create 2011 SA2 data.  Note: this still needs to be normalised.

Estimate_2011SA2 <- All_2006SLA_estimate %>%
  inner_join(CA_SLA_2006_SA2_2011, by = "SLA_MAINCODE_2006") %>%
  mutate(SA2_estimate = Estimate_2006SLA * RATIO) %>%
  group_by(SA2_MAINCODE_2011, Item) %>%
  summarise(Estimate_to_normalise = sum(SA2_estimate))

# How to normalise data by SA2? 
# Spread -> mutate -> gather?

# Let's see what the unique Items are

Items <- as.data.frame(unique(Estimate_2011SA2$Item))

# Let's filter for specific items

library(stringr)

Fallow_2011SA2_untransformed <- filter(Estimate_2011SA2, str_detect(Item, 'Fallow*'))

FallowTotal_2011SA2_untransformed <- filter(Estimate_2011SA2, str_detect(Item, 'Fallow land - total area left fallow (ha)*')) %>%
  rename(Total = Estimate_to_normalise)

Cultivation_2011SA2_untransformed <- filter(Estimate_2011SA2, str_detect(Item, 'Preparation*'))

CultivationTotal_2011SA2_untransformed <- filter(Estimate_2011SA2, str_detect(Item, 'Preparation of cropping land - total area prepared (ha)*')) %>%
  rename(Total = Estimate_to_normalise)

Stubble_2011SA2_untransformed <- filter(Estimate_2011SA2, str_detect(Item, 'Treatment*'))

StubbleTotal_2011SA2_untransformed <- filter(Estimate_2011SA2, str_detect(Item, 'Treatment of crop stubble - total area treated (ha)*')) %>%
  rename(Total = Estimate_to_normalise)

AreaOfHolding_2011SA2_untransformed <- filter(Estimate_2011SA2, str_detect(Item, "Area of holding - total area (ha)*")) %>%
  rename(Total = Estimate_to_normalise)

# Now to normalise, we join then mutate with a calculation of each item as a proportion of the total holdings

Fallow_2011SA2_PropOfHoldings <- Fallow_2011SA2_untransformed %>%
  inner_join(AreaOfHolding_2011SA2_untransformed, by = 'SA2_MAINCODE_2011') %>%
  mutate(Normalised_Estimate = Estimate_to_normalise / Total) %>%
  select(SA2_MAINCODE_2011, Item = Item.x, Normalised_Estimate)

Cultivation_2011SA2_PropOfHoldings <- Cultivation_2011SA2_untransformed %>%
  inner_join(AreaOfHolding_2011SA2_untransformed, by = 'SA2_MAINCODE_2011') %>%
  mutate(Normalised_Estimate = Estimate_to_normalise / Total) %>%
  select(SA2_MAINCODE_2011, Item = Item.x, Normalised_Estimate)

Stubble_2011SA2_PropOfHoldings <- Stubble_2011SA2_untransformed %>%
  inner_join(AreaOfHolding_2011SA2_untransformed, by = 'SA2_MAINCODE_2011') %>%
  mutate(Normalised_Estimate = Estimate_to_normalise / Total) %>%
  select(SA2_MAINCODE_2011, Item = Item.x, Normalised_Estimate)

# and of each management category

Fallow_2011SA2_PropOfFallow <- Fallow_2011SA2_untransformed %>%
  inner_join(FallowTotal_2011SA2_untransformed, by = 'SA2_MAINCODE_2011') %>%
  mutate(Normalised_Estimate = Estimate_to_normalise / Total) %>%
  select(SA2_MAINCODE_2011, Item = Item.x, Normalised_Estimate)

Cultivation_2011SA2_PropOfCultivation <- Cultivation_2011SA2_untransformed %>%
  inner_join(CultivationTotal_2011SA2_untransformed, by = 'SA2_MAINCODE_2011') %>%
  mutate(Normalised_Estimate = Estimate_to_normalise / Total) %>%
  select(SA2_MAINCODE_2011, Item = Item.x, Normalised_Estimate)

Stubble_2011SA2_PropOfStubble <- Stubble_2011SA2_untransformed %>%
  inner_join(StubbleTotal_2011SA2_untransformed, by = 'SA2_MAINCODE_2011') %>%
  mutate(Normalised_Estimate = Estimate_to_normalise / Total) %>%
  select(SA2_MAINCODE_2011, Item = Item.x, Normalised_Estimate)

# can go back and clean up items by replacing 'area (ha)' with 'proportion'
# %>% mutate(Item = str_replace(Item, "area (ha)", "proportion"))
# couldn't get it to work.  
