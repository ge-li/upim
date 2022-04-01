#' Jacobian of PIM U-estimating function
#'
#' The Jacobian has the generic form
#' \eqn{\dot{\delta}(b) = \frac{\partial}{\partial b^{T}} \delta(b) =
#' \frac{\left(2 \mu y-y-\mu^{2}\right) \dot{\mu}^{2}+\mu(1-\mu)(y-\mu) \ddot{\mu}}{\mu^{2}(1-\mu)^{2}} x x^{T}}.
#'
#' @param y numeric A vector of pseudo observations.
#' @param X matrix The pairwise difference of original design matrix.
#' @param b numeric The PIM parameter.
#' @param link character The link function: "logit", or "probit".
#' @param w numeric The weights, default is NULL.
#'
#' @return matrix A `p` by `p` Jacobian matrix of `res_fun(...)`.
#' @export
#'
jac_est_fun <- function(y, X, b, link, w = NULL) {
  # Calculate linear part for reuse
  Xb <- as.vector(X %*% b)
  if (link == "logit") {
    # I've worked out the math.
    tmp <- -stats::dlogis(Xb)
  } else if (link == "probit") {
    # Avoid double overflow!
    # Take away: 1 - pnorm(10) is not as precise as pnorm(-10) in R!
    # DO NOT USE: (pnorm(Xb) * (1 - pnorm(Xb)))!
    # ALWAYS USE: (pnorm(-abs(Xb)) * (1 - pnorm(-abs(Xb))))
    f <- stats::pnorm(Xb)
    df <- stats::dnorm(Xb)
    ddnorm <- function(x) {
      # derivative of dnorm(x)
      -exp(-x ^ 2 / 2) * x / sqrt(2 * pi)
    }
    ddf <- ddnorm(Xb)
    f1mf <- (stats::pnorm(-abs(Xb)) * (1 - stats::pnorm(-abs(Xb))))
    tmp <- ((2 * f * y - y - f^2) * df^2 + f1mf * ddf * (y - f)) / (f1mf^2)
  } else {
    stop("`link` must be either \"logit\" or \"probit\".")
    # # ------------ Future work, if needed ------------
    # # For a generic link function, e.g., make.link("cloglog"),
    # # one can do
    # f <- make.link("cloglog")$linkinv(Xb)
    # df <- make.link("cloglog")$mu.eta(Xb)
    # ddf <- ddf(Xb) # user define ddf() corresponding to the link.
    # tmp <- ((2 * f * y - y - f ^ 2) * df ^ 2 + f * (1 - f) * ddf * (y - f)) / (f * (1 - f))^2
    # # CAUTION: if you calculate tmp raw, there will likely be numerical issues.
  }
  if (!is.null(w)) {
    tmp <- tmp * w
  }
  crossprod(tmp * X, X) / length(y) # dU_n: p x p
}

