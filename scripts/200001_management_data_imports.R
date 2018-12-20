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
# Some SD names are not unique because they occur in more than one state (Central West, Morthern, South Eastern, South West)
# Modify above code to add a column with the state ID so that joins can be state specific
# Steps: 2001SD -> 2006SD -> 2006SSD -> 2006SLA -> 2011SA2
# Correspondence files: CA2006SD_2001SD.csv, CA_2006SD_2006SSD.csv, CA2006SSD_2006SLA.csv, CG_SLA_2006_SA2_2011.xls
# Check which direcion the correspondece works in


