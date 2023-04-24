######################################
# Title: Check reference tree        #
# Author: Tommaso Cancellario        #
# Reviewer:                          #
# Creation: 2023 - 04 - 21           #
# Last update: 2023 - 04 - 21        #
######################################

# Load libraries
library(biomonitoR)
library(readxl)
library(openxlsx)

# Set WD
# setwd("/home/tcanc/OneDrive/Biodiversidad Baleares/Tom/")
setwd("/Users/tcanc/Library/CloudStorage/OneDrive-UniversitatdelesIllesBalears/Biodiversidad Baleares/threatened_Balearic_species/")

# Load sheet 1
# getSheetNames("./tmp/threatenedSpecies_2023-04-24.xlsx")
species.list <- read_excel("./tmp/threatenedSpecies_2023-04-24.xlsx", 
                           sheet = "01_taxonomyCheck")
head(species.list)

# Filter column for biomonitoR check
species.list <- species.list[ ,c("phylum", "order", "family", 
                                 "genus", "species", "subspecies")]

colnames(species.list) <- c("Phylum", "Order", "Family", 
                            "Genus", "Species", "Subspecies")

ref_from_tree(as.data.frame(species.list))


