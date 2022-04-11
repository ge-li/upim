#' Fit a probabilistic index model
#'
#' @param y numeric The outcome vector.
#' @param X matrix The design matrix.
#' @param link character The link function: "logit", or "probit".
#' @param w numeric The weights, default is NULL.
#' @param init numeric The initial guess of Newton's method.
#' @param tol numeric The numeric tolerance of `nleqslv()`.
#' @param max.iter numeric The maximum iteration of Newton's method.
#' @param keep.data logical Should the returned object keep original data?
#'
#' @return A list containing the estimated coefficients and their covaraince
#'           matrix. It also contains the diagnostics of `nleqlsv()` procedure.
#'           If `keep.data` is `TRUE`, then the inputs `y`, `X`, `link`, `w`
#'           will also be returned.
#' @export
pim_fit <- function(y, X, link = "logit", w = NULL,
                    init = NULL, tol = 1e-6, max.iter = 200,
                    keep.data = FALSE) {
  # handle the inputs
  if (is.vector(X)) {
    X <- as.matrix(X, ncol = 1)
  }
  if (!is.matrix(X)) {
    X <- as.matrix(X)
  }
  n <- length(y)
  p <- NCOL(X)
  if (link != "logit" && link != "probit") {
    stop("`link` must be either \"logit\" or \"probit\".")
  }

  # transform the original data into pairwise comparison data
  y_new <- create_pseudo_obs(y) # vector: n^2 x 1
  X_new <- new_design_matrix(X) # matrix: n^2 x p

  if (is.null(init)) {
    b <- rep(0, p) # initial guess, vector: p x 1
  } else {
    b <- init
  }

  # Wrapped estimating function.
  U <- function(b) {
    # est_fun() returns a n^2 x p matrix, need to take average
    .colMeans(est_fun(y = y_new, X = X_new, b = b, link = link, w = w), n^2, p)
  }
  # Wrapped Jacobian of estimating function.
  dU <- function(b) {
    jac_est_fun(y = y_new, X = X_new, b = b, link = link, w = w)
  }

  # Find the root of the estimating equation.
  slv <- nleqslv::nleqslv(b, U, method = "Newton", jac = dU, jacobian = TRUE,
                          control = list(xtol = tol, ftol = tol,
                                         maxit = max.iter))

  b <- slv$x # set b to solution

  # Sandwich estimator for U-statistics Z-estimator.
  meat <- sandwich_meat(y = y_new, X = X_new, b = b, link = link, w = w)
  slv$vcov <- solve(slv$jac) %*% meat %*% solve(slv$jac) / n

  # Touch up the returning object.
  names(slv)[1] <- "coef"
  names(slv$coef) <- colnames(X)
  colnames(slv$vcov) <- colnames(X)
  rownames(slv$vcov) <- colnames(X)
  if (slv$termcd != 1) {
    warning(paste("Termination Code: ", slv$termcd, " - ", slv$message, sep = ""))
  }
  if (keep.data) {
    slv$y = y
    slv$X = X
    slv$link = link
    slv$w = w
  }
  slv
}



