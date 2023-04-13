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

# Search in ITIS
for(i in 77:length(sp)){
  
  
  tryCatch(cl <- classification(sci_id = sp[i], db = "itis")[[1]], error=function(e){})
  
  if(exists("cl")){
    
    if(all(!is.na(cl))){
      
      scientificName <- itis_terms(sp[i]) %>% 
        filter(tsn == cl$id[cl$rank == last(cl$rank)])
      scientificName <- paste(scientificName$scientificName, scientificName$author)
      
      taxon.cl.1 <- data.frame(kingdom = ifelse("kingdom" %in% cl$rank, cl$name[cl$rank == "kingdom"], NA),
                               phylum = ifelse("phylum" %in% cl$rank, cl$name[cl$rank == "phylum"], NA),
                               class = ifelse("class" %in% cl$rank, cl$name[cl$rank == "class"], NA),
                               order = ifelse("order" %in% cl$rank, cl$name[cl$rank == "order"], NA),
                               family = ifelse("family" %in% cl$rank, cl$name[cl$rank == "family"], NA),
                               genus = ifelse("genus" %in% cl$rank, cl$name[cl$rank == "genus"], NA),
                               species = ifelse("species" %in% cl$rank, cl$name[cl$rank == "species"], NA),
                               subspecies = ifelse("subspecies" %in% cl$rank, cl$name[cl$rank == "subspecies"], NA),
                               scientificName = scientificName)
      
      taxon.cl <- rbind(taxon.cl, taxon.cl.1)
      
    } else {
      # If not found in ITIS 
      taxon.cl.1 <- data.frame(kingdom = NA,
                               phylum = NA,
                               class = NA,
                               order = NA,
                               family = NA,
                               genus = NA,
                               species = NA,
                               subspecies = NA,
                               scientificName = sp[i])
      
      taxon.cl <- rbind(taxon.cl, taxon.cl.1)
      
    }
    
  } else {
    
    taxon.cl.1 <- data.frame(kingdom = NA,
                             phylum = NA,
                             class = NA,
                             order = NA,
                             family = NA,
                             genus = NA,
                             species = NA,
                             subspecies = NA,
                             scientificName = sp[i])
    
    taxon.cl <- rbind(taxon.cl, taxon.cl.1)
    
  }
  
  print(paste(i, "----", length(sp), "----"))
  rm(cl)
  }
