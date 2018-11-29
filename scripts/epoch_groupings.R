# define groupings to enable consistency of commodity labels across differenet ABS censuses

library(readr)
library(dplyr)


# Explore data to creat groupings of commodities

commodities_epochs <- read_csv("./data/commodities_epochs.csv", col_types = "iicccccddcc")
commodities_epochs$Commodity_code <- as.character(commodities_epochs$Commodity_code)


distinct_labels <- commodities_epochs %>% select(census, Commodity_code, Commodity_label) %>% distinct

# filter to get commodities of interest.  Can use regex, stringr...

# for specific whole labels:
#distinct_labels %>% filter(Commodity_label %in% c("",""))

# for detection: 

library(stringr)

distinct_crops <- distinct_labels %>% filter(str_detect(str_to_lower(Commodity_label), "cereal") | 
                                               str_detect(str_to_lower(Commodity_label), "broadacre") |
                                               str_detect(str_to_lower(Commodity_label), "hay"))

distinct_crops_area <- distinct_crops %>% filter(str_detect(str_to_lower(Commodity_label), "area"))

# code to check existince of crop within labels across censuses.  If a single lable for each census, use in mutate below.  If not, think about a solution.

distinct_crops_area %>% filter(str_detect(str_to_lower(Commodity_label), "cotton"))

# create crop label

sugarcane_crush <- c("Non-cereal broadacre crops - Sugar cane - total area (ha)",
                     "Broadacre crops - Non-cereal crops - Sugar cane - Cut for crushing - Area (ha)",
                     "Broadacre crops - Non-cereal crops - Sugar cane - Cut for plants - Area (ha)",
                     "Broadacre crops - Non-cereal crops - Sugar cane - Standover from 2010 season - Area (ha)",
                     "Broadacre crops - Non-cereal crops - Sugar cane - Newly planted in 2010 for harvest in a following season - Area (ha)",
                     "Broadacre crops - Non-cereal crops - Sugar cane - Total - Area (ha)")

test <- mutate(distinct_crops_area,
               crop = ifelse(grepl("Wheat",distinct_crops_area$Commodity_label), "wheat",
                      ifelse(grepl("Oats",distinct_crops_area$Commodity_label), "oats",
                      ifelse(grepl("Triticale",distinct_crops_area$Commodity_label), "triticale",
                      ifelse(grepl("Barley",distinct_crops_area$Commodity_label), "barley",
                      ifelse(grepl("Sorghum",distinct_crops_area$Commodity_label), "sorghum",
                      ifelse(grepl("Maize",distinct_crops_area$Commodity_label), "maize",
                      ifelse(grepl("Oats",distinct_crops_area$Commodity_label), "oats",
                      ifelse(grepl("Canola",distinct_crops_area$Commodity_label), "canola",
                      ifelse(grepl("Rice for grain",distinct_crops_area$Commodity_label), "rice",
                      ifelse(grepl("Chickpeas",distinct_crops_area$Commodity_label), "chickpeas",
                      ifelse(grepl("Lentils",distinct_crops_area$Commodity_label), "lentils",
                      ifelse(grepl("Lupins",distinct_crops_area$Commodity_label), "lupins",
                      ifelse(grepl("Rice for grain",distinct_crops_area$Commodity_label), "rice",
                      ifelse(grepl("Cotton - irrigated",distinct_crops_area$Commodity_label), "cotton_irrigated",
                      ifelse(grepl("Cotton (irrigated)",distinct_crops_area$Commodity_label), "cotton_irrigated",
                      ifelse(grepl("Cotton - non irrigated",distinct_crops_area$Commodity_label), "cotton_nonirrigated",
                      ifelse(grepl("Cotton (non-irrigated)",distinct_crops_area$Commodity_label), "cotton_nonirrigated",
                      ifelse(grepl("Sugar cane - total",distinct_crops_area$Commodity_label), "sugarcane",
                      ifelse(grepl("Sugar cane - Cut",distinct_crops_area$Commodity_label), "sugarcane",
                      ifelse(grepl("Sugar cane - Standover",distinct_crops_area$Commodity_label), "sugarcane",
                      ifelse(grepl("Sugar cane - Newly",distinct_crops_area$Commodity_label), "sugarcane",
                      ifelse(grepl("Sugar cane (plant or other - not for crushing) - Area (ha)",distinct_crops_area$Commodity_label), "sugarcane",
                      ifelse(grepl("Peanuts",distinct_crops_area$Commodity_label), "peanuts",
                                    
                      
                      ""))))))))))))))))))))))))

