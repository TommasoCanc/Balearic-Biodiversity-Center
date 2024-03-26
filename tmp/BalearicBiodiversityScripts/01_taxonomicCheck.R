##############################################
# Title: Taxonomy check                      #
# Author: Tommaso Cancellario & Jorge Palomo #
# Reviewer:                                  #
# Creation: 2023 - 04 - 16                   #
# Last update: 2023 - 07 - 05                #
##############################################

# Load libraries
library(rgbif)

# Set WD
# setwd("/Users/tcanc/Library/CloudStorage/OneDrive-UniversitatdelesIllesBalears/Biodiversidad Baleares/threatened_Balearic_species/")
setwd("/Users/tcanc/Desktop/")


# Load species list
species.list <- read.csv("./biomonitoR/AMBI/name.csv", sep = ";")
head(species.list)

sp <- unique(species.list$Taxa)

# Reference database: GBIF
spCheck <- data.frame()

for(i in 1:length(sp)){
  
  tax_key <- name_backbone(sp[i])
  
  
  if(tax_key$matchType != "NONE") {
    
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
                            subspecies = ifelse(stringr::str_count(acceptedName.check$canonicalName, "\\w+") == 3, acceptedName.check$canonicalName, NA), # ifelse("subspecies" %in% colnames(acceptedName.check), acceptedName.check$subspecies, NA),
                            scientificName = acceptedName.check$scientificName,
                            taxonomicStatusOriginalName = ifelse("status" %in% colnames(tax_key), tax_key$status, NA),
                            taxonomicRank = ifelse("rank" %in% colnames(acceptedName.check), acceptedName.check$rank, NA)
    )
    
    
    
    spCheck <- rbind(spCheck, spCheck.1)
    
  } else {
    
    # Not found: the species is not present in GBIF
    spCheck.1 <- data.frame(originalName = sp[i],
                            acceptedName = "Not found",
                            kingdom = "Not found",
                            phylum = "Not found",
                            order = "Not found",
                            family = "Not found",
                            genus = "Not found",
                            species = "Not found",
                            subspecies = "Not found",
                            scientificName = "Not found",
                            taxonomicStatusOriginalName = "Not found",
                            taxonomicRank = "Not found")
    
    spCheck <- rbind(spCheck, spCheck.1)
    
    
  }
  
  print(paste(i, "---- of ----", length(sp)))
}
rm(tax_key, i, key, acceptedName.check, spCheck.1)


unique(species.list$Taxon == spCheck$originalName)

# Save file
write.csv(spCheck, paste0("./Plecoptera_GBIFChecked_", Sys.Date(),".csv"), row.names = FALSE)
