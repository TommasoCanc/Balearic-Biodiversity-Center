##############################################
# Title: Pipeline CBB DB.                    #
# Author: Tommaso Cancellario & Antoni Far   #
# Reviewer:                                  #
# Creation: 2024 - 03 - 04 (yyyy - mm - dd)  #
# Last update: 2024 - 03 - 04                #
##############################################

# Install package (if required) and load.
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr, tidyverse)

# Load functions
fun <- list.files("./Functions/", full.names = TRUE)
sapply(fun, source)

# Load reviewed taxonomy file
df <- read.csv("./Template/Annelida.csv")
df <- read.csv("./Template/Annelida_noMarker.csv")

df <- df %>% 
  select(kingdom, phylum, order, family, genus, species, subspecies, marker)

head(df)

# Create long taxonomy format
df_long <- cbb_tree(df)

# Search taxonomy in COL
df_col <- cbbdbCol(df_long$Taxa)

