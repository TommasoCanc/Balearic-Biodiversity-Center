##############################################
# Title: Pipeline CBB DB.                    #
# Author: Tommaso Cancellario & Antoni Far   #
# Reviewer:                                  #
# Creation: 2024 - 03 - 04 (yyyy - mm - dd)  #
# Last update: 2024 - 03 - 04                #
##############################################


if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr, tidyverse)

# Load functions
fun <- list.files("YOUR PATH TO FUNCTION FOLDER", full.names = TRUE)
for (i in fun) {
  source(i)
}; rm (fun, i)


# Load reviewed taxonomy file
df <- read.csv("YOUR PATH TO TAXON CSV", sep = ";")

df <- df %>% 
  select(Kingdom, Phylum, Order, Family, Genus, Species, Subspecies)

head(df)

# Create long taxonomy format
df_long <- cbb_tree(df) 

# Search taxonomy in COL
df_col <- cbbdbCol(df_long$Taxa)
