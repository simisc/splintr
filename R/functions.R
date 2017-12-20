splintr <- function(..., centre = 0) {
  n <- splines::ns(...)
  adj <- predict(n, newx = centre)
  df <- length(attr(n, "knots")) + 1

  length(adj) == df || stop("Length of adj does not much df.")

  for (i in 1:df) {
    n[, i] <- n[, i] - adj[i]
  }

  class(n)[1] <- "splintr"
  # class(n) <- c("splintr", class(n))
  attr(n, "centre") <- centre
  n
}

makepredictcall.splintr <- function (var, call) {
  if (as.character(call)[1L] != "splintr")
    return(call)
  at <- attributes(var)[c("knots", "Boundary.knots",
                          "intercept", "centre")]
  xxx <- call[1L:2L]
  xxx[names(at)] <- at
  xxx
}

predict.splintr <- function (object, newx, ...) {
  if (missing(newx))
    return(object)
  a <- c(list(x = newx),
         attributes(object)[c("knots",
                              "Boundary.knots",
                              "intercept",
                              "centre")])
  n <- do.call("splintr", a)
  # should this be the return value? Check usage n original
  return(n)
}
