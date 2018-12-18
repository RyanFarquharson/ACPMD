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
             gather(Area, Estimate, -Item, na.rm = TRUE)) #%>%
    #write_csv(path = paste0("./data/200001/",table_name_Estimate))
    
  assign(table_name_Number_of_establishments, select(table_name, "Item", ends_with("establishments")) %>%
             gather(Area, Number_of_establishments, -Item, na.rm = TRUE))
  
  n <- n + 1
  
 }
  
####################

# Need to find a 2001 SD to 2011 SA2 correspondence file




# combine individual state Estimate tables into a single table

estimate_table <- data.frame(Item = character(),
                             Area = character(),
                             Estimate = double())

for (f in list.files("./data/200001/")) {
  new_table <- read_csv(paste0("./data/200001/",f))
  estimate_table <- bind_rows(estimate_table, new_table)
}

# concord from 2001 SLAs to 2011 SA2s

# import ABS correspondence file

SLA_2001_SA2_2011 <- head(read_excel("./data/raw_data/concordance/CG_SLA_2001_SA2_2011.xls", sheet = "Table 3", skip = 5), n = -3)

# use an inner join to match up SLA names with the correspondence data

estimate_SA2 <- inner_join(estimate_table, SLA_2001_SA2_2011, by = c("Area" = "SLA_NAME_2001"))

# Use the concordance data to calculate new "Estimate" values by SA2

estimate_SA2$Estimate_SA2 <- estimate_SA2$Estimate * estimate_SA2$RATIO

# Use a group_by and summarise to sum Estimates for each commodity by SA2

commodities_200001_SA2 <- estimate_SA2 %>%
  select(`SA2_MAINCODE_2011`, SA2_NAME_2011, `Commodity`, Estimate_SA2) %>%
  group_by(`SA2_MAINCODE_2011`, SA2_NAME_2011, `Commodity`) %>%
  summarise(SA2Est = sum(Estimate_SA2))

# rename columns to be consistent across all epochs

commodities_200001_SA2 <- rename(commodities_200001_SA2,
                                 ASGS_code = "SA2_MAINCODE_2011",
                                 ASGS_label = "SA2_NAME_2011",
                                 Commodity_label = "Commodity",
                                 Estimate = "SA2Est"
)

write_csv(commodities_200001_SA2, "./data/commodities_200001_SA2.csv")

