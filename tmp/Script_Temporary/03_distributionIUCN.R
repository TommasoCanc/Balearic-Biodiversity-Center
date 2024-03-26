######################################
# Title: IUCN download               #
# Author: Tommaso Cancellario        #
# Reviewer:                          #
# Creation: 2023 - 02 - 21           #
# Last update: 2023 - 03 - 15        #
######################################

# Load libraries
library(dplyr)
library(rredlist)

# Set WD
# setwd("/home/tcanc/OneDrive/Biodiversidad Baleares/Tom/")
setwd("/Users/tcanc/Library/CloudStorage/OneDrive-UniversitatdelesIllesBalears/Biodiversidad Baleares/Tom/")

# Load species list
species.list <- read.csv("./Lists/03_higherTaxonomy/Reptilia_higherTaxonomy_2023-04-13.csv", sep = ",")
head(species.list)

# Filter taxa columns
sp <- as.character(species.list$originalName)

sp.native <- data.frame()

for(i in 1:length(sp)){

  # Retrieve spatial information of NATIVE area from IUCN
  native <- rl_occ_country(sp[i], key = "adfd090eb40f601150b22d9676a3c228c1190bd7af733ac4e7172d683e31e1b4") 
  
  if(native$count != 0){
    sp.native.1 <- filter(native$result, distribution_code == "Native")
    sp.native.1$taxa <- native$name
  } else {
    sp.native.1 <- data.frame(code = NA,
                              country = NA,
                              presence = NA,
                              origin = NA,
                              distribution_code = NA,
                              taxa = native$name)
  }
  
  sp.native <- rbind(sp.native, sp.native.1)
  print(paste(i, "--- of ---", length(sp)))
}; rm(i, sp.native.1, native)

# Save csv
write.csv(sp.native, paste0("./Lists/04_IUCN/Reptilia_IUCN_", Sys.Date(),".csv"), row.names = F)
