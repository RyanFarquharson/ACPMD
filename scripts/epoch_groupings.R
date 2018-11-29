# define groupings to enable consistency of commodity labels across differenet ABS censuses

library(readr)
library(dplyr)


# Explore data to creat groupings of commodities

commodities_epochs <- read_csv("./data/commodities_epochs.csv")
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

distinct_crops_area %>% filter(str_detect(str_to_lower(Commodity_label), "sugar"))

# create crop label

test <- mutate(distinct_crops_area, crop = ifelse(grepl("Wheat",distinct_crops_area$Commodity_label), "wheat",
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
                                                                                                                                                                  
                                                                                                                                                                  ""))))))))))))))))))

