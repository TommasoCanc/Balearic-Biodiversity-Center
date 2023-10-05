##############################################
# Title: GBIF download                       #
# Author: Tommaso Cancellario & Jorge Palomo #
# Reviewer:                                  #
# Creation: 2023 - 02 - 21                   #
# Last update: 2023 - 07 - 13                #
##############################################

# Load libraries
pacman::p_load(dplyr, rgbif, stringr)

# Functions
"%ni%" <- Negate("%in%")

# Set WD
# setwd("/home/tcanc/OneDrive/Biodiversidad Baleares/Tom/")
setwd("~/Desktop/")

# Set group name
grName <- "Mammalia"

# Load species list
species.list <- read.csv("./Mammalia_FEDist_2023-07-10.csv", sep = ";")
head(species.list)

# Filter genus and species columns
sp <- as.character(species.list$taxaOriginal.x)
sp <- sp[complete.cases(sp)]

# Extract genus
gen <- unique(word(sp, 1))

# Spatial polygon for Balearic islands
balearic <- "POLYGON((0.898 38,4.592 38,4.592 40.295,0.898 40.295,0.898 38))"

########################
# Species distribution #
########################

# Set kingdom parameter for the function tax_key
kingdom <- "animalia"

# sp.gbif <- list(info = data.frame(),
#                 data = data.frame())

sp.gbif <- data.frame()


for(i in 1:length(sp)){
  
  # Use the name_suggest function to get the gbif taxon key
  tax_key <- name_backbone(sp[i], kingdom = kingdom)
  key <- ifelse("acceptedUsageKey" %in% colnames(tax_key), tax_key$acceptedUsageKey, tax_key$usageKey)
  acceptedName.check <- name_usage(key = key)
  # tax_key <- name_suggest(q = sp[i])
  # tax_key <- tax_key$data$key[tax_key$data$rank == "SPECIES"]
  # Number of occurrence in Spain
  nOcc <- occ_count(taxonKey = key, country = "ES")
  
  # List of occurrence in Balearic islands
  dat_ne <- occ_search(taxonKey = key, hasCoordinate = T, 
                       geometry = balearic, limit = 199999)
  nOccBal <- dat_ne$meta$count
  dat_ne <- dat_ne$data
  
  fossil <- ifelse(isTRUE(unique(dat_ne$basisOfRecord) == "FOSSIL_SPECIMEN"), "FOSSIL", "PRESENT")
  
  
  # Add un if(!is.null(dat_ne)){} 
  
  # if(!is.null(dat_ne)){
  #   if("scientificName" %in% colnames(dat_ne))
  #   {scientificName <- data.frame(dat_ne$scientificName)
  #   } else {scientificName <- rep(NA, nrow(dat_ne))}
  #   
  #   if("acceptedScientificName" %in% colnames(dat_ne))
  #   {acceptedScientificName <- data.frame(dat_ne$acceptedScientificName)
  #   } else {acceptedScientificName <- rep(NA, nrow(dat_ne))}
  #   
  #   if("decimalLatitude" %in% colnames(dat_ne))
  #   {decimalLatitude <- data.frame(dat_ne$decimalLatitude)
  #   } else {decimalLatitude <- rep(NA, nrow(dat_ne))}
  #   
  #   if("decimalLongitude" %in% colnames(dat_ne))
  #   {decimalLongitude <- data.frame(dat_ne$decimalLongitude)
  #   } else {decimalLongitude <- rep(NA, nrow(dat_ne))}
  #   
  #   if("year" %in% colnames(dat_ne))
  #   {year <- data.frame(dat_ne$year)
  #   } else {year <- rep(NA, nrow(dat_ne))}
  #   
  #   if("institutionCode" %in% colnames(dat_ne))
  #   {institutionCode <- data.frame(dat_ne$institutionCode)
  #   } else {institutionCode <- rep(NA, nrow(dat_ne))}
  #   
  #   if("locality" %in% colnames(dat_ne))
  #   {locality <- data.frame(dat_ne$locality)
  #   } else {locality <- rep(NA, nrow(dat_ne))}
  #   
  #   if("datasetName" %in% colnames(dat_ne))
  #   {datasetName <- data.frame(dat_ne$datasetName)
  #   } else {datasetName <- rep(NA, nrow(dat_ne))}
  #   
  #   dat_ne <- cbind(scientificName, acceptedScientificName, decimalLatitude, decimalLongitude,
  #                   year, institutionCode, locality, datasetName)
  #   
  #   colnames(dat_ne) <- c("scientificName", "acceptedScientificName", "decimalLatitude", 
  #                         "decimalLongitude", "year", "institutionCode", 
  #                         "locality", "datasetName")
  #   
  # } else {
  #   
  #   dat_ne <- data.frame(scientificName = sp[i], 
  #                        acceptedScientificName = acceptedName.check$data$scientificName, 
  #                        decimalLatitude = NA, 
  #                        decimalLongitude = NA,
  #                        year = NA, 
  #                        institutionCode = NA, 
  #                        locality = NA, 
  #                        datasetName= NA)
  # }
  
  # We consider the species present if the number of occurrence is >= 5
  info <- data.frame(originalSpecies = sp[i],
                     acceptedName = acceptedName.check$data$scientificName, #unique(dat_ne$acceptedScientificName),
                     tax_key = key,
                     status = tax_key$status,
                     nOcc.ES = nOcc,
                     nOcc.BAL = nOccBal,
                     fossil = fossil,
                     presenceAbsence = ifelse(nOccBal >= 5, "present", "absent"))
  
  
  # info$presenceAbsence <- ifelse(info$nOcc.BAL >= 5, "present", "absent") 
  
  sp.gbif <- rbind(sp.gbif, info)
  
  # sp.gbif$data <- rbind(sp.gbif$data, dat_ne)
  
  print(paste(i, "--- of ---", length(sp)))
} 
rm(tax_key, key, nOcc, dat_ne, info, i, acceptedName.check, nOccBal, fossil)

sp.gbif$source <- "Original list"
sp.gbif


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
unique(unique(word(sp.gen$Taxa, 1)) %in% gen) # It has to be TRUE

sp.gen <- sp.gen$Taxa[!grepl("\\s+spec\\b", sp.gen$Taxa)]

# Remove genus not present into the original list
gen.remove <- unique(word(sp.gen, 1))[unique(word(sp.gen, 1)) %ni% gen]
if(length(gen.remove) != 0){
  sp.gen <- sp.gen[!grepl(paste(gen.remove, collapse="|"), sp.gen)]
} else {
  sp.gen
}

sp.gen <- unique(sp.gen)


genus.gbif <- data.frame()

for(i in 878:length(sp.gen)){
  
  # Use the name_suggest function to get the gbif taxon key
  tax_key <- name_backbone(sp.gen[i], kingdom = kingdom)
  key <- ifelse("acceptedUsageKey" %in% colnames(tax_key), tax_key$acceptedUsageKey, tax_key$usageKey)
  acceptedName.check <- name_usage(key = key)

  # Number of occurrence in Spain
  nOcc <- occ_count(taxonKey = key, country = "ES")
  
  # List of occurrence in Balearic islands
  dat_ne <- occ_search(taxonKey = key, hasCoordinate = T, 
                       geometry = balearic, limit = 199999)
  nOccBal <- dat_ne$meta$count
  dat_ne <- dat_ne$data
  
  fossil <- ifelse(isTRUE(unique(dat_ne$basisOfRecord) == "FOSSIL_SPECIMEN"), "FOSSIL", "PRESENT")
  
  # We consider the species present if the number of occurrence is >= 5
  info <- data.frame(originalSpecies = sp.gen[i],
                     acceptedName = acceptedName.check$data$scientificName, #unique(dat_ne$acceptedScientificName),
                     tax_key = key,
                     status = tax_key$status,
                     nOcc.ES = nOcc,
                     nOcc.BAL = nOccBal,
                     fossil = fossil,
                     presenceAbsence = ifelse(nOccBal >= 5, "present", "absent"))
  
  
  # info$presenceAbsence <- ifelse(info$nOcc.BAL >= 5, "present", "absent") 
  
  genus.gbif <- rbind(genus.gbif, info)
  
  # sp.gbif$data <- rbind(sp.gbif$data, dat_ne)
  
  print(paste(i, "--- of ---", length(sp.gen)))
} 
rm(tax_key, key, nOcc, dat_ne, info, i, acceptedName.check, nOccBal, fossil)


# Remove fossil record from info and data files
genus.gbif <- genus.gbif[genus.gbif$fossil != "FOSSIL_SPECIMEN", ]

# Remove records do not present in Spain
genus.gbif <- genus.gbif[genus.gbif$nOcc.ES != 0, ]

#genus.gbif <- genus.gbif[!duplicated(genus.gbif), ]

genus.gbif$source <- "Genus derived"

# Merge gbif species list and list created starting from the genus.
gbifInfo <- merge(sp.gbif, genus.gbif, by = "acceptedName", all = TRUE)

# Save .csv
dir.create(paste0("./Lists/06_gbif/", grName))
write.csv(gbifInfo, paste0("./Lists/06_gbif/", grName, "/", grName, "_gbifInfo_", Sys.Date(),".csv"), row.names = F) # , fileEncoding = "macroman"

