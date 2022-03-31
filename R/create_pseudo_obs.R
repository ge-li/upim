#' Create pseudo observations
#'
#' The pseudo observations is defined as \eqn{Y_{ij}^* = I(Y_i \preceq Y_j)}.
#' @param y numeric
#'
#' @return \eqn{Y_{ij}^*} as an vector with length `length(y)^2`.
#' @export
#'
#' @examples
#' create_pseudo_obs(c(-1, 0, 1))
create_pseudo_obs <- function(y) {
  # Note: as.vector(t(matrix)) flattens the matrix in row major fashion,
  #       R's default as.vector() will stretch a matrix in column major.
  # So it's the desired (1, 1), (1, 2), ..., (1, n), ->
  #                     (2, 1), (2, 2), ..., (2, n), ->
  #                                 ....., ->
  #                     (n, 1), (n, 2), ..., (n, n)
  # stacked by rows
  as.vector(t(outer(y, y, preceq)))
}
