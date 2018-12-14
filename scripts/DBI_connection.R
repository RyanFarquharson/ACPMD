# connected to Access database using Connections tab in Rstudio
# help available at https://db.rstudio.com/odbc/


library(DBI)
con <- dbConnect(odbc::odbc(), "ABS198296")

# Look at what is in the database

dbListTables(con)
dbListFields(con, "Ag1983")
dbListFields(con, "Item_list")

# Create a list of tables

Aglist <- dbListTables(con, table_name = "Ag%")

# iterate through list to import into R as dataframes and use inner join to match up item info and save as csv

Item_listR <- dbReadTable(con, "Item_list")

for (item in Aglist) {
  tablename <- paste0(item,"R") 
  assign(tablename, dbReadTable(con, item) %>%
    inner_join(Item_listR) %>%
    select("Area_id", "Item_id", "Item_Name", "Units", "Value")%>%
      write_csv(path = paste0("./data/198296/",tablename))
  )
}

# concord to SA2s

# import ABS correspondence file

SLA_1996_SA2_2011 <- head(read_excel("./data/raw_data/concordance/CG_SLA_1996_SA2_2011.xls", sheet = "Table 3", skip = 5), n = -3)

# use an inner join to match up SLA names with the correspondence data

AgRlist <- paste0(Aglist,"R")

ABS <- data.frame(Area_id = integer(),
                  Item_id = integer(),
                  Item_Name = character(),
                  Units = character(),
                  Value = double())

# need to add a column for the census year in each table first. Then can iterate through.  .id doesn't work when iterating.

for (f in list.files("./data/198296/")) {
  new_table <- read_csv(paste0("./data/198296/",f))
  ABS <- bind_rows(ABS, new_table, .id = c("1983","1984",)
}



