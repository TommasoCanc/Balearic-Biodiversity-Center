# READ NCBI txt

# Functions
source("/Users/tcanc/Desktop/GitHub/Balearic-Biodiversity-Center/Functions/writeFasta.R")


# Load TXT in r
sp.files <- list.files("./results/originalNamesTxt", full.names = TRUE)
numbers <-  as.numeric(regmatches(sp.files, regexpr("[0-9]+", sp.files)))
sp.files <- sp.files[order(numbers)]
sp.files


# Create a dataframe to contain NCBI info and fasta
ncbiInfo <- data.frame()
nucleotideFasta <- data.frame()

#length(sp.files)
for(i in 1:2){
  
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

  # Save csv file  
  write.csv(ncbiInfo, paste0("./results/originalNamesCSV/", # Change directory  
                             i, "_", gsub(".*[_]([^.]+)[.].*", "\\1", sp.files[i]), "_", 
                             Sys.Date(),".csv"), 
            row.names = FALSE)
  
  # Save fasta file
  writeFasta(data = nucleotideFasta, 
             filename = paste0("./results/originalNamesFASTA/", # Change directory  
                               i, "_", gsub(".*[_]([^.]+)[.].*", "\\1", sp.files[i]), "_", 
                               Sys.Date(),".fasta"))
  

    
}

rm(ncbi.2, i, lat, lon, lat_lon, seq, taxonomy, nucleotideFasta.1, nucleotides, 
   gbank, term, a, j, def)
