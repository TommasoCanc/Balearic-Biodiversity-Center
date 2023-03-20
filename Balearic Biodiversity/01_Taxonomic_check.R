######################################
# Title: Taxonomy check              #
# Author: Tommaso Cancellario        #
# Reviewer:                          #
# Creation: 2023 - 02 - 21           #
# Last update: 2023 - 03 - 20        #
######################################


# Load libraries
library(dplyr)
library(taxize)

# Set WD
# setwd("/home/tcanc/OneDrive/Biodiversidad Baleares/Tom/")
setwd("/Users/tcanc/Library/CloudStorage/OneDrive-UniversitatdelesIllesBalears/Biodiversidad Baleares/Tom/")

# Load species list
species.list <- read.csv("./Lists/originalList/Reptilia_2023_03_17.csv", sep = ";")
head(species.list)

# Filter genus and species columns
sp <- as.character(species.list$Taxon)

# Check for synonyms
sp.list <- data.frame()

for(i in 1:length(sp)){
  
  # Skip the error 404
  tryCatch({ 
    # Open connection to url 
    acceptedName <- synonyms(sci_id = sp[i], db = "itis")[[1]]
    }, error = function(e){}
    )
  
  if(exists("acceptedName")) {
  if("acc_name" %in% colnames(acceptedName)){
    
    acceptedName <- select(acceptedName, acc_name) %>% 
      distinct()
    
    sp.list.1 <- data.frame(originalName = sp[i],
                            acceptedName = acceptedName[1,1])
    
  } else {
    
    # If acceptedName is not a dataframe is an NA value and it happens when 
    # no names is found in ITIS database
    sp.list.1 <- data.frame(originalName = sp[i],
                            acceptedName = ifelse(is.data.frame(acceptedName), "", "Not found"))
    
  } 
    sp.list <- rbind(sp.list, sp.list.1)
    rm(acceptedName)
  } else {
    # If the error 404 happen "no data" values is produced
    sp.list.1 <- data.frame(originalName = sp[i],
                            acceptedName = "Not data")
    sp.list <- rbind(sp.list, sp.list.1)
  }
  
  print(paste(i, "--- of ---", length(sp)))

}

# Save .csv
write.csv2(sp.list, paste0("./Lists/01_TaxonomyCheck/Reptilia_taxonomyCheck_", Sys.Date(),".csv"), row.names = F)