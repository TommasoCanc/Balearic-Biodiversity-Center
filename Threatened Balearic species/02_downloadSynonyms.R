######################################
# Title: Pick up synonyms GBIF       #
# Author: Tommaso Cancellario        #
# Reviewer:                          #
# Creation: 2023 - 04 - 24           #
# Last update: 2023 - 04 - 24        #
######################################

# Load libraries
library(openxlsx)
library(rgbif)

# Set WD
setwd("/Users/tcanc/Library/CloudStorage/OneDrive-UniversitatdelesIllesBalears/Biodiversidad Baleares/threatened_Balearic_species/")

# Load sheet 1
# getSheetNames("./tmp/threatenedSpecies_2023-04-24.xlsx")
species.list <- read.xlsx("./tmp/threatenedSpecies_2023-04-24.xlsx", 
                           sheet = "01_taxonomyCheck")
head(species.list)

# Filter for species and subspecies rank
species.list <- species.list[species.list$taxonomicRank == "SPECIES" |
                             species.list$taxonomicRank == "SUBSPECIES", ]
unique(species.list$taxonomicRank)

sp <- species.list$acceptedName


# Download synonyms
spSyn <- data.frame()

for(i in 1:length(sp)){
  
  # Search taxa GBIF key
  taxKey <- name_backbone(sp[i])
  key <- ifelse("acceptedUsageKey" %in% colnames(taxKey), taxKey$acceptedUsageKey, taxKey$usageKey)
  
  # Search possible synonyms
  taxSyn <- jsonlite::fromJSON(paste0("https://api.gbif.org/v1/species/", key, "/synonyms"))
  
  # Create data set with synonym
  if(length(taxSyn$results) != 0){
    
    synonym <- taxSyn$results$canonicalName
    taxonomicStatus = taxSyn$results$taxonomicStatus
    
    spSyn.1 <- data.frame(originalName = sp[i],
                          synonym = synonym,
                          taxonomicStatus = taxonomicStatus)
  } else {
    
    spSyn.1 <- data.frame(originalName = sp[i],
                          synonym = NA,
                          taxonomicStatus = taxKey$status)
    
  }
  
  spSyn <- rbind(spSyn, spSyn.1)
  print(paste(i, "---- of ----", length(sp)))
  
}
rm(taxKey, key, taxSyn, synonym, taxonomicStatus, spSyn.1, i)

# Save file
wb <- loadWorkbook("./tmp/threatenedSpecies_2023-04-24.xlsx")
newSheet <- addWorksheet(wb, sheetName = "02_downloadSynonyms")
writeData(wb, sheet = "02_downloadSynonyms", x = spSyn)
saveWorkbook(wb, "./tmp/threatenedSpecies_2023-04-24.xlsx", overwrite = TRUE)
