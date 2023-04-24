#' @name writeFasta
#'
#' @title Function to convert data frame to fasta file. 
#'
#' @description
#' This function is useful to condert n data.frame object to fasta file.
#'
#' @param data dataset name to download. 
#' @param filename dataset name to download. 
#' 
#' @details 
#'
#' @keywords data frame
#' @keywords fasta file

#' @examples
#' dbReference <- writeFasta()


writeFasta <- function(data, filename){
  fastaLines = c()
  for (rowNum in 1:nrow(data)){
    fastaLines = c(fastaLines, paste0(">", data[rowNum, "seqName"], ";", 
                                      data[rowNum, "seqTaxa"], ";",
                                      data[rowNum, "seqBP"]))
    fastaLines = c(fastaLines, data[rowNum, "nucleotides"])
  }
  fileConn <- file(filename)
  writeLines(fastaLines, fileConn)
  close(fileConn)
}