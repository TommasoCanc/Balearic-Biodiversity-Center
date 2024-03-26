##############################################
# Title: Pipeline CBB DB.                    #
# Author: Tommaso Cancellario & Antoni Far   #
# Reviewer:                                  #
# Creation: 2024 - 03 - 04 (yyyy - mm - dd)  #
# Last update: 2024 - 03 - 04                #
##############################################

library(dplyr)
library(tidyverse)

# Load functions
fun <- list.files("./Desktop/GitHub/CBB_dataAnalysis/Balearic_species_lists_pipeline_test/fun/", full.names = TRUE)
for (i in fun) {
  source(i)
}; rm (fun, i)


# Load reviewed taxonomy file


df <- read.csv("./Desktop/miriapodos.csv", sep = ";")

df <- df %>% 
  select(Kingdom, Phylum, Order, Family, Genus, Species, Subspecies)

head(df)

# Create long taxonomy format
df_long <- cbb_tree(df) 

# Search taxonomy in COL
df_col <- cbbdbCol(df_long$Taxa[30:40])
