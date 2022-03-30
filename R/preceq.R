#' @title Preceq
#'
#' @description Calculate \eqn{I(x \preceq y) = I(x < y) + 0.5 I(x = y)}
#' @param x numeric
#' @param y numeric
#'
#' @return \eqn{I(x \preceq y)}
#' @export
#'
#' @examples
#' preceq(x = c(0, 0, 0), y = c(-1, 0, 1))
#' preceq(x = 0, y = c(-1, 0, 1))
preceq <- function(x, y) {
  (x < y) + 0.5 * (x == y)
}
