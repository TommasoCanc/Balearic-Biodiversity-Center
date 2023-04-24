######################################
# Title: Taxonomy check              #
# Author: Tommaso Cancellario        #
# Reviewer:                          #
# Creation: 2023 - 04 - 16           #
# Last update: 2023 - 04 - 16        #
######################################

# Load libraries
library(openxlsx)
library(rgbif)

# Set WD
setwd("/Users/tcanc/Library/CloudStorage/OneDrive-UniversitatdelesIllesBalears/Biodiversidad Baleares/threatened_Balearic_species/")

# Load species list
species.list <- read.csv("./data/thTaxa.csv", sep = ";")
head(species.list)

sp <- unique(species.list$scientificName)

# Reference database: GBIF
spCheck <- data.frame()

for(i in 1:length(sp)){
  
  tax_key <- name_backbone(sp[i])
  key <- ifelse("acceptedUsageKey" %in% colnames(tax_key), tax_key$acceptedUsageKey, tax_key$usageKey)
  acceptedName.check <- name_usage(key = key)$data
  
  spCheck.1 <- data.frame(originalName = sp[i],
                          acceptedName = acceptedName.check$canonicalName,
                          kingdom = ifelse("kingdom" %in% colnames(acceptedName.check), acceptedName.check$kingdom, NA),
                          phylum = ifelse("phylum" %in% colnames(acceptedName.check), acceptedName.check$phylum, NA),
                          order = ifelse("order" %in% colnames(acceptedName.check), acceptedName.check$order, NA),
                          family = ifelse("family" %in% colnames(acceptedName.check), acceptedName.check$family, NA),
                          genus = ifelse("genus" %in% colnames(acceptedName.check), acceptedName.check$genus, NA),
                          species = ifelse("species" %in% colnames(acceptedName.check), acceptedName.check$species, NA),
                          subspecies = ifelse("subspecies" %in% colnames(acceptedName.check), acceptedName.check$subspecies, NA),
                          taxonomicStatusOriginalName = ifelse("status" %in% colnames(tax_key), tax_key$status, NA),
                          taxonomicRank = ifelse("rank" %in% colnames(acceptedName.check), acceptedName.check$rank, NA)
                          )
  
  spCheck <- rbind(spCheck, spCheck.1)
  print(paste(i, "---- of ----", length(sp)))
}
rm(tax_key, i, key, acceptedName.check, spCheck.1)

# Save file
write.xlsx(spCheck, paste0("./tmp/threatenedSpecies_", Sys.Date(),".xlsx"), sheetName="01_taxonomyCheck")
