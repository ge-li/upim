#' Meat of U sandwich estimator
#'
#' @param y numeric A vector of pseudo observations.
#' @param X matrix The pairwise difference of original design matrix.
#' @param b numeric The PIM parameter.
#' @param link character The link function: "logit", or "probit".
#' @param w numeric The weights, default is NULL.
#'
#' @return matrix A `p x p` matrix.
#' @export
sandwich_meat <- function(y, X, b, link, w) {
  n <- sqrt(length(y))
  U <- est_fun(y = y, X = X, b = b, link = link, w = w) # n^2 x p
  # split U into n chunks, each chunk represents a row in the estimating function
  U_i <- 2 * sapply(split.data.frame(U, rep(seq(n), each = n)), colSums) / (n - 1) # p * n
  if (is.vector(U_i)) { # if p == 1
    return(crossprod(U_i) / n)
  } else {
    return(tcrossprod(U_i) / n)
  }
}
