#' Remove y entry if x data is missing.
#'
#' @description
#'
#' This function remove y entry if x data is missing.
#'
#' @param x dataframe of taxa.
#'
#'
#' @keywords rm_origin
#'
#' @examples
#'
#' x <-  c("aaaa", "bbbb", "cccc", NA)
#' y <-  c("zzzz", "vvvv", "tttt", "uuuu")
#' rm_origin(x[1], y[1])
#' rm_origin(x[4], y[4])
#' 

rm_origin <- function(x, y) {
  z <- ifelse(length(x) == 0 || is.na(x) || x == "", "", y)
  
  return(z)
}