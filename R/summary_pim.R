#' Get summary statistics for fitted PIM.
#'
#' @param pim_obj - fitted object from [pim_fit()]
#'
#' @return a data frame with columns
#'   \tabular{ll}{
#'   \code{term} \tab covariates \cr
#'   \code{estimate} \tab point estimate \cr
#'   \code{std.error} \tab standard error \cr
#'   \code{statistic} \tab Z-statistic (asymptotic) \cr
#'   \code{p.value} \tab p-value \cr
#'   \code{link} \tab link function used \cr
#'   \code{prob.index} \tab probabilistic index \cr
#'   \code{prob.index.se} \tab standard error of the probabilistic index \cr
#' }
#' @export
#'
#' @examples
#' pim_obj <- pim_fit(mtcars$mpg, mtcars[c("cyl", "disp")], link = "logit", nleqslv.global = "dbldog")
#' summary_pim(pim_obj)
#' pim_obj <- pim_fit(mtcars$mpg, mtcars[c("cyl", "disp")], link = "probit", nleqslv.global = "dbldog")
#' summary_pim(pim_obj)
summary_pim <- function(pim_obj) {
  sum_stat <- data.frame(
    term = names(pim_obj$coef),
    estimate = pim_obj$coef,
    std.error = sqrt(diag(pim_obj$vcov))
  )
  sum_stat$statistic <- sum_stat$estimate / sum_stat$std.error
  sum_stat$p.value <- 2 * (1 - pnorm(abs(sum_stat$statistic)))
  sum_stat$link <- pim_obj$link
  if (pim_obj$link == "logit") {
    sum_stat$prob.index <- plogis(sum_stat$estimate)
    sum_stat$prob.index.se <- sum_stat$std.error * dlogis(sum_stat$estimate)
  } else if (pim_obj$link == "probit") {
    sum_stat$prob.index <- pnorm(sum_stat$estimate)
    sum_stat$prob.index.se <- sum_stat$std.error * dnorm(sum_stat$estimate)
  }

  rownames(sum_stat) <- NULL
  sum_stat
}
