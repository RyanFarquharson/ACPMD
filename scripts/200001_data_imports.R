# Import data from specified sheets of original excel files containing 2000-01 ABS census data for the ACPMD. 
# These files have multiple worksheets with headings in merged cells
# Here we create tidy dataframes from which we can build a database


library(readr)
library(readxl)
library(tidyverse)


filelist <- list.files("./data/raw_data/200001/")
statelist <- c("NSW", "Vic", "Qld", "SA", "WA", "Tas", "NT&ACT")

# worksheet to start at
sheet_n <- 2

# row in which merged header appears
names_row <- 5

skip_n <- names_row -1

# number of rows to remove from bottom of worksheet
remove_last_rows <- -3


# iterate through files

n <- 1

for (f in filelist) {
  path <- paste0("./data/raw_data/200001/",f)
  state <- statelist[n]
  sheets <- excel_sheets(path)
  n <- n + 1
  
  # iterate through sheets
  
  for (i in 2:length(sheets)) {
    sheet_n <- i
    
    number_of_cols <- ncol(head((read_excel(path, sheet = sheet_n, skip = skip_n)), n = 1))
    
    cola <- head((read_excel(path, sheet = sheet_n, skip = skip_n, col_names = FALSE)), n = 1) %>% 
      select(seq(2, number_of_cols, 2)) %>%
      rep(each = 2)
    
    # use paste to put alternating ' _Estimate' or ' _Number of establishments' next to each column name.
    
    colnames <- c("Area", paste(cola, rep(c(" _Estimate", " _Number of establishments"), (number_of_cols - 1) / 2)))
    
    # read in data and put in column names
    
    table_name <- head((read_excel(path, sheet = sheet_n, skip = names_row + 1, col_names = colnames)), n = remove_last_rows)
    
    # create tidy tables for Estimates and Number of establishments
    
    table_name_Estimate <- paste(state, "Table", i-1, "Estimate", sep="_")
    
    table_name_Number_of_establishmments <- paste(state, "Table", i-1, "Number_of_establishments", sep="_")
    
    assign(table_name_Estimate, select(table_name, "Area", ends_with("Estimate")) %>%
             gather(Commodity, Estimate, -Area, na.rm = TRUE)) %>%
      write_csv(path = paste0("./data/200001/",table_name_Estimate))
    
    assign(table_name_Number_of_establishmments, select(table_name, "Area", ends_with("establishments")) %>%
             gather(Commodity, Number_of_establishments, -Area, na.rm = TRUE))
  }
  
}


# combine individual state Estimate tables into a single table

estimate_table <- data.frame(Area = character(),
                             Commodity = character(),
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

