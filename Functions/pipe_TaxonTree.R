#' Create a taxonomic entry for each taxonomic nomenclature of a taxonomic
#' data frame.
#'
#' @description
#'
#' Create a taxonomic entry for each taxonomic nomenclature of a taxonomic
#' data frame according to the CBB DB requirements.
#'
#' @param x dataframe of taxa.
#'
#' @keywords cbb_tree
#' @examples
#' df <- read.csv("./Template/Annelida.csv")
#' df <- df[ ,c("kingdom", "phylum", "order", "family", "genus", "species", "subspecies", "variety")]
#' cbb_tree(df)

cbb_tree <- function(x){
  
  # Check if the x object is a data frame. If not stop the function
  if (!is.data.frame(x)) {
    stop("Input is not a data frame.")
  }
  
  # Load or install pack if required
  if (!require("stringr")) install.packages("stringr")
  
  # Check if exist columns completely empty and remove
  empty_col <- sapply(x, function(col) any(is.na(col))) 
  rm_col <- which(empty_col == TRUE)
  x <- x[, -rm_col]
  
  paste("The column/s", names(rm_col), "had be removed")
  
  # Upper case to first letter
  colnames(x) <- str_to_title(colnames(x)) 
  
  taxa.col <- c(colnames(x), "Taxa")
  
  empty.df <- as.data.frame(matrix(ncol = length(taxa.col), nrow = 0))
  colnames(empty.df) <- taxa.col
  DF <- empty.df
  
  # All the columns have to be type:characters
  x[] <- lapply(x, as.character)
  
  # Trim unnecessary spaces
  x[] <- lapply(x, trimws)
  
  # Remove duplicated
  x <- x[!duplicated(x), ]
  
  for (i in 1:ncol(x)) {
    temp.name <- colnames(x[, i, drop = FALSE])
    temp.pos <- which(colnames(x) == temp.name)
    temp <- x[, 1:temp.pos, drop = FALSE]
    temp <- temp[which(temp[, temp.name] != ""), , drop = FALSE]
    temp.un <- unique(temp)
    empty.df <- merge(empty.df, temp.un, all.y = TRUE, sort = FALSE)
    
    if(temp.name == 'Subspecies') {
      empty.df$Taxa <-
        paste(word(temp.un[, temp.name], 1, 2), 'subsp.', word(temp.un[, temp.name], 3))
    } else if (temp.name == 'Variety') {
      empty.df$Taxa <-
        paste(word(temp.un[, temp.name], 1, 2), 'var.', word(temp.un[, temp.name], 3))
      
    } else {
      empty.df$Taxa <- temp.un[, temp.name]
    }
    
    DF <- rbind.data.frame(DF, empty.df)
  }

  # Check if exist columns Species and subspecies in data frame
  if("Species" %in% colnames(x)){DF$Species <- word(DF$Species, -1)}
  if("Subspecies" %in% colnames(x)){DF$Subspecies <- word(DF$Subspecies, -1)}
  if("Variety" %in% colnames(x)){DF$Variety <- word(DF$Variety, -1)}
  DF <- DF[!duplicated(DF), ]
  
  return(DF)
  
}
  
