# Importing original files containing 2000-01 ABS census data for the ACPMD.

library(readr)
library(readxl)
library(dplyr)

# The 2000-01 data are in excel files (one for each state/territory) with multiple sheets, with commodity categories going across columns, areas down rows.
# The files use merged cells and indentations.

# Here we start with 71250DO003_200001.xls which contains NSW data

path5 <- "./data/raw_data/200001/71250DO003_200001.xls"

excel_sheets(path5)

# Unlike for 200506 and 201011, readxl is able to open these files directly - no need to save as xlsx files first.

# Here we manually create a list that combines the two rows of column headings

NSW_Table1_names <- c("Area",
                 "Sown pastures - sown pastures (including pure lucerne) - total area (ha) _Estimate",
                 "Sown pastures - sown pastures (including pure lucerne) - total area (ha) _Number of establishments",
                 "Sown pastures - sown pastures (excluding pure lucerne) - total area (ha) _Estimate",
                 "Sown pastures - sown pastures (excluding pure lucerne) - total area (ha) _Number of establishments",
                 "Sown pastures - lucerne & other pasture species mixtures - area (ha) _Estimate",
                 "Sown pastures - lucerne & other pasture species mixtures - area (ha) _Number of establishments",
                 "Sown pastures - pure lucerne pasture - area (ha) _Estimate",
                 "Sown pastures - pure lucerne pasture - area (ha) _Number of establishments",
                 "Sown pastures - pasture legumes only (excl. lucerne) - area (ha) _Estimate",
                 "Sown pastures - pasture legumes only (excl. lucerne) - area (ha) _Number of establishments",
                 "Sown pastures - sown grasses only - area (ha) _Estimate",
                 "Sown pastures - sown grasses only - area (ha) _Number of establishments",
                 "Sown pastures - sown perennial grasses & legume mixtures - area (ha) _Estimate",
                 "Sown pastures - sown perennial grasses & legume mixtures - area (ha) _Number of establishments",
                 "Sown pastures - sown annual grasses & legume mixtures - area (ha) _Estimate",
                 "Sown pastures - sown annual grasses & legume mixtures - area (ha) _Number of establishments"
                 ) 

# Now the use read_excel to bring in the table using the above names

NSW_Table1 <- head((read_excel(path5, sheet = 2, skip = 6, col_names = NSW_Table1_names)), n = -3)

# It looks like these sheets can be read in, and new column names specified.  
# The indenations are not preserved so SD groupings cannot be easily distinguished, but we're interested in SLA data anyway.
# For this work, we are mostly interested in the SLA data so it may be possible to skip rows with NAs.

# We also need to tidy the data.  
# First we will split into two tables (Estimate, Number of establishments) using select.

NSW_Table1_Estimate <- select(NSW_Table1, "Area", ends_with("Estimate"))

NSW_Table1_Number_of_establishmments <- select(NSW_Table1, "Area", ends_with("establishments"))

# Second, we will gather each table into a long file

library(tidyverse)

NSW_Table1_Estimate %>% gather(Commodity, Estimate, -Area, na.rm = TRUE)

NSW_Table1_Number_of_establishmments %>% gather(Commodity, Number_of_establishments, -Area, na.rm = TRUE)

# Nice. At this stage we won't bother combing these tables.  They are tidy.  Can easily do a bind_columns if needed.

# Now, run through all the the NSW tables.  Will need to manually create column names, but may be able to iterate through the sheets.


NSW_Table2_names <- c("Area",
                      "Sown pastures - sown/resown during year to pastures (including pure lucerne) - total area (ha) _Estimate",
                      "Sown pastures - sown/resown during year to pastures (including pure lucerne) - total area (ha) _Number of establishments",
                      "Sown pastures - sown/resown during year to pastures (excluding pure lucerne) - total area (ha) _Estimate",
                      "Sown pastures - sown/resown during year to pastures (excluding pure lucerne) - total area (ha) _Number of establishments",
                      "Sown pastures - sown/resown during year to lucerne & other pasture species mixtures - area (ha) _Estimate",
                      "Sown pastures - sown/resown during year to lucerne & other pasture species mixtures - area (ha) _Number of establishments",
                      "Sown pastures - sown/resown during year to pure lucerne - area (ha) _Estimate",
                      "Sown pastures - sown/resown during year to pure lucerne - area (ha) _Number of establishments",
                      "Sown pastures - sown/resown during year to pasture legumes only (excl. lucerne) - area (ha) _Estimate",
                      "Sown pastures - sown/resown during year to pasture legumes only (excl. lucerne) - area (ha) _Number of establishments",
                      "Sown pastures - sown/resown during year to grasses only - area (ha) _Estimate",
                      "Sown pastures - sown/resown during year to grasses only - area (ha) _Number of establishments",
                      "Sown pastures - sown/resown during year to perennial grasses & legume mixtures - area (ha) _Estimate",
                      "Sown pastures - sown/resown during year to perennial grasses & legume mixtures - area (ha) _Number of establishments",
                      "Sown pastures - sown/resown during year to annual grasses & legume mixtures - area (ha) _Estimate",
                      "Sown pastures - sown/resown during year to annual grasses & legume mixtures - area (ha) _Number of establishments"
                      )

NSW_Table2 <- head((read_excel(path5, sheet = 3, skip = 6, col_names = NSW_Table2_names)), n = -3)

NSW_Table2_Estimate <- select(NSW_Table2, "Area", ends_with("Estimate")) %>%
  gather(Commodity, Estimate, -Area, na.rm = TRUE)

NSW_Table2_Number_of_establishmments <- select(NSW_Table2, "Area", ends_with("establishments")) %>%
  gather(Commodity, Number_of_establishments, -Area, na.rm = TRUE)


NSW_Table3_names <- c("Area",
                      "Crops cut for hay - total area (ha) _Estimate",
                      "Crops cut for hay - total area (ha) _Number of establishments",
                      "Crops cut for hay - total production (t) _Estimate",
                      "Crops cut for hay - total production (t) _Number of establishments",
                      "Hay - pastures cut for hay - total area (ha) _Estimate",
                      "Hay - pastures cut for hay - total area (ha) _Number of establishments",
                      "Hay - pastures cut for hay - total production (t) _Estimate",
                      "Hay - pastures cut for hay - total production (t) _Number of establishments",
                      "Hay - pure lucerne cut for hay - area (ha) _Estimate",
                      "Hay - pure lucerne cut for hay - area (ha) _Number of establishments",
                      "Hay - pure lucerne cut for hay - production (t) _Estimate",
                      "Hay - pure lucerne cut for hay - production (t) _Number of establishments",
                      "Hay - other pastures cut for hay (sown or native) - area (ha) _Estimate",
                      "Hay - other pastures cut for hay (sown or native) - area (ha) _Number of establishments",
                      "Hay - other pastures cut for hay (sown or native) - production (t) _Estimate",
                      "Hay - other pastures cut for hay (sown or native) - production (t) _Number of establishments",
                      "Other crops (incl. lab lab purpureus) cut for hay - area (ha) _Estimate",
                      "Other crops (incl. lab lab purpureus) cut for hay - area (ha) _Number of establishments",
                      "Other crops (incl. lab lab purpureus) cut for hay - production (t) _Estimate",
                      "Other crops (incl. lab lab purpureus) cut for hay - production (t) _Number of establishments"
                      )

NSW_Table4_names <- c("Area",
                      "Cereals for all purposes - total area (ha) _Estimate",
                      "Cereals for all purposes - total area (ha) _Number of establishments",
                      "Cereals for grain - total area (ha) _Estimate",
                      "Cereals for grain - total area (ha) _Number of establishments",
                      "Cereals for grain - total production (t) _Estimate",
                      "Cereals for grain - total production (t) _Number of establishments",
                      "Cereals (incl. wheat oats & forage sorghum) cut for hay - area (ha) _Estimate",
                      "Cereals (incl. wheat oats & forage sorghum) cut for hay - area (ha) _Number of establishments",
                      "Cereals (incl. wheat oats & forage sorghum) cut for hay - production (t) _Estimate",
                      "Cereals (incl. wheat oats & forage sorghum) cut for hay - production (t) _Number of establishments",
                      "All cereals for all purposes other than hay, seed or grain (e.g. silage or fed off) - area (ha) _Estimate",
                      "All cereals for all purposes other than hay, seed or grain (e.g. silage or fed off) - area (ha) _Number of establishments"
                      )

# have a play with automating collection of column names

ncol(head((read_excel(path5, sheet = 3, skip = 4,)), n = 1))

colnames <- head((read_excel(path5, sheet = 3, skip = 4,)), n = 1) %>% 
  select(seq(2, ncol(head((read_excel(path5, sheet = 3, skip = 4,)), n = 1)), 2))

test3 <- rep(colnames,each = 2)

# try using paste to put _Estimate or _Number of establishments next to each colname.


library(purrr)

# Can use map from purr to read multiple sheets, however each sheet will need different column names.

test2 <-
  path5 %>% 
  excel_sheets() %>% 
  #set_names() %>% 
  map(read_excel, path = path5, skip = 4)

# Can also save as csv files, but would also want to trim last rows off
