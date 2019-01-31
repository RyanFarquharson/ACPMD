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
  

#####

# Need to convert 2001 SD to 2011 SA2s using correspondence files.
# We now have a 2001SD to 2011 SA2 corespondence file from ABS so can go directly

# First step - match 2001SD names to SD codes.  This will needs to be done on a state by state basis due to non-unique names.

# path for concordance/correspondence files

concpath <- "./data/raw_data/concordance/"

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

# Bind rows to bring all of the data together.  Renamed column because subsequent join was being difficult.

All_2001SD_estimate <- 
  bind_rows(NSW_2001SD_estimate,
            Vic_2001SD_estimate,
            Qld_2001SD_estimate,
            SA_2001SD_estimate,
            WA_2001SD_estimate,
            Tas_2001SD_estimate,
            NTACT_2001SD_estimate) %>%
  rename(SD_CODE_2001 = 'SD_Code_2001')


# Read excel to bring 200SD to 2011SA2 correspondence in.

CA_SD_2001_SA2_2011 <- read_excel(paste0(concpath,"CA_SD_2001_SA2_2011.xlsx"), sheet = 4, skip = 5, n_max = 2230,  
                                   col_names = TRUE)

# Join, mutate, calculate, group by and summarise to create 2011 SA2 data.  Note: this still needs to be normalised.

str(All_2001SD_estimate)
str(CA_SD_2001_SA2_2011)


Estimate_2011SA2 <- All_2001SD_estimate %>%
  inner_join(CA_SD_2001_SA2_2011, by = "SD_CODE_2001") %>%
  mutate(SA2_estimate = Estimate * RATIO) %>%
  group_by(SA2_MAINCODE_2011, Item) %>%
  summarise(Estimate_to_normalise = sum(SA2_estimate))

#####

# How to normalise data by SA2? 
# Spread -> mutate -> gather?

# Let's see what the unique Items are

Items <- as.data.frame(unique(Estimate_2011SA2$Item))

# Let's filter for specific items

library(stringr)

Fallow_2011SA2_untransformed <- filter(Estimate_2011SA2, str_detect(Item, 'Fallow*'))

FallowGreaterThanNineMonths_2011SA2_untransformed <- filter(Estimate_2011SA2, str_detect(Item, 'Fallow land - more than 9 months fallow - area (ha)*'))

FallowTotal_2011SA2_untransformed <- filter(Estimate_2011SA2, str_detect(Item, 'Fallow land - total area left fallow (ha)*')) %>%
  rename(Total = Estimate_to_normalise)

Cultivation_2011SA2_untransformed <- filter(Estimate_2011SA2, str_detect(Item, 'Preparation*'))

NoCultivation_2011SA2_untransformed <- filter(Estimate_2011SA2, str_detect(Item, 'Preparation of cropping land - no cultivation*'))

CultivationTotal_2011SA2_untransformed <- filter(Estimate_2011SA2, str_detect(Item, 'Preparation of cropping land - total area prepared (ha)*')) %>%
  rename(Total = Estimate_to_normalise)

Stubble_2011SA2_untransformed <- filter(Estimate_2011SA2, str_detect(Item, 'Treatment*'))

StubbleRemoved_2011SA2_untransformed <- filter(Estimate_2011SA2, str_detect(Item, 'Treatment of crop stubble - most stubble removed*'))

StubbleIntact_2011SA2_untransformed <- filter(Estimate_2011SA2, str_detect(Item, 'Treatment of crop stubble - stubble left intact*'))

StubbleMulched_2011SA2_untransformed <- filter(Estimate_2011SA2, str_detect(Item, 'Treatment of crop stubble - stubble mulched*'))

StubblePloughed_2011SA2_untransformed <- filter(Estimate_2011SA2, str_detect(Item, 'Treatment of crop stubble - stubble ploughed*'))

StubbleCoolBurn_2011SA2_untransformed <- filter(Estimate_2011SA2, str_detect(Item, 'Treatment of crop stubble - stubble removed by cool burn*')) %>%

StubbleHotBurn_2011SA2_untransformed <- filter(Estimate_2011SA2, str_detect(Item, 'Treatment of crop stubble - stubble removed by hot burn*'))

StubbleTotal_2011SA2_untransformed <- filter(Estimate_2011SA2, str_detect(Item, 'Treatment of crop stubble - total area treated (ha)*')) %>%
  rename(Total = Estimate_to_normalise)

AreaOfHolding_2011SA2_untransformed <- filter(Estimate_2011SA2, str_detect(Item, "Area of holding - total area (ha)*")) %>%
  rename(Total = Estimate_to_normalise)

# Now to normalise, we join then mutate with a calculation of each item as a proportion of the total holdings

FallowTotal_2011SA2_PropOfHoldings <- Fallow_2011SA2_untransformed %>%
  inner_join(AreaOfHolding_2011SA2_untransformed, by = 'SA2_MAINCODE_2011') %>%
  mutate(Normalised_Estimate = Estimate_to_normalise / Total) %>%
  select(SA2_MAINCODE_2011, Item = Item.x, Normalised_Estimate)

FallowGreaterThanNineMonths_2011SA2_PropOfHoldings <- FallowGreaterThanNineMonths_2011SA2_untransformed %>%
  inner_join(AreaOfHolding_2011SA2_untransformed, by = 'SA2_MAINCODE_2011') %>%
  mutate(Normalised_Estimate = Estimate_to_normalise / Total) %>%
  select(SA2_MAINCODE_2011, Item = Item.x, Normalised_Estimate)

Cultivation_2011SA2_PropOfHoldings <- Cultivation_2011SA2_untransformed %>%
  inner_join(AreaOfHolding_2011SA2_untransformed, by = 'SA2_MAINCODE_2011') %>%
  mutate(Normalised_Estimate = Estimate_to_normalise / Total) %>%
  select(SA2_MAINCODE_2011, Item = Item.x, Normalised_Estimate)

NoCultivation_2011SA2_PropOfHoldings <- NoCultivation_2011SA2_untransformed %>%
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

# There are numerous combinations that can be calculated
# can go back and clean up items by replacing 'area (ha)' with 'proportion'
# Tried '%>% mutate(Item = str_replace(Item, "area (ha)", "proportion"))'
# couldn't get it to work.  

# Combine into a single table?