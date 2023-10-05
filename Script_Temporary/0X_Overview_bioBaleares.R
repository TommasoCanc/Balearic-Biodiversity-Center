################################################################################
# Title: Biodiversidad Baleares                                                #
# Author: Tommaso Cancellario                                                  #
# Reviewer:                                                                    #
# Creation: 2023 - 02 - 13                                                     #
# Last update: 2023 - 00 - 00                                                  #
################################################################################

# Set WD
setwd("/media/tcanc/PHILIPS UFD/UIB/Biodiversity_Baleares/")

# Load library
library(data.table)
library(dplyr)
library(ggplot2)

# Load data
# https://www.gbif.org/occurrence/download/0282414-220831081235567
occ <- fread("./0282414-220831081235567/occurrence.txt") # 2,289,664 with coordinates (GBIF) - 2289664
head(occ)

# Filter data
occFiltered <- occ %>% 
  select(publisher, institutionCode, datasetName, basisOfRecord, associatedReferences, 
         stateProvince, county, municipality, locality, decimalLatitude, decimalLongitude, 
         scientificName, kingdom, phylum, class, order, family, subfamily, genus, subgenus, 
         infragenericEpithet, specificEpithet, infraspecificEpithet, taxonRank, taxonomicStatus,
         acceptedScientificName)
head(occFiltered)

# Save .csv
write.csv(occFiltered, "occurrenceBalearicFiltered_20230213.csv", row.names = FALSE)

rm(occ); gc()

# How many fossil speciments we have in our DS?
occFossil <- occFiltered[occFiltered$basisOfRecord == "FOSSIL_SPECIMEN", ]
nrow(occFossil); unique(occFossil$basisOfRecord)

unique(occFossil$scientificName)
unique(occFossil$acceptedScientificName)

occFossil %>% distinct(scientificName, taxonomicStatus, acceptedScientificName)

unique(occFossil$taxonRank)


# NOT FOSSIL
occPres <- occFiltered[occFiltered$basisOfRecord != "FOSSIL_SPECIMEN", ]
nrow(occPres); unique(occPres$basisOfRecord)

unique(occPres$scientificName)
unique(occPres$acceptedScientificName)

occPres %>% distinct(scientificName, taxonomicStatus, acceptedScientificName)

# Number of total occurrences ----
table(occPres$kingdom)
ggplot(data.frame(occPres), aes(x = kingdom)) +
  geom_bar() + 
  labs(title = "Occurrences per Kingdom", x = "Kingdom", y = "N. of Occurrences") +
  theme_minimal()

# Animalia ----
occPres.animalia <- occPres[occPres$kingdom == "Animalia", ]
head(occPres.animalia)

occPres.animalia.order <- data.frame(table(occPres.animalia$order))
occPres.animalia.order.10 <- occPres.animalia.order[order(occPres.animalia.order$Freq, decreasing = TRUE), ][1:10, ]
# occPres.animalia.order.20 <- occPres.animalia.order[order(occPres.animalia.order$Freq, decreasing = TRUE), ][1:20, ]
# occPres.animalia.order.30 <- occPres.animalia.order[order(occPres.animalia.order$Freq, decreasing = TRUE), ][1:30, ]

ggplot(data = occPres.animalia.order.10, aes(x = Freq, y = reorder(Var1, Freq))) +
  geom_bar(stat="identity") +
  labs(title = "Animalia records", x = "Order", y = "N. of Occurrences") +
  theme_minimal()







# UIB group 
sort(unique(occPres.animalia$institutionCode))
occPres.animalia.uib <- occPres.animalia[occPres.animalia$institutionCode == "UIB", ]
which(is.na(occPres.animalia.uib$decimalLatitude))

# Carnivora
nrow(occPres.animalia.uib[occPres.animalia.uib$order == "Carnivora", ])

nrow(occPres.animalia.uib[occPres.animalia.uib$phylum == "Chordata", ])
nrow(occPres.animalia.uib[occPres.animalia.uib$phylum == "Arthropoda", ])

nrow(occPres.animalia.uib[occPres.animalia.uib$genus == "Testudo", ])

# RJB group
occPres.animalia.rjb <- occPres.animalia[occPres.animalia$institutionCode == "", ] 

