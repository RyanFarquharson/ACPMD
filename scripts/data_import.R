# create a function that will read in data sitting on spearate sheets from 2001 ABS ag census data

# Signature
# data_import: chr chr int int int -> tibble

# Purpose
# Import data from specified sheets of an excel file that has headings in merged cells and create tidy dataframes

# Stub
# data_import: path sheet_n names_row remove_last_rows -> table_name

# Examples


library(readr)
library(readxl)
library(tidyverse)

# automate collection of column names where there have been merged cells to go across two columns

path <- "./data/raw_data/200001/71250DO003_200001.xls"
sheets <- excel_sheets(path)
sheet_n <- 2
names_row <- 5
skip_n <- names_row -1
remove_last_rows <- -3

number_of_cols <- ncol(head((read_excel(path, sheet = sheet_n, skip = skip_n)), n = 1))

cola <- head((read_excel(path, sheet = sheet_n, skip = skip_n, col_names = FALSE)), n = 1) %>% 
  select(seq(2, number_of_cols, 2)) %>%
  rep(each = 2)

# use paste to put alternating ' _Estimate' or ' _Number of establishments' next to each column name.

colnames <- c("Area", paste(cola, rep(c(" _Estimate", " _Number of establishments"), (number_of_cols - 1) / 2)))

# read in data and put in column names

table_name <- head((read_excel(path, sheet = sheet_n, skip = names_row + 1, col_names = colnames)), n = remove_last_rows)

# create tidy tables for Estimates and Number of establishments

table_name_Estimate <- select(table_name, "Area", ends_with("Estimate")) %>%
  gather(Commodity, Estimate, -Area, na.rm = TRUE)

table_name_Number_of_establishmments <- select(table_name, "Area", ends_with("establishments")) %>%
  gather(Commodity, Number_of_establishments, -Area, na.rm = TRUE)


# iterate through sheets

for (i in seq_along(sheets[-1])) {
  sheet_n <- i
  
}
