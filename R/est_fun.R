#' PIM U-estimating function
#'
#' The component estimating function is
#' \eqn{\delta(b)=\frac{\dot{\mu}(x^T b)}{\mu(x^T b)[1-\mu(x^T b)]}[y-\mu(x^T b)]w x}.
#' Here, \eqn{\mu} is the inverse of the link function. In "logit" case,
#' it can be simplified.
#'
#' @param y numeric A vector of pseudo observations.
#' @param X matrix The pairwise difference of original design matrix.
#' @param b numeric The PIM parameter.
#' @param link character The link function: "logit", or "probit".
#' @param w numeric The weights, default is NULL.
#'
#' @return matrix A `n^2 x p` matrix contains the `n^2` transposed estimating fun.
#' @export
#'
est_fun <- function(y, X, b, link, w = NULL) {
  # Calculate linear part for reuse
  Xb <- as.vector(X %*% b)
  if (link == "logit") {
    tmp <- 1 # dlogis(x) / (plogis(x) * (1 - plogis(x))) is 1
    U <- X * (y - stats::plogis(Xb)) # * tmp, omit for efficiency
  } else if (link == "probit") {
    # Avoid double overflow!
    # Take away: 1 - pnorm(10) is not as precise as pnorm(-10) in R!
    # DO NOT USE: tmp <- dnorm(Xb) / (pnorm(Xb) * (1 - pnorm(Xb)))!
    tmp <- stats::dnorm(Xb) / (stats::pnorm(-abs(Xb)) * (1 - stats::pnorm(-abs(Xb))))
    U <- X * (y - stats::pnorm(Xb)) * tmp
  } else {
    stop("`link` must be either \"logit\" or \"probit\".")
    # # ------------ Future work, if needed ------------
    # # For a generic link function, e.g., make.link("cloglog"),
    # # one can do
    # f <- make.link("cloglog")$linkinv(Xb)
    # df <- make.link("cloglog")$mu.eta(Xb)
    # U <- X * ((y - f) * df) / (f * (1 - f))
    # # But, the make.link() function is not as precise as e.g., pnorm().
  }
  if (!is.null(w)) {
    U <- U * w
  }
  U
}


