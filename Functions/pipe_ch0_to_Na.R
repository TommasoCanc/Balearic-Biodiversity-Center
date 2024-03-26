#' Substitute "" or NA values with selected string.
#'
#' @description
#'
#' This function substitute "" or NA values with selected string.
#'
#' @param x dataframe of taxa.
#'
#'
#' @keywords ch0_to_Na
#'
#' @examples
#'
#' x <- c("aaaa", "bbbb", "cccc", NA)
#' ch0_to_Na(x[1])
#' ch0_to_Na(x[4], str = "dddd")

ch0_to_Na <- function(x, str = "") {
  y <- ifelse(length(x) == 0 || is.na(x), str, x)
  
  return(y)
  
}





