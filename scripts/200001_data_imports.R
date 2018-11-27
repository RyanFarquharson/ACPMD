# Importing original files containing 2000-01 ABS census data for the ACPMD.

library(readr)
library(readxl)
library(dplyr)

# The 2000-01 data are in excel files with multiple sheets, with commodity categories going across columns, areas down rows.
# The files use merged cells and indentations.
# It will take quite some work to write a script to import and arrange the data.
# Just going to have a play here to get a feel how it might be done.

path5 <- "./data/raw_data/200001/71250DO003_200001.xls"

excel_sheets(path5)

# Unlike for 200506 and 201011, readxl is able to open these files.

read_excel(path5, sheet = 2, skip = 4)

# It looks like these sheets can be read in, and new column names specified.  
# The indenations are not preserved so SD groupings cannot be easily distinguished.
# For this work, we are mostly interested in the SLA data so it may be possible to skip rows with NAs.