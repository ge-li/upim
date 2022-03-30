#' New design matrix
#'
#' Create new design matrix \eqn{X_{ij}^* = X_j - X_i} for PIM.
#'
#' @param X matrix original design matrix
#'
#' @return Assuming `n = NROW(X)`, `p = NCOL(X)`,
#'   the returned object is also an matrix but with dimension n^2 x p.
#' @export
#'
#' @examples
#' X <- matrix(c(4, 9, 2, 3, 5, 7, 8, 1, 6), ncol = 3, byrow = TRUE)
#' new_design_matrix(X)
new_design_matrix <- function(X) {
  n <- NROW(X)
  ind <- seq_len(n) # equivalent to 1:n, but faster
  i <- rep(ind, rep(n, n)) # 1,...,1; ...; n,...,n
  j <- rep(ind, n)         # 1,...,n; ...; 1,...,n
  X[j, , drop = FALSE] - X[i, , drop = FALSE] # keep column form when p = 1
}
