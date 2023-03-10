#https://cran.r-project.org/web/packages/rentrez/vignettes/rentrez_tutorial.html

# Libraries
library(rentrez)
library(stringr)

dataBase <- "nuccore"
term <- "((((Balearic[All Fields] OR Baleares[All Fields]) OR Mallorca[All Fields]) OR Menorca[All Fields]) OR Ibiza[All Fields]) OR Formentera[All Fields]"

# Searc in Nucleotide database with the terms above.
a <- entrez_search(db = dataBase, term = term, use_history = T) # <- 144760 hits
# We need to set the maximum number of results equalt to the number of hits
a <- entrez_search(db = dataBase, term = term, retmax = a$count, use_history = T)

# Metadata info catch

# The IDs are the most important thing returned here. They allow us to fetch records 
# matching those IDs, gather summary data about them or find cross-referenced records 
# in other databases. 

gbank <- entrez_fetch(db = "nuccore", id = a$ids[1], rettype = "gbwithparts", retmode = "text")


ncbi.2 <- as.data.frame(matrix(NA, ncol=13))
colnames(ncbi.2) <- c("sampleid", "species_name","country",
                      "lat", "lon", "markercode", "nucleotides", "nucleotides_bp",
                      "definition", "voucher", "pubmed", "collection_date",
                      "INV")

gbank <- entrez_fetch(db="nucleotide", id=a$ids[1], rettype="gbwithparts", retmode = "text")

ncbi.2$sampleid[1] <- gsub("\"","",gsub("^.*ACCESSION\\s*|\\s*\n.*$", "", gbank))
taxonomy <- gsub("\"", "", gsub("^.*ORGANISM\\s*|\\s*.\nREFERENCE.*$", "", gbank))
taxonomy <- unlist(strsplit(taxonomy, "\n"))
ncbi.2$species_name[1] <- taxonomy[1]

# COUNTRY
ncbi.2$country <- as.character(ifelse(grepl("country", gbank) == T,
                                      gsub("\"","",gsub("^.*country=\\s*|\\s*\n.*$", "", gbank)), NA))


# LONGITUDE & LATITUDE
if(isTRUE(grepl("lat_lon", gbank))) {
  
  lat_lon <- gsub("\"","",gsub("^.*lat_lon=\\s*|\\s*\n.*$", "", gbank))

  # lat_lon <- ifelse(grepl("lat_lon", gbank) == T, 
  #                   gsub("\"","",gsub("^.*lat_lon=\\s*|\\s*\n.*$", "", gbank)), NA)
  
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

# SEUENCE
seq <- gsub("\n", "", gsub("^.*ORIGIN\\s*|\\//.*$", "", gbank))
ncbi.2$nucleotides[1] <- gsub(" ", "", gsub("[[:digit:]]+", "", seq))
ncbi.2$nucleotides_bp[1] <- nchar(as.character(ncbi.2$nucleotides[1]))

# VOUCHER
ncbi.2$voucher[1] <- ifelse(grepl("specimen_voucher=", gbank) == T, 
                            as.character(gsub("\"","",gsub("^.*specimen_voucher=\\s*|\\s*\n.*$", "", gbank))), NA)

# DEFINITION
ncbi.2$definition[1] <- gsub("\"", "", gsub("^.*DEFINITION\\s*|\\s*.\n.*$", "", gbank))

# PUBMED
ncbi.2$pubmed[1] <- ifelse(grepl("PUBMED", gbank) == T, 
                           as.character(gsub("\"", "", gsub("^.*PUBMED\\s*|\\s*\n.*$", "", gbank))), NA)

# Collection date
ncbi.2$collection_date[1] <- ifelse(grepl("collection_date", gbank) == T, 
                                    as.character(gsub("\"", "", gsub("^.*collection_date=\\s*|\\s*\n.*$", "", gbank))), NA)

# INV
ncbi.2$INV[1] <- ifelse(grepl("INV", gbank) == T, 
                        as.character(gsub("\"", "", gsub("^.*INV\\s*|\\s*\n.*$", "", gbank))), NA)

