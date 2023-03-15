######################################
# Title: GBIF download,              #
# Author: Tommaso Cancellario        #
# Reviewer:                          #
# Creation: 2023 - 02 - 21           #
# Last update: 2023 - 03 - 15        #
######################################

# Load libraries
library(dplyr)
library(rgbif)
library(stringr)
# library(ggplot2)
# library(sf)

# Functions
"%ni%" <- Negate("%in%")

# Set WD
# setwd("/home/tcanc/OneDrive/Biodiversidad Baleares/Tom/")
setwd("/Users/tcanc/Library/CloudStorage/OneDrive-UniversitatdelesIllesBalears/Biodiversidad Baleares/Tom/")

# Load species list
species.list <- read.csv("./Lists/originalList/Amphibia_2023_03_15.csv", sep = ";")
head(species.list)

# Filter genus and species columns
sp <- as.character(species.list$Taxon)

# Extract genus
gen <- unique(word(sp, 1))

# Spatial polygon for Balearic islands
balearic <- "POLYGON((0.898 38,4.592 38,4.592 40.295,0.898 40.295,0.898 38))"

########################
# Species distribution #
########################

# Set kingdom parameter for the function tax_key
kingdom <- "animalia"

sp.gbif <- list(info = data.frame(),
                data = data.frame())

for(i in 1:length(sp)){
  
  # Use the name_suggest function to get the gbif taxon key
  tax_key <- name_backbone(sp[i], kingdom = kingdom)
  key <- ifelse("acceptedUsageKey" %in% colnames(tax_key), tax_key$acceptedUsageKey, tax_key$usageKey)
  acceptedName.check <- name_usage(key = key)
  # tax_key <- name_suggest(q = sp[i])
  # tax_key <- tax_key$data$key[tax_key$data$rank == "SPECIES"]
  # Number of occurrence in Spain
  nOcc <- occ_count(key, country = "ES")
  
  # List of occurrence in Balearic islands
  dat_ne <- occ_search(taxonKey = key, hasCoordinate = T, 
                       geometry = balearic, limit = 199999)
  nOccBal <- dat_ne$meta$count
  dat_ne <- dat_ne$data
  
  # Add un if(!is.null(dat_ne)){} 
  
  if(!is.null(dat_ne)){
    if("scientificName" %in% colnames(dat_ne))
    {scientificName <- data.frame(dat_ne$scientificName)
    } else {scientificName <- rep(NA, nrow(dat_ne))}
    
    if("acceptedScientificName" %in% colnames(dat_ne))
    {acceptedScientificName <- data.frame(dat_ne$acceptedScientificName)
    } else {acceptedScientificName <- rep(NA, nrow(dat_ne))}
    
    if("decimalLatitude" %in% colnames(dat_ne))
    {decimalLatitude <- data.frame(dat_ne$decimalLatitude)
    } else {decimalLatitude <- rep(NA, nrow(dat_ne))}
    
    if("decimalLongitude" %in% colnames(dat_ne))
    {decimalLongitude <- data.frame(dat_ne$decimalLongitude)
    } else {decimalLongitude <- rep(NA, nrow(dat_ne))}
    
    if("year" %in% colnames(dat_ne))
    {year <- data.frame(dat_ne$year)
    } else {year <- rep(NA, nrow(dat_ne))}
    
    if("institutionCode" %in% colnames(dat_ne))
    {institutionCode <- data.frame(dat_ne$institutionCode)
    } else {institutionCode <- rep(NA, nrow(dat_ne))}
    
    if("locality" %in% colnames(dat_ne))
    {locality <- data.frame(dat_ne$locality)
    } else {locality <- rep(NA, nrow(dat_ne))}
    
    if("datasetName" %in% colnames(dat_ne))
    {datasetName <- data.frame(dat_ne$datasetName)
    } else {datasetName <- rep(NA, nrow(dat_ne))}
    
    dat_ne <- cbind(scientificName, acceptedScientificName, decimalLatitude, decimalLongitude,
                    year, institutionCode, locality, datasetName)
    
    colnames(dat_ne) <- c("scientificName", "acceptedScientificName", "decimalLatitude", 
                          "decimalLongitude", "year", "institutionCode", 
                          "locality", "datasetName")
    
  } else {
    
    dat_ne <- data.frame(scientificName = sp[i], 
                         acceptedScientificName = acceptedName.check$data$scientificName, 
                         decimalLatitude = NA, 
                         decimalLongitude = NA,
                         year = NA, 
                         institutionCode = NA, 
                         locality = NA, 
                         datasetName= NA)
  }
  
  
  info <- data.frame(originalSpecies = sp[i],
                     acceptedName = acceptedName.check$data$scientificName, #unique(dat_ne$acceptedScientificName),
                     tax_key = key,
                     status = tax_key$status,
                     nOcc.ES = nOcc,
                     nOcc.BAL = nOccBal)
  # We consider the species present if the number of occurrence is >= 5
  info$presenceAbsence <- ifelse(info$nOcc.BAL >= 5, "present", "absent") 
  
  sp.gbif$info <- rbind(sp.gbif$info, info)
  
  sp.gbif$data <- rbind(sp.gbif$data, dat_ne)
  
  print(paste(i, "--- of ---", length(sp)))
} 
rm(tax_key, key, nOcc, dat_ne, info, i, acceptedScientificName, acceptedName.check, 
   datasetName, decimalLatitude, decimalLongitude, institutionCode, locality, 
   scientificName, year, nOccBal)

sp.gbif$info
sp.gbif$data

sp.gbif$info$source <- "Original list"

######################
# Genus distribution #
######################

# Remove genus if does not work.
# Eschatocephalus (i=50)
# gen <- gen[-50]

# Check if the original list is complete, we search in GBIF all the species 
# belonging to a specific genus

sp.gen <- data.frame()

for(i in 1:length(gen)){
  
  # Use the name_suggest function to get the gbif taxon key
  tax_key <- name_backbone(gen[i], kingdom = kingdom)
  key <- ifelse("acceptedUsageKey" %in% colnames(tax_key), tax_key$acceptedUsageKey, tax_key$usageKey)
  acceptedName.check <- name_usage(key = key)
  
  # Retrive all the species belonging a specific genus from GBIF
  sp <- name_usage(acceptedName.check$data$key, data="children", limit = 99999)$data %>% 
    filter(!is.na(species)) %>% 
    pull(species) %>% 
    as.data.frame()
  colnames(sp) <- "Taxa"
  
  sp.gen <- rbind(sp.gen, sp)
  
  print(paste(i, "--- of ---", length(gen)))
}
rm(acceptedName.check, tax_key, i, key)

# Check if we have different genus compared to the original list
unique(word(sp.gen$Taxa, 1)) %in% gen

sp.gen <- sp.gen$Taxa
genus.gbif <- list(info = data.frame(),
                   data = data.frame())

# NOTE: Check and remove i Taxa if the loop is blocked.
# Removed Arachnida: 111-Aranea spec;
# sp.gen[923]

for(i in 1:length(sp.gen)){
  
  # Use the name_suggest function to get the gbif taxon key
  tax_key <- name_backbone(sp.gen[i], kingdom = kingdom)
  key <- ifelse("acceptedUsageKey" %in% colnames(tax_key), tax_key$acceptedUsageKey, tax_key$usageKey)
  acceptedName.check <- name_usage(key = key)
  fossil <- occ_search(taxonKey = key, limit = 1)$data$basisOfRecord
  
  # Number of occurrence in Spain
  nOcc <- occ_count(key, country = "ES")
  
  # List of occurrence in Balearic islands
  dat_ne <- occ_search(taxonKey = key, hasCoordinate = T, 
                       geometry = balearic, limit = 199999)
  nOccBal <- dat_ne$meta$count
  dat_ne <- dat_ne$data
  
  # Add un if(!is.null(dat_ne)){} 
  
  if(!is.null(dat_ne)){
    if("scientificName" %in% colnames(dat_ne))
    {scientificName <- data.frame(dat_ne$scientificName)
    } else {scientificName <- rep(NA, nrow(dat_ne))}
    
    if("acceptedScientificName" %in% colnames(dat_ne))
    {acceptedScientificName <- data.frame(dat_ne$acceptedScientificName)
    } else {acceptedScientificName <- rep(NA, nrow(dat_ne))}
    
    if("decimalLatitude" %in% colnames(dat_ne))
    {decimalLatitude <- data.frame(dat_ne$decimalLatitude)
    } else {decimalLatitude <- rep(NA, nrow(dat_ne))}
    
    if("decimalLongitude" %in% colnames(dat_ne))
    {decimalLongitude <- data.frame(dat_ne$decimalLongitude)
    } else {decimalLongitude <- rep(NA, nrow(dat_ne))}
    
    if("year" %in% colnames(dat_ne))
    {year <- data.frame(dat_ne$year)
    } else {year <- rep(NA, nrow(dat_ne))}
    
    if("institutionCode" %in% colnames(dat_ne))
    {institutionCode <- data.frame(dat_ne$institutionCode)
    } else {institutionCode <- rep(NA, nrow(dat_ne))}
    
    if("locality" %in% colnames(dat_ne))
    {locality <- data.frame(dat_ne$locality)
    } else {locality <- rep(NA, nrow(dat_ne))}
    
    if("datasetName" %in% colnames(dat_ne))
    {datasetName <- data.frame(dat_ne$datasetName)
    } else {datasetName <- rep(NA, nrow(dat_ne))}
    
    if("basisOfRecord" %in% colnames(dat_ne))
    {basisOfRecord <- data.frame(dat_ne$basisOfRecord)
    } else {basisOfRecord <- rep(NA, nrow(dat_ne))}
    
    dat_ne <- cbind(scientificName, acceptedScientificName, decimalLatitude, decimalLongitude,
                    year, institutionCode, locality, datasetName, basisOfRecord)
    
    colnames(dat_ne) <- c("scientificName", "acceptedScientificName", "decimalLatitude", 
                          "decimalLongitude", "year", "institutionCode", 
                          "locality", "datasetName", "basisOfRecord")
    
  } else {
    
    dat_ne <- data.frame(scientificName = sp.gen[i], 
                         acceptedScientificName = acceptedName.check$data$scientificName, 
                         decimalLatitude = NA, 
                         decimalLongitude = NA,
                         year = NA, 
                         institutionCode = NA, 
                         locality = NA, 
                         datasetName = NA,
                         basisOfRecord = ifelse(!is.null(fossil), fossil, NA))
  }
  
  
  info <- data.frame(originalSpecies = sp.gen[i],
                     acceptedName = acceptedName.check$data$scientificName, #unique(dat_ne$acceptedScientificName),
                     tax_key = key,
                     status = tax_key$status,
                     nOcc.ES = nOcc,
                     nOcc.BAL = nOccBal)
  # We consider the species present if the number of occurrence is >= 5
  info$presenceAbsence <- ifelse(info$nOcc.BAL >= 5, "present", "absent")
  
  genus.gbif$info <- rbind(genus.gbif$info, info)
  
  genus.gbif$data <- rbind(genus.gbif$data, dat_ne)
  
  print(paste(i, "--- of ---", length(sp.gen)))
}
rm(tax_key, key, nOcc, dat_ne, info, i, acceptedScientificName, acceptedName.check, 
   datasetName, decimalLatitude, decimalLongitude, institutionCode, locality, 
   scientificName, year, nOccBal, fossil, basisOfRecord)

tail(genus.gbif$info)
tail(genus.gbif$data)


# Remove fossil record from info and data files
fossil.rm <- genus.gbif$data$acceptedScientificName[which(genus.gbif$data$basisOfRecord == "FOSSIL_SPECIMEN")]

genus.gbif$info <- genus.gbif$info[genus.gbif$info$acceptedName %ni% fossil.rm, ]
genus.gbif$data <- genus.gbif$data[genus.gbif$data$basisOfRecord != "FOSSIL_SPECIMEN", ]

# unique(genus.gbif$data$basisOfRecord)

# Remove records do not present in Spain
noEs <- genus.gbif$info[genus.gbif$info$nOcc.ES == 0, ]

genus.gbif$data <- genus.gbif$data[genus.gbif$data$acceptedScientificName %ni% noEs, ]
genus.gbif$info <- genus.gbif$info[genus.gbif$info$nOcc.ES != 0, ] %>% 
  distinct(acceptedName, .keep_all = TRUE)

genus.gbif$info$source <- "Genus derived"

# Remove rows that contains all NA's
genus.gbif$data <- filter(genus.gbif$data, rowSums(is.na(genus.gbif$data)) != ncol(genus.gbif$data))

# Merge gbif species list and list created starting from the genus.
gbifInfo <- merge(sp.gbif$info, genus.gbif$info, by = "acceptedName", all = TRUE)

# Save .csv
write.csv2(gbifInfo, paste0("./Lists/gbif/Amphibia_gbifInfo_", Sys.Date(),".csv"), row.names = F, fileEncoding = "macroman")
write.csv2(genus.gbif$info, paste0("./Lists/gbif/Amphibia_genusInfo_", Sys.Date(),".csv"), row.names = F, fileEncoding = "macroman")

write.csv2(sp.gbif$data, paste0("./Lists/gbif/Amphibia_gbifData_", Sys.Date(),".csv"), row.names = F, fileEncoding = "macroman")
write.csv2(genus.gbif$data, paste0("./Lists/gbif/Amphibia_genusData_", Sys.Date(),".csv"), row.names = F, fileEncoding = "macroman")

#####################
# Distribution plot #
#####################

# Load Balearic shape file
balearic.sp <- read_sf("../Shapefile/Balearic_Islands/Balearic_4326.shp")
marine.sp <- read_sf("../Shapefile/Maritime_boundaries_balearic/Marine_boundaries_Balearic_polygon_4326.shp")

sp.gbif.sf <- sp.gbif$data %>% 
  select(decimalLongitude, decimalLatitude) %>% 
  na.omit %>% # Remove NA
  st_as_sf(coords = c("decimalLongitude", "decimalLatitude")) %>% 
  st_set_crs(st_crs(balearic.sp))


pdf(file = "../Plot/Odonata_Balearic.pdf")
ggplot() +
  geom_sf(data = balearic.sp) +
  geom_sf(data = marine.sp, fill = NA) +
  geom_sf(data = sp.gbif.sf, size = .5, color = "#FFC465") +
  theme_bw()
dev.off()

rm(list = ls())
