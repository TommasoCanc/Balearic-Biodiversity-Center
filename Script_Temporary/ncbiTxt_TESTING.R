#' @name ncbiTxt
#'
#' @title Function to convert data frame to fasta file. 
#'
#' @description
#' This function is useful to download the GenBank .txt file.
#'
#' @param data character vector containing species names.
#' @param ncbi_search NCBI search string (default "[ORGN]").
#' @param ncbi_db NCBI databese for searching (default "nuccore").
#' @param ncbi_chunk Chunk of sequence to download (default 10).
#' @param dir_name path of the directory to save .txt files.
#' 
#' @details 
#'
#' @keywords data frame
#' @keywords fasta file
#'
#' @examples
#' Taxa with data in NCBI.
#' x <- ncbiTxt(data = c("Agrostis barceloi", "Helosciadium bermejoi"), 
#' ncbi_search = "[ORGN]", ncbi_db = "nuccore", ncbi_chunk = 10, 
#' dir_name = "~/Desktop/prova/")

ncbiTxt <- function(data = NULL, ncbi_search = "[ORGN]", 
                    ncbi_db = "nuccore", ncbi_chunk = 10, 
                    dir_name = NULL) {

  # Load (or install) rentrez package
  if (!require("rentrez"))
    install.packages("rentrez")
  require("rentrez")
  
  if(!is.null(dir_name)){
    
    # Create directory to save txt files
    dir.create(dir_name)  
    
    for(j in 1:length(data)) {
      
      print(paste("----", data[j], ";", j, "of", length(data), "----"))
      
      # Term to search
      term <- paste0(data[j], ncbi_search)
      
      # Search in Nucleotide database with the terms above.
      a <- entrez_search(db = ncbi_db, term = paste0(data[j], ncbi_search), use_history = T)
      
      if(length(a$ids) != 0){
        
        # Download chunk of ncbi_chunk records
        for(seq_start in seq(0, a$count, ncbi_chunk)){
          Sys.sleep(1) # Time in seconds
          recs <- entrez_fetch(db = "nuccore", web_history = a$web_history,
                               rettype = "gbwithparts", retmode = "text", 
                               retmax = ncbi_chunk, retstart = seq_start)
          
          cat(recs, file = paste0(dir_name, j, "_", data[j], ".txt"), append=TRUE)
          
          print(seq_start)
        }
        
      } else {
        # If the taxa it is not present in NCBI we procuce a file with "No data" string
        cat("No data\n", file = paste0(dir_name, j, "_", data[j], ".txt"))
        
      }
      
    }
    
    
  } else {
    
    message("Please choose the directory name.")
    
  }
  
}