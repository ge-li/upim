#' Fit a probabilistic index model
#'
#' @param y numeric The outcome vector.
#' @param X matrix The design matrix.
#' @param link character The link function: "logit", or "probit".
#' @param w numeric The weights, default is NULL.
#' @param init numeric The initial guess of Newton's method.
#' @param tol numeric The numeric tolerance of `nleqslv()`.
#' @param max.iter numeric The maximum iteration of Newton's method.
#' @param nleqslv.global character The global strategy for Newton's method. See ?nleqslv::nleqslv.
#' @param trace logical Show Newton's method iteration report if TRUE.
#' @param test.nleqslv logical Test different global strategies for Newton's method if TRUE. See ?nleqslv::testnslv.
#' @param keep.data logical Should the returned object keep original data?
#'
#' @return A list containing the estimated coefficients and their covaraince
#'           matrix. It also contains the diagnostics of `nleqlsv()` procedure.
#'           If `keep.data` is `TRUE`, then the inputs `y`, `X`, `w`
#'           will also be returned.
#' @export
pim_fit <- function(y, X, link = "logit", w = NULL, init = NULL,
                    tol = sqrt(.Machine$double.eps), max.iter = 100,
                    nleqslv.global = "none",
                    trace = FALSE,
                    test.nleqslv = FALSE,
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
    b <- jitter(rep(0, p)) # initial guess, vector: p x 1
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

  if (test.nleqslv) {
    cat("  ----------------\n")
    cat("Test different methods for solving with `nleqlsv::testnslv()`:\n")
    cat("Message:\n")
    cat("Fcrit - Convergence of function values has been achieved.\n")
    cat("Xcrit - This means that the relative distance between two consecutive x-values is smaller than xtol.\n")
    cat("Stalled - The algorithm cannot find an acceptable new point.\n")
    cat("Maxiter - Iteration limit maxit exceeded.\n")
    cat("Illcond - Jacobian is too ill-conditioned.\n")
    cat("Singular - Jacobian is singular.\n")
    cat("BadJac - Jacobian is unusable.\n")
    test_res <- nleqslv::testnslv(
      x = b,
      fn = U,
      jac = dU,
      method = c("Newton"), # "Broyden" available, but not useful for PIM
      global = c("none", "cline", "qline", "gline", "pwldog", "dbldog", "hook"),
      control = list(xtol = tol, ftol = tol, cndtol = tol, maxit = max.iter)
    )
    test_res$out$`Largest |f|` = sqrt(test_res$out$Fnorm * 2)
    print(test_res$out)
    return(test_res$out)
  }

  if (trace) {
    cat("**Showing nleqslv::nleqslv() iteration report**\n")
    cat("  Columns:\n")
    cat("  --------\n")
    cat("  Jac - Jacobian type (reciprocal condition number); N: Newton Jacobian; B: Broyden updated matrix\n")
    cat("  Lambda - Line search parameter\n")
    cat("  Fnorm - Fnorm square of the euclidean norm of function values / 2\n")
    cat("  Largest |f| - Infinity norm of f(x) at the current point\n\n")
  }

  # Use Newton's method to find the root of the estimating equation.
  slv <- NULL
  try(
    slv <- nleqslv::nleqslv(
      b, # initial guess
      U, # estimating function
      method = "Newton", # use Newton's method, i.e., update Jac for each iter
      jac = dU, # analytic Jacobian for the estimating function
      jacobian = TRUE, # return Jacobian
      global = nleqslv.global, # global strategy for Newton's method
      control = list(
        xtol = tol, # step length tolerance.
        ftol = tol, # ||f||_\infty, function value tolerance
        cndtol = tol, # Jacobian reciprocal condition number tolerance
        maxit = max.iter, # maximum iteration
        trace = trace # whether print iteration report
      )
    ),
    silent = TRUE
  )
  if (trace) {
    cat("\n")
    cat("  Results:\n")
    cat("  --------\n")
  }

  # Check convergence
  # 1. Check if object exist
  if (is.null(slv)) {
    stop("Cannot find a solution to the PIM estimating equation.")
  }
  # 2. The initial guess might result in function value within tolerance.
  #    Double-check if Jacobian is indeed non-singular.
  inv_jac <- NULL
  try(slv$inv_jac <- solve(slv$jac, tol = tol), silent = TRUE)
  if (is.null(slv$inv_jac)) {
    stop("Jacobian of the PIM estimating function is not invertible.")
  }
  # 3. Check nleqslv termination code, e.g., if termcd = 4, maxit is exceeded.
  if (slv$termcd != 1) {
    stop(paste("nleqslv() termination code: ", slv$termcd, " - ", slv$message, sep = ""))
  }

  # Pass all checks, claim convergence.
  if (trace) {
    cat("  Convergence achieved: PIM estimating function value is within tolerance.\n")
  }

  # Sandwich estimator for U-statistics Z-estimator.
  slv$meat <- sandwich_meat(y = y_new, X = X_new, b = slv$x, link = link, w = w)
  slv$vcov <- slv$inv_jac %*% slv$meat %*% slv$inv_jac / n

  # Touch up the returning object.
  names(slv)[1] <- "coef"
  names(slv$coef) <- colnames(X)
  colnames(slv$vcov) <- colnames(X)
  rownames(slv$vcov) <- colnames(X)
  colnames(slv$jac) <- colnames(X)
  rownames(slv$jac) <- colnames(X)
  slv$link <- link
  slv$w <- w
  slv$y <- y
  slv$X <- X
  if (keep.data) {
    return(slv[c("coef", "jac", "vcov", "link", "w", "y", "X")])
  } else {
    return(slv[c("coef", "jac", "vcov", "link")])
  }

}



