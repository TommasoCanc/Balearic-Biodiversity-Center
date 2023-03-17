######################################
# Title: FAUNA EUROPEA download data #
# Author: Tommaso Cancellario        #
# Reviewer:                          #
# Creation: 2023 - 02 - 21           #
# Last update: 2023 - 03 - 15        #
######################################

# Load libraries
library(dplyr)
library(purrr)
library(rvest)
library(stringr)

# Function
"%ni%" <- Negate("%in%")

# Set WD
# setwd("/home/tcanc/OneDrive/Biodiversidad Baleares/Tom/")
setwd("/Users/tcanc/Library/CloudStorage/OneDrive-UniversitatdelesIllesBalears/Biodiversidad Baleares/Tom/")

# Load species list
species.list <- read.csv("./Lists/originalList/Reptilia_2023_03_17.csv", sep = ";")
head(species.list)

# Filter genus and species columns
sp <- as.character(species.list$Taxon)

# Extract genus
gen <- unique(word(sp, 1))

########################
# Species distribution #
########################

# We download the Fauna Europaea information about species distribution
taxa.distribution <- data.frame()

for(i in 1:length(sp)) {
sp.sub <-gsub(" ", "+", sp[i])

# Link with species name
simple <- read_html(paste0("https://fauna-eu.org/cdm_dataportal/search/results/taxon?ws=portal%2Ftaxon%2Ffind&query=", sp.sub,"&form_build_id=form-yCUOMbyaOrUypUfzCmfYy_S4qRO0OaqCMcOThvnkGJY&form_id=cdm_dataportal_search_taxon_form&search%5BdoTaxaByCommonNames%5D=&search%5BdoSynonyms%5D=&search%5BdoTaxa%5D=1&search%5BpageSize%5D=25&search%5BpageNumber%5D=0"))
body <- html_nodes(simple, "body")
div <- html_nodes(body, "div")
span <- html_nodes(div, "span")

span.code <- span[1]
span.code.ch <- as.character(span.code)
res <- str_match(span.code.ch, "uuid:\\s*(.*?)\\s*sec_uuid")
res <- res[ ,2]

tryCatch(taxa <- read_html(paste0("https://fauna-eu.org/cdm_dataportal/taxon/", res), options = "HUGE"), error=function(e){})

if (isTRUE(exists("taxa"))) {
body.taxa <- html_nodes(taxa, "body")

# Taxonomic information
taxonName <- html_nodes(body.taxa, ".TaxonName")[1]  %>% 
  html_text() %>% 
  str_trim()
author <- html_nodes(body.taxa, ".authors")[1] %>% 
  html_text() %>% 
  str_trim()

# Table about presence/absence data
table <- html_nodes(body.taxa, "table") %>% 
html_table()

distribution <- table[[1]]

if("Region" %in% colnames(distribution)){
  distribution <- distribution[distribution$Region == "Balearic Is.", ]
} else {
  distribution <- data.frame(Region = NA,
                             Status = NA)
}

if(nrow(distribution) != 0){
  
  taxa.distribution.1 <- data.frame(taxa.original = sp[i],
                                    taxa.fauna.eu = paste(taxonName, author),
                                    Region = distribution[,1],
                                    Status = distribution[,2])
} else {
  
  taxa.distribution.1 <- data.frame(taxa.original = sp[i],
                                    taxa.fauna.eu = paste(taxonName, author),
                                    Region = NA,
                                    Status = NA)
}

rm(taxa)
} else {taxa.distribution.1 <- data.frame(taxa.original = sp[i],
                                         taxa.fauna.eu = NA,
                                         Region = NA,
                                         Status = NA)}
               
taxa.distribution <- rbind(taxa.distribution, taxa.distribution.1)
print(paste(i, "--- of ---", length(sp)))

}
rm(res, sp.sub, taxa.distribution.1, taxonName, author, body, body.taxa, distribution, 
   div, simple, span, span.code, table, i, span.code.ch)

taxa.distribution$source <- "Original list"

######################
# Genus distribution #
######################

# To check if the original list is complete, we search in Fauna Europaea all the 
# species belonging to a specific genus.

sp.gen <- data.frame()

for(i in 1:length(gen)) {
  
  # Genus list i element
  gen.sub <- gen[i]
  
  # This is the page with the first 25 (or less) scientific names.
  simple <- read_html(paste0("https://fauna-eu.org/cdm_dataportal/search/results/taxon?ws=portal%2Ftaxon%2Ffind&query=", gen.sub,"&form_build_id=form-yCUOMbyaOrUypUfzCmfYy_S4qRO0OaqCMcOThvnkGJY&form_id=cdm_dataportal_search_taxon_form&search%5BdoTaxaByCommonNames%5D=&search%5BdoSynonyms%5D=&search%5BdoTaxa%5D=1&search%5BpageSize%5D=25&search%5BpageNumber%5D=0"))
  body <- html_nodes(simple, "body") 
  gen.ls <- html_nodes(body, ".Taxon") 
  nPages <- html_nodes(body, ".active")  %>% 
    html_attr("href") %>% 
    unique()
  
  if(length(gen.ls) != 0) {
    
    sp.gen.1 <- data.frame()
    
    gen.taxonName <- html_nodes(gen.ls, ".TaxonName")  %>% 
      html_text() %>% 
      str_trim() %>% 
      data.frame() %>% 
      slice(-1)  
    
    sp.gen.1 <- rbind(sp.gen.1, gen.taxonName)
    colnames(sp.gen.1) <- "Taxa"
    
  } else {
    sp.gen.1 <- data.frame(Taxa = paste(gen[i], "sp."))
  }
  
  if(length(nPages) != 0 & length(gen.ls) != 0){
    
    for(j in 1:length(nPages)){
      
      # If the genus count more than 25 scientific names we need to scrape also the other pages.
      simple.1 <- read_html(paste0("https://fauna-eu.org", nPages[j]))
      body.1 <- html_nodes(simple.1, "body") 
      gen.ls.1 <- html_nodes(body.1, ".Taxon")
      
      gen.taxonName.1 <- html_nodes(gen.ls.1, ".TaxonName")  %>% 
        html_text() %>% 
        str_trim() %>% 
        data.frame()
      
      colnames(gen.taxonName.1) <- "Taxa"
      sp.gen.1 <- rbind(sp.gen.1, gen.taxonName.1)
    }
  }
  
  sp.gen <- rbind(sp.gen, sp.gen.1)
  print(paste(i, "--- of ---", length(gen)))
  
} 
rm(body, body.1, gen.ls, gen.ls.1, simple, simple.1, 
   sp.gen.1, gen.sub, gen.taxonName, gen.taxonName.1, i, j, nPages)

# Count number of words (we want only species level)
sp.gen$nWords <- str_count(sp.gen$Taxa, "\\w+")

# We need to remove all the taxa with sp.gen$nWord = 1
sp.ge.one <- sp.gen[sp.gen$nWords == 1, ]
if(nrow(sp.ge.one) != 0){
  sp.gen <- sp.gen[!grepl(paste(sp.ge.one$Taxa, collapse="|"), sp.gen$Taxa), ]
} else {
  sp.gen
}

# Check if we have different genus compared to the original list
unique(unique(word(sp.gen$Taxa, 1)) %in% gen) # It has to be TRUE

# Remove genus not present into the original list
gen.remove <- unique(word(sp.gen$Taxa, 1))[unique(word(sp.gen$Taxa, 1)) %ni% gen]
  if(length(gen.remove) != 0){
    sp.gen <- sp.gen[!grepl(paste(gen.remove, collapse="|"), sp.gen$Taxa), ]
  } else {
    sp.gen
  }
      
# Remove rows with just one word
# sp.gen <- sp.gen[sp.gen$nWords != 1, ]

# Download distribution information starting from the species derived form the genus
sp <- as.character(sp.gen$Taxa)
genus.distribution <- data.frame()

for(i in 1:length(sp)) {
  sp.sub <-gsub(" ", "+", sp[i])
  
  # Link with species name
  simple <- read_html(paste0("https://fauna-eu.org/cdm_dataportal/search/results/taxon?ws=portal%2Ftaxon%2Ffind&query=", sp.sub,"&form_build_id=form-yCUOMbyaOrUypUfzCmfYy_S4qRO0OaqCMcOThvnkGJY&form_id=cdm_dataportal_search_taxon_form&search%5BdoTaxaByCommonNames%5D=&search%5BdoSynonyms%5D=&search%5BdoTaxa%5D=1&search%5BpageSize%5D=25&search%5BpageNumber%5D=0"))
  body <- html_nodes(simple, "body")
  div <- html_nodes(body, "div")
  span <- html_nodes(div, "span")
  
  span.code <- span[1]
  span.code.ch <- as.character(span.code)
  res <- str_match(span.code.ch, "uuid:\\s*(.*?)\\s*sec_uuid")
  res <- res[ ,2]
  
  tryCatch(taxa <- read_html(paste0("https://fauna-eu.org/cdm_dataportal/taxon/", res), options = "HUGE"), error=function(e){})
  
  if (isTRUE(exists("taxa"))) {
    body.taxa <- html_nodes(taxa, "body")
    
    # Taxonomic information
    taxonName <- html_nodes(body.taxa, ".TaxonName")[1]  %>% 
      html_text() %>% 
      str_trim()
    author <- html_nodes(body.taxa, ".authors")[1] %>% 
      html_text() %>% 
      str_trim()
    
    # Table about presence/absence data
    table <- html_nodes(body.taxa, "table") %>% 
      html_table()
    
    distribution <- table[[1]]
    
    if("Region" %in% colnames(distribution)){
      distribution <- distribution[distribution$Region == "Balearic Is.", ]
    } else {
      distribution <- data.frame(Region = NA,
                                 Status = NA)
    }
    
    if(nrow(distribution) != 0){
      
      taxa.distribution.1 <- data.frame(taxa.original = sp[i],
                                        taxa.fauna.eu = paste(taxonName, author),
                                        Region = distribution[,1],
                                        Status = distribution[,2])
    } else {
      
      taxa.distribution.1 <- data.frame(taxa.original = sp[i],
                                        taxa.fauna.eu = paste(taxonName, author),
                                        Region = NA,
                                        Status = NA)
    }
    
    rm(taxa)
  } else {taxa.distribution.1 <- data.frame(taxa.original = sp[i],
                                            taxa.fauna.eu = NA,
                                            Region = NA,
                                            Status = NA)}
  
  genus.distribution <- rbind(genus.distribution, taxa.distribution.1)
  print(paste(i, "--- of ---", length(sp)))
  
}
rm(res, sp.sub, taxa.distribution.1, taxonName, author, body, body.taxa, distribution,
      div, simple, span, span.code, table, i, span.code.ch)

# Filter only the species with presence and presence/absence information.
genus.distribution.p <- genus.distribution[genus.distribution$Status == "present", ] %>%
  distinct() %>% 
  filter_all(any_vars(!is.na(.))) # Remove rows fill only with NA values

# We need to save also presence absence information to solve doubts (e.g. Aeshna affinis)
genus.distribution.pa <- genus.distribution[genus.distribution$Status == "present" |
                                            genus.distribution$Status == "absent" |
                                            genus.distribution$Status == "doubtfully present", ] %>%
  distinct() %>% 
  filter_all(any_vars(!is.na(.))) # Remove rows fill only with NA values

genus.distribution.p$source <- "Genus derived"

# Check difference between original list and genus temporary list
faunaEuropaea <- merge(taxa.distribution, genus.distribution.pa, by="taxa.fauna.eu", all = T) %>%
  distinct()

# Save .csv
write.csv2(faunaEuropaea, paste0("./Lists/faunaEuropaea/Reptilia_faunaEuropaea_", Sys.Date(),".csv"), row.names = F, fileEncoding = "macroman")
write.csv2(genus.distribution.pa, paste0("./Lists/faunaEuropaea/Reptilia_faunaEuropaea_pa_", Sys.Date(),".csv"), row.names = F, fileEncoding = "macroman")

rm(list = ls())
