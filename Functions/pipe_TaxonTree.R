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
#' df <- read.csv("./Desktop/Catalogo_Odonata_2023-08-01.csv")
#'
#' df <- df %>%
#' select(Phylum, Order, Family, Genus, Species, Subspecies)
#'  
#' cbb_tree(df)

  
x = df

cbb_tree <- function(x){
  
  # Check if the x object is a data frame. If not stop the function
  if (!is.data.frame(x)) {
    stop("Input is not a data frame.")
  }
  
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
    empty.df$Taxa <- temp.un[, temp.name]
    DF <- rbind.data.frame(DF, empty.df)
  }

  
  # Add si existe esta columna !!!!!!!!!!!!
  DF$Species <- word(DF$Species, -1)
  DF$Subspecies <- word(DF$Subspecies, -1)
  DF <- DF[!duplicated(DF), ]
  
  # DF <- DF[, match(taxa.col, colnames(DF))]
  
  return(DF)
  
}
  
  
  
  
