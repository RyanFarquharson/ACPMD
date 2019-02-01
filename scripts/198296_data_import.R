# The 1982 to 1996 ABS agstats are contained in a Microsoft Access database
# The database can be accessed in R using an ODBC connection.
# The ODBC is configured in Windows.  Go to ODBC Data Source Administrator and Add a ODBC Microsoft Access Setup, in which you specify to file to which you want to connect.
# The ODBC name is ABS198296
# It points to conAgStats4_2000.mdb

# connected to Access database using Connections tab in Rstudio
# help available at https://db.rstudio.com/odbc/


library(DBI)
con <- dbConnect(odbc::odbc(), "ABS198296")

# Look at what is in the database

dbListTables(con)
dbListFields(con, "Ag1983")
dbListFields(con, "Item_list")
dbListFields(con, "ASGC96")

# Create a list of tables

Aglist <- dbListTables(con, table_name = "Ag%")

# iterate through list to import into R as dataframes and use inner join to match up item info and save as csv

Item_listR <- dbReadTable(con, "Item_list")
ASGC96R <- dbReadTable(con, "ASGC96")

for (item in Aglist) {
  tablename <- paste0(item,"R") 
  assign(tablename, dbReadTable(con, item) %>%
    inner_join(Item_listR) %>%
      inner_join(ASGC96R) %>%
    select("Area_id", "Name", "Item_id", "Item_Name", "Units", "Value")%>%
      write_csv(path = paste0("./data/198296/",tablename))
  )
}


# Add a column for the census year in each table first then bind rows.

Yearlist <- seq(1982,1996,1)

ABS <- data.frame(Area_id = integer(),
                  Name = character(),
                  Item_id = integer(),
                  Item_Name = character(),
                  Units = character(),
                  Value = double(),
                  Year = integer())

counter <- 1
for (f in list.files("./data/198296/")) {
  new_table <- read_csv(paste0("./data/198296/",f))
  new_table$Year <- Yearlist[counter]
  ABS <- bind_rows(ABS, new_table)
  counter <- counter + 1
}

# concord to SA2s

# import ABS correspondence file

# Note, CG is a population grid correspondence.  Need to find a CA correspondence for 1996 SLA to 2011 SA2 and repeat.
# I have requested an area correspondence for 1996 SLA to 2011 SA2 from ABS (31/01/2019)

SLA_1996_SA2_2011 <- head(read_excel("./data/raw_data/concordance/CG_SLA_1996_SA2_2011.xls", sheet = "Table 3", skip = 5), n = -3)


# use an inner join to match up SLA names with the correspondence data

ABS_SA2 <- inner_join(ABS, SLA_1996_SA2_2011, by = c("Name" = "SLA_NAME_1996"))

# Use the concordance data to calculate new "Estimate" values by SA2

ABS_SA2$Estimate_SA2 <- ABS_SA2$Value * ABS_SA2$RATIO


-------------

# Use a group_by and summarise to sum Estimates for each commodity by SA2

commodities_198296_SA2 <- ABS_SA2 %>%
  select(`SA2_MAINCODE_2011`, SA2_NAME_2011, `Item_Name`, Estimate_SA2) %>%
  group_by(`SA2_MAINCODE_2011`, SA2_NAME_2011, `Item_Name`) %>%
  summarise(SA2Est = sum(Estimate_SA2))

# rename columns to be consistent across all epochs

commodities_198296_SA2 <- rename(commodities_198296_SA2,
                                 ASGS_code = "SA2_MAINCODE_2011",
                                 ASGS_label = "SA2_NAME_2011",
                                 Commodity = "Item_Name",
                                 Estimate = "SA2Est"
)

write_csv(commodities_198296_SA2, "./data/commodities_198296_SA2.csv")
