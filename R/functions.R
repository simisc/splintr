#' Generate a basis matrix for natural cubic splines with interpretable intercepts
#' @export
#' @param ... Parameters passed to \code{\link[splines]{ns}}.
#' @param centre The \code{x}-value at which all spline terms should be zero.
#' @return A matrix of dimension \code{length(x)} by \code{df}, like \code{\link[splines]{ns}}.
#'   Attributes are that correspond to the arguments to \code{ns()} with an additional
#'   \code{centre} attribute for use by \code{predict.splintr()}.
splintr <- function(..., centre = 0) {
  n <- splines::ns(...)
  adj <- predict(n, newx = centre)
  # df <- length(attr(n, "knots")) + 1
  # for (i in 1:df) n[, i] <- n[, i] - adj[i]
  n <- sweep(n, 2, adj)
  class(n)[1L] <- "splintr"
  attr(n, "centre") <- centre
  return(n)
}

makepredictcall.splintr <- function (var, call) {
  # if (as.character(call)[1L] != "splintr")
  #   return(call)
  as.character(call)[1L] != "splintr" && return(call)
  at <- attributes(var)[c("knots",
                          "Boundary.knots",
                          "intercept",
                          "centre")]
  x <- call[1L:2L]
  x[names(at)] <- at
  return(x)
}

predict.splintr <- function (object, newx, ...) {
  # if (missing(newx))
  #   return(object)
  missing(newx) && return(object)
  a <- c(list(x = newx),
         attributes(object)[c("knots",
                              "Boundary.knots",
                              "intercept",
                              "centre")])
  n <- do.call("splintr", a)
  return(n)
}
