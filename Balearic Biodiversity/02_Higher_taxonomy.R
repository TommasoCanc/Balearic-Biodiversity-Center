######################################
# Title: Higher taxonomy             #
# Author: Tommaso Cancellario        #
# Reviewer:                          #
# Creation: 2023 - 03 - 28           #
# Last update: 2023 - 03 - 28        #
######################################

# Load libraries
library(dplyr)
library(taxize)

# Set WD
# setwd("/home/tcanc/OneDrive/Biodiversidad Baleares/Tom/")
setwd("/Users/tcanc/Library/CloudStorage/OneDrive-UniversitatdelesIllesBalears/Biodiversidad Baleares/Tom/")

# Load species list
species.list <- read.csv("./Lists/01_TaxonomyCheck/Reptilia_taxonomyCheck_2023-03-20_REVIEWED.csv", sep = ";")
head(species.list)

# Filter genus and species columns
sp <- as.character(species.list$originalName)

taxon.cl <- data.frame()

for(i in 1:length(sp)){
  
  cl <- classification(sp[i], db = "itis")[[1]]
  
  scientificName <- itis_terms(sp[i]) %>% 
    filter(tsn == cl$id[cl$rank == "species"])
  scientificName <- paste(scientificName$scientificName, scientificName$author)
  
  taxon.cl.1 <- data.frame(kingdom = cl$name[cl$rank == "kingdom"],
                           phylum = cl$name[cl$rank == "phylum"],
                           class = cl$name[cl$rank == "class"],
                           order = cl$name[cl$rank == "order"],
                           family = cl$name[cl$rank == "family"],
                           genus = cl$name[cl$rank == "genus"],
                           species = cl$name[cl$rank == "species"],
                           scientificName = scientificName)
  
  taxon.cl <- rbind(taxon.cl, taxon.cl.1)
  
}






