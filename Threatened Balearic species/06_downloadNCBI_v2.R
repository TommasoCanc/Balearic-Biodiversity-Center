######################################
# Title: NCBI download data          #
# Author: Tommaso Cancellario        #
# Reviewer: Laura Triginer           #
# Creation: 2023 - 04 - 26           #
# Last update: 2023 - 04 - 26        #
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

# Create folder to store downloaded txt files for each species
dir.create("./results/originalNamesTxt_1/")

# Remove all file into the directory. This directory has to be clean at the beginning.
unlink(list.files("./results/originalNamesTxt", full.names = TRUE)) 

# Download row data fram NCBI original species names 
for(j in 1:length(spOriginal)) {
  
  print(paste("----", spOriginal[j], ";", j, "of", length(spOriginal), "----"))
  
  # Term to search
  term <- paste0(spOriginal[j], "[ORGN]")
  
  # Search in Nucleotide database with the terms above.
  a <- entrez_search(db = dataBase, term = term, use_history = T)
  
  if(length(a$ids) != 0){
  
    # Download chunk of 1000 records
    for(seq_start in seq(0, a$count, 1000)){
      Sys.sleep(1) # Time in seconds
      recs <- entrez_fetch(db = "nuccore", web_history = a$web_history,
                           rettype = "gbwithparts", retmode = "text", 
                           retmax = 1000, retstart = seq_start)
      cat(recs, file = paste0("./results/originalNamesTxt/", j, "_",spOriginal[j], ".txt"), append=TRUE)
      print(seq_start)
    }
    
  } else {
    # If the taxa it is not present in NCBI we procuce a file with "No data" string
    cat("No data\n", file = paste0("./results/originalNamesTxt/", j, "_",spOriginal[j], ".txt"))
    
  }
  
}

# Create a dataframe to contain NCBI info and fasta
ncbiInfo <- data.frame()
nucleotideFasta <- data.frame()

# Load TXT in r
sp.files <- list.files("./results/originalNamesTxt", full.names = TRUE)
numbers <-  as.numeric(regmatches(sp.files, regexpr("[0-9]+", sp.files)))
sp.files <- sp.files[order(numbers)]
sp.files

#length(sp.files)
for(i in 17:18){
  
  print(paste("----", i, "of", length(sp.files), "----"))
  rowNcbi <- paste(readLines(sp.files[i]), collapse="\n")
  
  if(rowNcbi != "No data"){
    
    ncbi.2 <- as.data.frame(matrix(NA, ncol=13))
    colnames(ncbi.2) <- c("sampleid", "species_name","country",
                          "lat", "lon", "markercode", "nucleotides_bp",
                          "definition", "voucher", "pubmed", "collection_date",
                          "INV", "authors")
    
    recs.ls <- as.list(unlist(strsplit(rowNcbi, '//\n\n')))
    
    for(j in 1:length(recs.ls)){
      print(paste("----", j, "of", length(recs.ls), "----"))
      gbank <- recs.ls[[j]]
      
      # ACCESSION NUMBER
      # ncbi.2$sampleid <- gsub("\"","",gsub("^.*ACCESSION\\s*|\\s*\n.*$", "", gbank))
      ncbi.2$sampleid <- word(gsub("\"", "", gsub("^.*ACCESSION\\s*|\\s*\n.*$", "", gbank)), 1)
      
      # TAXONOMY
      taxonomy <- unlist(strsplit(taxonomy <- gsub("\"", "", gsub("^.*ORGANISM\\s*|\\s*.\nREFERENCE.*$", "", gbank)), "\n"))
      ncbi.2$species_name <- taxonomy[1]
      
      # COUNTRY
      ncbi.2$country <- as.character(ifelse(grepl("country", gbank) == T,
                                            gsub("\"", "", gsub("^.*country=\\s*|\\s*\n.*$", "", gbank)), NA))
      
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
                                  gsub("\"", "", gsub("^.*product=\\s*|\\s*\n.*$", "", gbank)), NA)
      
      # SEQUENCE
      seq <- as.character(ifelse(grepl("ORIGIN", gbank) == T,
                                 gsub("\n", "", gsub("^.*ORIGIN\\s*|\\//.*$", "", gbank)), NA))
      # ncbi.2$nucleotides <- gsub(" ", "", gsub("[[:digit:]]+", "", seq))
      nucleotides <- gsub(" ", "", gsub("[[:digit:]]+", "", seq))
      ncbi.2$nucleotides_bp <- nchar(nucleotides)
      
      nucleotideFasta.1 <- data.frame(seqName =  ncbi.2$sampleid,
                                      seqTaxa = taxonomy[1],
                                      seqBP = nchar(nucleotides),
                                      nucleotides = nucleotides)
      
      # VOUCHER
      ncbi.2$voucher <- ifelse(grepl("specimen_voucher=", gbank) == T, 
                               as.character(gsub("\"", "", gsub("^.*specimen_voucher=\\s*|\\s*\n.*$", "", gbank))), NA)
      
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
      
    }
    
  } else {
    
    ncbi.2 <- as.data.frame(matrix(NA, ncol=13))
    colnames(ncbi.2) <- c("sampleid", "species_name","country",
                          "lat", "lon", "markercode", "nucleotides_bp",
                          "definition", "voucher", "pubmed", "collection_date",
                          "INV", "authors")
    
    ncbi.2[1, ] <- "No data"
    ncbi.2$species_name <- gsub(".*[_]([^.]+)[.].*", "\\1", sp.files[i])
    
    
    # Create total dataset   
    ncbiInfo <- rbind(ncbiInfo, ncbi.2)
    
  }
  
}

rm(ncbi.2, i, lat, lon, lat_lon, seq, taxonomy, nucleotideFasta.1, nucleotides, 
   gbank, term, a, j, def)

# Save ncbi info and fasta file
dir.create("./results/originalNamesCSV/")
dir.create("./results/originalNamesFASTA/")
write.csv(ncbiInfo, paste0("./results/originalNamesCSV/originalNames_1_20_",Sys.Date(),".csv"), row.names = FALSE)
writeFasta(data = nucleotideFasta, filename = paste0("./results/originalNamesFASTA/originalNames_17_18",Sys.Date(),".fasta"))

rm(list = ls())
