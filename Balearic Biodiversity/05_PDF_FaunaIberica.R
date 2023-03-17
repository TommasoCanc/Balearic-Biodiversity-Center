######################################
# Title: Extract from Fauna Iderica  #
# Author: Tommaso Cancellario        #
# Reviewer:                          #
# Creation: 2023 - 03 - 16           #
# Last update: 2023 - 03 - 16        #
######################################

# http://www.faunaiberica.es/publicaciones/dfi

# Load libraries
library(pdftools)
library(stringr)
library(rlang)

# Load PDF
text <- pdf_text("/Users/tcanc/Library/CloudStorage/OneDrive-UniversitatdelesIllesBalears/Biodiversidad Baleares/Tom/Fauna Iberica/Collembola_2021.pdf")
# From pag. 5 to pag.39
text[5]

stringBalearic <- c()
for(j in 5:39){
  
  # Split text
  text2 <- strsplit(text[j], "\n")
  
  for(i in 1:length(text2[[1]])){
    
    stringIB <- str_subset(str_trim(text2[[1]][i]), "IB")  
    
    if(!is_empty(stringIB)){
      stringBalearic <- c(stringBalearic, stringIB)
    }
    
  }  
  
}

stringBalearic.1 <- strsplit(stringBalearic, "\\[")


stringBalearic.2 <- data.frame()
for(i in 1:length(stringBalearic.1)){
  
  stringBalearic.3 <- data.frame(taxa = stringBalearic.1[[i]][1],
                                 distribution = gsub("\\]", "",stringBalearic.1[[i]][2])
  )  
  
  stringBalearic.2 <- rbind(stringBalearic.2, stringBalearic.3)
  
}

