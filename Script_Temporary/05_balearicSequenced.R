######################################
# Title: Balearic sequences          #
# Author: Tommaso Cancellario        #
# Reviewer: Laura Triginer           #
# Creation: 2023 - 05 - 10           #
# Last update: 2023 - 05 - 10        #
######################################


# Libraries
library(dplyr)

# Set WD
setwd("~/OneDrive - Universitat de les Illes Balears/Biodiversidad Baleares/threatened_Balearic_species/")

# Load csv
ls <- list.files("./results/originalNamesCSV", full.names = TRUE)
numbers <-  as.numeric(regmatches(ls, regexpr("[0-9]+", ls)))
ls <- ls[order(numbers)]
ls[1:11]
rm(numbers)

# String 
my_pattern <- paste0("Balearic", "|", 
                     "Balears", "|", 
                     "Baleares", "|", 
                     "Minorca", "|", 
                     "Mallorca", "|",
                     "Majorca", "|",
                     "Maiorca", "|",
                     "Mayorca", "|",
                     "Menorca", "|",
                     "Cabrera", "|",
                     "Dragonera", "|",
                     "Ibiza", "|",
                     "Eivissa", "|",
                     "Formentera")

df <-  data.frame()
# i=143
for(i in 1:length(ls)){
  
  sp <- read.csv(ls[i])
  
  sp.1 <- sp[grep(my_pattern, sp$country), ]
  df.1 <- data.frame(taxa = gsub("[0-9_-]+", "", gsub("^\\d+_|\\.csv$", "", basename(ls[i]))),
                     balearicSequenced = ifelse(nrow(sp.1) != 0, "YES", "NO"))
  
  df <- rbind(df, df.1)
  
  print(paste(i, "of", length(ls)))
}

write.csv2(df, "./balearic sequenced.csv")

sort(unique(sp$country))
