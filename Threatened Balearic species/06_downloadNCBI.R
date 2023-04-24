######################################
# Title: NCBI download data          #
# Author: Tommaso Cancellario        #
# Reviewer:                          #
# Creation: 2023 - 03 - 10           #
# Last update: 2023 - 03 - 13        #
######################################

# More info about rentrez package:
# https://cran.r-project.org/web/packages/rentrez/vignettes/rentrez_tutorial.html

# Load libraries
library(rentrez)
library(stringr)
library(seqinr)

# Set WD
setwd("/Users/tcanc/Library/CloudStorage/OneDrive-UniversitatdelesIllesBalears/Biodiversidad Baleares/threatened_Balearic_species/")

# Functions
source("/Users/tcanc/Desktop/GitHub/Balearic-Biodiversity-Center/Functions/writeFasta.R")

# Load sheet
# getSheetNames("./tmp/threatenedSpecies_2023-04-24.xlsx")
sp <- readxl::read_excel("./tmp/threatenedSpecies_2023-04-24.xlsx", 
                           sheet = "02_downloadSynonyms")
head(sp)

# Original name
spOriginal <- unique(sp$originalName)

# Synonyms name
spSynonyms <- unique(sp$synonym)

# NCBI database search
dataBase <- "nuccore"

# Term to search
# term <- "Helosciadium bermejoi[ORGN]"

# Metadata info catch
ncbiInfo <- data.frame()
nucleotideFasta <- data.frame()

length(spOriginal)
for(j in 1:3) {
  
  print(paste("----", spOriginal[j], ";", j, "of", length(spOriginal), "----"))
  
  # Term to search
  term <- paste0(spOriginal[j], "[ORGN]")
  
  # Search in Nucleotide database with the terms above.
  a <- entrez_search(db = dataBase, term = term, use_history = T)
  # We need to set the maximum number of results equalt to the number of hits
  a <- entrez_search(db = dataBase, term = term, retmax = a$count, use_history = T)
  
  if(isTRUE(length(a$ids) != 0)) {
    
    for(i in 1:length(a$ids)){
      
      ncbi.2 <- as.data.frame(matrix(NA, ncol=13))
      colnames(ncbi.2) <- c("sampleid", "species_name","country",
                            "lat", "lon", "markercode", "nucleotides_bp",
                            "definition", "voucher", "pubmed", "collection_date",
                            "INV", "authors")
      
      # The IDs are the most important thing returned here. They allow us to fetch records 
      # matching those IDs, gather summary data about them or find cross-referenced records 
      # in other databases. 
      gbank <- entrez_fetch(db = "nuccore", id = a$ids[i], rettype = "gbwithparts", retmode = "text")
      
      # ACCESSION NUMBER
      # ncbi.2$sampleid <- gsub("\"","",gsub("^.*ACCESSION\\s*|\\s*\n.*$", "", gbank))
      ncbi.2$sampleid <- word(gsub("\"","",gsub("^.*ACCESSION\\s*|\\s*\n.*$", "", gbank)), 1)
      
      # TAXONOMY
      taxonomy <- unlist(strsplit(taxonomy <- gsub("\"", "", gsub("^.*ORGANISM\\s*|\\s*.\nREFERENCE.*$", "", gbank)), "\n"))
      ncbi.2$species_name <- taxonomy[1]
      
      # COUNTRY
      ncbi.2$country <- as.character(ifelse(grepl("country", gbank) == T,
                                            gsub("\"","",gsub("^.*country=\\s*|\\s*\n.*$", "", gbank)), NA))
      
      # LONGITUDE & LATITUDE
      if(isTRUE(grepl("lat_lon", gbank))) {
        
        lat_lon <- gsub("\"","",gsub("^.*lat_lon=\\s*|\\s*\n.*$", "", gbank))
        lon <- as.numeric(word(lat_lon,-2))
        ncbi.2$lon <- ifelse(word(lat_lon,-1) == "W", -abs(lon), lon)
        lat <- as.numeric(gsub("\"", "", as.character(word(lat_lon,1))))
        ncbi.2$lat <- ifelse(word(lat_lon,2) == "S", -abs(lat), lat)
        
      } else {
        
        ncbi.2$lon <- NA
        ncbi.2$lat <- NA
        
      }
      
      # MARKER CODE
      ncbi.2$markercode <- ifelse(grepl("product=", gbank) == T,
                                  gsub("\"","",gsub("^.*product=\\s*|\\s*\n.*$", "", gbank)), NA)
      
      # SEQUENCE
      seq <- gsub("\n", "", gsub("^.*ORIGIN\\s*|\\//.*$", "", gbank))
      # ncbi.2$nucleotides <- gsub(" ", "", gsub("[[:digit:]]+", "", seq))
      nucleotides <- gsub(" ", "", gsub("[[:digit:]]+", "", seq))
      nucleotideFasta.1 <- data.frame(seqName =  ncbi.2$sampleid, 
                                      nucleotides = nucleotides)
      ncbi.2$nucleotides_bp <- nchar(as.character(ncbi.2$nucleotides[1]))
      
      # VOUCHER
      ncbi.2$voucher <- ifelse(grepl("specimen_voucher=", gbank) == T, 
                               as.character(gsub("\"","",gsub("^.*specimen_voucher=\\s*|\\s*\n.*$", "", gbank))), NA)
      
      # DEFINITION
      def <- str_replace_all(gsub("^.*DEFINITION\\s*|\\s*.\nACCESSION.*$", "", gbank), "[\r\n]" , "")
      ncbi.2$definition <- gsub("\\s+", " ", str_trim(def))
      
      # PUBMED
      ncbi.2$pubmed <- ifelse(grepl("PUBMED", gbank) == T, 
                              as.character(gsub("\"", "", gsub("^.*PUBMED\\s*|\\s*\n.*$", "", gbank))), NA)
      
      # Collection date
      ncbi.2$collection_date <- ifelse(grepl("collection_date", gbank) == T, 
                                       as.character(gsub("\"", "", gsub("^.*collection_date=\\s*|\\s*\n.*$", "", gbank))), NA)
      
      # INV
      ncbi.2$INV <- ifelse(grepl("INV", gbank) == T, 
                           as.character(gsub("\"", "", gsub("^.*INV\\s*|\\s*\n.*$", "", gbank))), NA)
      
      # AUTHORS
      ncbi.2$authors <- ifelse(grepl("AUTHORS", gbank) == T, 
                               as.character(gsub("\"", "", gsub("^.*AUTHORS\\s*|\\s*\n.*$", "", gbank))), NA)
      
      # Create total dataset   
      ncbiInfo <- rbind(ncbiInfo, ncbi.2)
      nucleotideFasta <- rbind(nucleotideFasta, nucleotideFasta.1)
      
      print(paste0(i, "---- of ----", length(a$ids), "(", round((i/length(a$ids))*100, digits = 2),"%)"))  
    }
    
  } else {
    
    ncbi.2 <- as.data.frame(matrix(NA, ncol=13))
    colnames(ncbi.2) <- c("sampleid", "species_name","country",
                          "lat", "lon", "markercode", "nucleotides_bp",
                          "definition", "voucher", "pubmed", "collection_date",
                          "INV", "authors")
    
    ncbi.2[1, ] <- "No data"
    ncbi.2$species_name <- spOriginal[j]
    
    # Create total dataset   
    ncbiInfo <- rbind(ncbiInfo, ncbi.2)
    
  }
  
}

rm(ncbi.2, i, lat, lon, lat_lon, seq, taxonomy, nucleotideFasta.1, nucleotides, 
   gbank, term, a, j, def)


# Save ncbi info and fasta file
write.csv(ncbiInfo, paste0("~/Desktop/ncbiInfo_1_20_",Sys.Date(),".csv"), row.names = FALSE)
writeFasta(data = nucleotideFasta, filename = paste0("~/Desktop/ncbiFasta_1_20_",Sys.Date(),".fasta"))





rm(list = ls())