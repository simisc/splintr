#' Generate centred basis matrix
#'
#' Generate the basis matrix for a natural cubic splines with interpretable
#'   intercepts
#' @export
#' @param ... Parameters passed to \code{\link[splines]{ns}}.
#' @param centre The \code{x}-value at which all spline terms should be zero.
#' @return A matrix of dimension \code{length(x)} by \code{df},
#'   like \code{\link[splines]{ns}}. Attributes correspond to those of
#'   \code{\link[splines]{ns}} with an additional \code{centre} attribute for
#' use by \code{predict.splintr()}.
splintr <- function(..., centre = 0) {
  n <- splines::ns(...)
  adj <- predict(n, newx = centre)
  n <- sweep(n, 2, adj)
  class(n)[1] <- "splintr"
  attr(n, "centre") <- centre
  return(n)
}

#' @export
makepredictcall.splintr <- function(var, call) {
  # For prediction from models that use splintr in the formula
  as.character(call)[1L] != "splintr" && return(call)
  x <- call[1L:2L]
  atnames <- c("knots", "Boundary.knots", "intercept", "centre")
  x[atnames] <- attributes(var)[atnames]
  return(x)
}

#' @export
predict.splintr <- function(object, newx, ...) {
  # For prediction from the splintr object itself
  missing(newx) && return(object)
  atnames <- c("knots", "Boundary.knots", "intercept", "centre")
  a <- c(list(x = newx), attributes(object)[atnames])
  n <- do.call("splintr", a)
  return(n)
}

#' Utility Function for Safe Prediction
#'
#' Imported from \code{\link[stats]{makepredictcall}}
#' @importFrom stats makepredictcall
#' @name makepredictcall
#' @export
NULL

#' Model predictions
#'
#' Imported from \code{\link[stats]{predict}}
#' @importFrom stats predict
#' @name predict
#' @export
NULL
